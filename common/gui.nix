{
  conifg,
  pkgs,
  nixpkgs-unstable,
  ...
}: {
  imports = [
    ./key-remap.nix
  ];
  services.xserver.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;
  hardware.sane.enable = true;
  users.users.ikovalev.extraGroups = [
    "scanner"
    "lp"
  ];
  services.printing.drivers = [
    pkgs.cnijfilter2
    pkgs.gutenprint
  ];

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  services.displayManager.sddm.wayland.enable = true;
  services.displayManager.sddm.enable = true;

  services.gvfs.enable = true;

  services.udisks2.enable = true;

  security.rtkit.enable = true;

  hardware.bluetooth.settings = {
    General = {
      Experimental = true;
    };
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [xdg-desktop-portal-hyprland];
  };

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber = {
      enable = true;
      extraConfig.pipewire-pulse."92-low-latency" = {
        context.modules = [
          {
            name = "libpipewire-module-protocol-pulse";
            args = {
              pulse.min.req = "32/48000";
              pulse.default.req = "32/48000";
              pulse.max.req = "32/48000";
              pulse.min.quantum = "32/48000";
              pulse.max.quantum = "32/48000";
            };
          }
        ];
        stream.properties = {
          node.latency = "32/48000";
          resample.quality = 1;
        };
      };
      extraConfig."90-disable-suspend" = {
        "monitor.alsa.rules" = [
          {
            "matches" = [
              {"device.name" = "~alsa_card.*";}
            ];
            "actions" = {
              "update-props" = {
                "session.suspend-timeout-seconds" = 0;
              };
            };
          }
          {
            "matches" = [
              {"node.name" = "~alsa_output.*";}
              {"node.name" = "~alsa_input.*";}
            ];
            "actions" = {
              "update-props" = {
                "node.pause-on-idle" = false;
                "node.suspend-on-idle" = false;
                "session.suspend-timeout-seconds" = 0;
              };
            };
          }
        ];
      };
      extraConfig."60-latency" = {
        "context.properties" = {
          "default.clock.rate" = 48000;
          "default.clock.allowed-rates" = [48000];
          "default.clock.quantum" = 512;
          "default.clock.min-quantum" = 512;
          "default.clock.max-quantum" = 512;
        };
      };
    };
  };

  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "ikovalev";

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  # Install some GNOME extensions and essential packages
  environment.systemPackages = with pkgs; [
    easyeffects
    video-trimmer
    alacritty
    alacritty-theme
  ];
}
