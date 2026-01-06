#!/usr/bin/env python3
"""
SSH Toggle - A system tray app to enable SSH while running.
SSH server starts when this app launches and stops when it closes.
"""

import gi
import signal
import subprocess
import sys
import atexit

gi.require_version("Gtk", "3.0")
gi.require_version("AppIndicator3", "0.1")

from gi.repository import Gtk, AppIndicator3, GLib


class SSHToggle:
    def __init__(self):
        self.ssh_enabled = False

        self.indicator = AppIndicator3.Indicator.new(
            "ssh-toggle",
            "network-server-symbolic",
            AppIndicator3.IndicatorCategory.SYSTEM_SERVICES,
        )
        self.indicator.set_status(AppIndicator3.IndicatorStatus.ACTIVE)

        self.menu = Gtk.Menu()

        self.status_item = Gtk.MenuItem(label="SSH: Starting...")
        self.status_item.set_sensitive(False)
        self.menu.append(self.status_item)

        self.menu.append(Gtk.SeparatorMenuItem())

        quit_item = Gtk.MenuItem(label="Stop SSH & Quit")
        quit_item.connect("activate", self.quit)
        self.menu.append(quit_item)

        self.menu.show_all()
        self.indicator.set_menu(self.menu)

        GLib.idle_add(self.start_ssh)

        atexit.register(self.stop_ssh)

    def run_systemctl(self, action):
        """Run systemctl command with pkexec for privilege escalation."""
        try:
            result = subprocess.run(
                ["pkexec", "systemctl", action, "sshd"], capture_output=True, text=True
            )
            return result.returncode == 0
        except Exception as e:
            print(f"Error running systemctl {action}: {e}")
            return False

    def check_ssh_status(self):
        """Check if SSH service is running."""
        try:
            result = subprocess.run(
                ["systemctl", "is-active", "sshd"], capture_output=True, text=True
            )
            return result.stdout.strip() == "active"
        except Exception:
            return False

    def start_ssh(self):
        """Start the SSH service."""
        if self.run_systemctl("start"):
            self.ssh_enabled = True
            self.update_status()
            self.indicator.set_icon_full("network-server-symbolic", "SSH Active")
        else:
            self.status_item.set_label("SSH: Failed to start")
            self.show_notification("SSH Toggle", "Failed to start SSH server")
        return False

    def stop_ssh(self):
        """Stop the SSH service."""
        if self.ssh_enabled:
            subprocess.run(["pkexec", "systemctl", "stop", "sshd"], capture_output=True)
            self.ssh_enabled = False

    def update_status(self):
        """Update the status menu item."""
        if self.check_ssh_status():
            self.status_item.set_label("SSH: Running")
            self.indicator.set_icon_full("network-server-symbolic", "SSH Active")
        else:
            self.status_item.set_label("SSH: Stopped")
            self.indicator.set_icon_full("network-offline-symbolic", "SSH Stopped")

    def show_notification(self, title, message):
        """Show a desktop notification."""
        try:
            subprocess.run(["notify-send", title, message], check=False)
        except Exception:
            pass

    def quit(self, _widget=None):
        """Stop SSH and quit the application."""
        self.stop_ssh()
        Gtk.main_quit()


def signal_handler(_sig, _frame):
    """Handle signals gracefully."""
    Gtk.main_quit()


def main():
    signal.signal(signal.SIGINT, signal_handler)
    signal.signal(signal.SIGTERM, signal_handler)

    GLib.unix_signal_add(GLib.PRIORITY_DEFAULT, signal.SIGINT, Gtk.main_quit)

    app = SSHToggle()
    Gtk.main()


if __name__ == "__main__":
    main()
