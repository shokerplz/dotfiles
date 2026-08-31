{...}: {
  flake.nixosModules.roleGraphical = {pkgs, ...}: {
    programs = {
      appimage = {
        enable = true;
        binfmt = true;
      };
      hyprland = {
        enable = true;
        withUWSM = true;
      };
    };
    networking.domain = "home";

    nix.settings.substituters = [
      "https://nix-cache.ikovalev.nl"
    ];
    nix.settings.trusted-public-keys = [
      "nix-cache.ikovalev.nl:Krpx8e2jWFxP2mc+AqXkkMX0tGBFCskuRcWUcNZ4DtQ="
    ];
    fonts.packages = with pkgs; [
      nanum
    ];

    services = {
      udisks2.enable = true;
      gvfs.enable = true;
      xserver.enable = true;
      xserver.xkb = {
        layout = "us";
        variant = "";
      };
      printing = {
        enable = true;
        drivers = [
          pkgs.cnijfilter2
          pkgs.gutenprint
        ];
      };
      displayManager = {
        sddm = {
          wayland.enable = true;
          enable = true;
        };

        autoLogin.enable = true;
        autoLogin.user = "ikovalev";
      };

      # Key remap
      keyd = {
        enable = true;
        keyboards = {
          default = {
            settings = {
              main = {
                leftmeta = "layer(command)";
                leftalt = "layer(option)";
              };

              "command:C" = {
                c = "f23";
                v = "f24";
                x = "S-delete";

                left = "home";
                right = "end";
                up = "C-home";
                down = "C-end";

                backspace = "C-u";

                # Command+Space → Ctrl+Space for language switching
                space = "M-space";

                # Pass through for Hyprland window switching
                tab = "M-tab";

                # Pass through for Hyprland workspaces (Super+Number)
                "1" = "M-1";
                "2" = "M-2";
                "3" = "M-3";
                "4" = "M-4";
                "5" = "M-5";
                "6" = "M-6";
                "7" = "M-7";
                "8" = "M-8";
                "9" = "M-9";
              };

              "option:A" = {
                left = "C-left";
                right = "C-right";
                backspace = "A-backspace";
              };

              "app_switch:A" = {
                tab = "A-tab";
                "S-tab" = "A-S-tab";
              };
            };

            # Composite layers MUST come AFTER constituent layers
            # NixOS settings dict is alphabetically sorted, so we use extraConfig
            extraConfig = ''
              [command+shift]
              v = M-S-v
              tab = M-S-tab
              1 = M-S-1
              2 = M-S-2
              3 = M-S-3
              4 = M-S-4
              5 = M-S-5
              6 = M-S-6
              7 = M-S-7
              8 = M-S-8
              9 = M-S-9
            '';
          };
        };
      };

      pulseaudio.enable = false;
      pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        wireplumber = {
          enable = true;
          extraConfig = {
            pipewire-pulse."92-low-latency" = {
              context.modules = [
                {
                  name = "libpipewire-module-protocol-pulse";
                  args = {
                    pulse = {
                      min.req = "32/48000";
                      default.req = "32/48000";
                      max.req = "32/48000";
                      min.quantum = "32/48000";
                      max.quantum = "32/48000";
                    };
                  };
                }
              ];
              stream.properties = {
                node.latency = "32/48000";
                resample.quality = 1;
              };
            };
            "90-disable-suspend" = {
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
            "60-latency" = {
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
      };
    };

    hardware = {
      sane.enable = true;
      bluetooth = {
        enable = true;
        powerOnBoot = true;
        settings = {
          General = {
            Experimental = true;
          };
        };
      };
    };
    users.users.ikovalev.extraGroups = [
      "scanner"
      "lp"
    ];

    security.rtkit.enable = true;
  };
}
