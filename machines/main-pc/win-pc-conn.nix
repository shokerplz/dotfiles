{
  pkgs,
  config,
  ...
}: {
  programs.kdeconnect.enable = true;

  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        "workgroup" = "WORKGROUP";
        "server string" = "main-pc";
        "netbios name" = "MAIN-PC";
        "security" = "user";
        "acl allow execute always" = "yes";
        "map to guest" = "never";
        "hosts allow" = "10.0.100. 127.0.0.1 localhost";
        "hosts deny" = "0.0.0.0/0";
      };
      "Downloads" = {
        "path" = "/home/ikovalev/Downloads";
        "browseable" = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "valid users" = "ikovalev";
        "force user" = "ikovalev";
        "create mask" = "0644";
        "directory mask" = "0755";
      };
      "projects" = {
        "path" = "/home/ikovalev/projects";
        "browseable" = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "valid users" = "ikovalev";
        "force user" = "ikovalev";
        "create mask" = "0644";
        "directory mask" = "0755";
      };
    };
  };

  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };

  systemd.user.services.kdeconnectd = {
    description = "KDE Connect daemon";
    partOf = ["graphical-session.target"];
    after = ["graphical-session.target"];
    wantedBy = ["graphical-session.target"];

    serviceConfig = {
      ExecStart = "${pkgs.kdePackages.kdeconnect-kde}/bin/kdeconnectd";
      Restart = "on-failure";
      RestartSec = 5;
    };
  };

  systemd.user.services.kdeconnect-indicator = {
    description = "KDE Connect indicator";
    partOf = ["graphical-session.target"];
    after = ["graphical-session.target" "kdeconnectd.service"];
    wantedBy = ["graphical-session.target"];

    serviceConfig = {
      ExecStart = "${pkgs.kdePackages.kdeconnect-kde}/bin/kdeconnect-indicator";
      Restart = "on-failure";
      RestartSec = 5;
    };
  };

  networking = {
    nat.enable = true;
    nat = {
      externalInterface = "enp14s0";
      internalInterfaces = ["enp13s0"];
      internalIPs = ["10.0.100.0/24"];
    };
    interfaces = {
      enp13s0 = {
        mtu = 9000;
        ipv4.addresses = [
          {
            address = "10.0.100.1";
            prefixLength = 24;
          }
        ];
      };
    };
  };
}
