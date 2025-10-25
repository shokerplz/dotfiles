# GNOME Extensions Auto-Enable Guide

## Overview
This configuration automatically enables GNOME extensions using home-manager's dconf settings.

## How It Works
- Extensions are installed system-wide via `common/gui.nix`
- Extensions are auto-enabled per-user via `users/ikovalev/home.nix`
- Settings are applied through dconf on login

## Finding Extension UUIDs
To find the UUID of an extension:

1. **After installing the extension package**, look in:
   ```bash
   ls ~/.local/share/gnome-shell/extensions/
   # or system-wide:
   ls /run/current-system/sw/share/gnome-shell/extensions/
   ```

2. **From the extension metadata.json**:
   ```bash
   cat /run/current-system/sw/share/gnome-shell/extensions/*/metadata.json | jq -r '.uuid'
   ```

3. **Common extension UUIDs**:
   - Dash to Dock: `dash-to-dock@micxgx.gmail.com`
   - AppIndicator: `appindicatorsupport@rgcjonas.gmail.com`
   - Clipboard History: `clipboard-history@alexsaveau.dev`
   - System Monitor: Check actual UUID after installation
   - GSConnect: `gsconnect@andyholmes.github.io`

## Adding New Extensions

1. Add package to `common/gui.nix`:
   ```nix
   environment.systemPackages = with pkgs; [
     gnomeExtensions.your-extension
   ];
   ```

2. Add UUID to `users/ikovalev/home.nix`:
   ```nix
   dconf.settings."org/gnome/shell".enabled-extensions = [
     "your-extension-uuid@author.com"
   ];
   ```

## Troubleshooting

- Extensions not appearing: Check if UUID is correct
- Extensions disabled: Verify `disable-user-extensions = false`
- After GNOME updates: May need to restart GNOME Shell (Alt+F2, type 'r', Enter)
