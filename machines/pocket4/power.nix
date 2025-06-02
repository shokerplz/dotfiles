{ config, pkgs, ... }:

{

  boot.kernelPackages = pkgs.linuxPackages.extend (
    self: super: {
      "ryzen-smu" = super."ryzen-smu".overrideAttrs (_: {
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

  environment.systemPackages = with pkgs; [ ryzenadj ];
  systemd.targets.ac = {
    description = "AC power";
    conflicts = [ "battery.target" ];
    unitConfig.DefaultDependencies = "false";
  };

  systemd.targets.battery = {
    description = "Battery power";
    conflicts = [ "ac.target" ];
    unitConfig.DefaultDependencies = "false";
  };

  services.udev.extraRules = ''
    # fire ac.target when AC adapter is plugged in
    SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ENV{POWER_SUPPLY_ONLINE}=="1", \
        TAG+="systemd", ENV{SYSTEMD_WANTS}+="ac.target"

    # fire battery.target when it is unplugged
    SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ENV{POWER_SUPPLY_ONLINE}=="0", \
        TAG+="systemd", ENV{SYSTEMD_WANTS}+="battery.target"
  '';

  systemd.services.tdp-battery-15w = {
    description = "Limit APU to 15 W when on battery";
    wantedBy = [ "battery.target" ];
    unitConfig.RefuseManualStart = true;
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.ryzenadj}/bin/ryzenadj --stapm-limit=15000 --fast-limit=15000 --slow-limit=15000";
    };
  };

  systemd.services.tdp-ac-54w = {
    description = "Raise APU limit to 54 W when on AC";
    wantedBy = [ "ac.target" ];
    unitConfig.RefuseManualStart = true;
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.ryzenadj}/bin/ryzenadj --stapm-limit=54000 --fast-limit=54000 --slow-limit=54000";
    };
  };

}
