{pkgs, ...}: {
  services.power-profiles-daemon.enable = false;

  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0;

      PLATFORM_PROFILE_ON_AC = "performance";
      PLATFORM_PROFILE_ON_BAT = "low-power";

      SATA_LINKPWR_ON_BAT = "med_power_with_dipm";
      AHCI_RUNTIME_PM_ON_BAT = "auto";

      RUNTIME_PM_ON_AC = "auto";
      RUNTIME_PM_ON_BAT = "auto";

      WIFI_PWR_ON_AC = "off";
      WIFI_PWR_ON_BAT = "off";

      USB_AUTOSUSPEND = 1;

      WOL_DISABLE = "Y";
    };
  };

  boot.kernelPackages = pkgs.linuxPackages.extend (
    self: super: {
      ryzen-smu = super.ryzen-smu.overrideAttrs (_: {
        src = pkgs.fetchFromGitHub {
          owner = "amkillam";
          repo = "ryzen_smu";
          rev = "c4986ced92cca69e3f4e51caff1402e9baafdee2";
          hash = "sha256-I99bAZArcIPppYnUU6d1IwbhEzYnDGTzSE7Pc7wW5rA=";
        };
        version = "2025-05-09";
      });
    }
  );

  hardware.cpu.amd.ryzen-smu.enable = true;

  systemd.targets.ac = {
    description = "AC power";
    conflicts = ["battery.target"];
    unitConfig.DefaultDependencies = "false";
  };

  systemd.targets.battery = {
    description = "Battery power";
    conflicts = ["ac.target"];
    unitConfig.DefaultDependencies = "false";
  };

  services.upower.enable = true;

  services.udev.extraRules = ''
    SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ENV{POWER_SUPPLY_ONLINE}=="1", \
        TAG+="systemd", ENV{SYSTEMD_WANTS}+="ac.target"

    SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ENV{POWER_SUPPLY_ONLINE}=="0", \
        TAG+="systemd", ENV{SYSTEMD_WANTS}+="battery.target"
  '';

  systemd.services.tdp-battery-15w = {
    description = "Limit APU to 15 W when on battery";
    wantedBy = ["battery.target"];
    unitConfig.RefuseManualStart = true;
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.ryzenadj}/bin/ryzenadj --stapm-limit=15000 --fast-limit=15000 --slow-limit=15000";
    };
  };

  systemd.services.tdp-ac-54w = {
    description = "Raise APU limit to 54 W when on AC";
    wantedBy = ["ac.target"];
    unitConfig.RefuseManualStart = true;
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.ryzenadj}/bin/ryzenadj --stapm-limit=54000 --fast-limit=54000 --slow-limit=54000";
    };
  };

  systemd.services.disable-usb-wakeup = {
    description = "Disable USB controller wake sources";
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "disable-usb-wakeup" ''
        echo XHC0 > /proc/acpi/wakeup || true
      '';
    };
  };

  systemd.services.usb4-suspend-workaround = {
    description = "Disable USB4 runtime PM before sleep";
    wantedBy = ["sleep.target"];
    before = ["sleep.target"];
    unitConfig.StopWhenUnneeded = true;
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "usb4-suspend-prepare" ''
        for dev in /sys/bus/pci/devices/0000:c7:00.*/power/control; do
          [ -f "$dev" ] && echo on > "$dev" 2>/dev/null || true
        done
      '';
      ExecStop = pkgs.writeShellScript "usb4-suspend-restore" ''
        for dev in /sys/bus/pci/devices/0000:c7:00.*/power/control; do
          [ -f "$dev" ] && echo auto > "$dev" 2>/dev/null || true
        done
      '';
    };
  };
}
