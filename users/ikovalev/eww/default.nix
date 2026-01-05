# EWW (ElKowars Wacky Widgets) configuration
# Modular widget system for Hyprland
{pkgs, lib, ...}: let
  # Common PATH export for all scripts
  pathExport = ''export PATH="$PATH:/run/current-system/sw/bin:$HOME/.nix-profile/bin"'';

  # Import widget modules
  audioWidget = import ./audio.nix {inherit pathExport;};
  powerWidget = import ./power.nix {inherit pathExport;};
  notificationsWidget = import ./notifications.nix {inherit pathExport;};

  # Combine all widget modules
  widgets = [audioWidget powerWidget notificationsWidget];

  # Merge all yuck content
  combinedYuck = lib.concatStringsSep "\n\n" (map (w: w.yuck) widgets);

  # Merge all scss content
  combinedScss = lib.concatStringsSep "\n\n" (map (w: w.scss) widgets);

  # Merge all scripts
  combinedScripts = lib.foldl' (acc: w: acc // w.scripts) {} widgets;

  # Base styles shared across all widgets
  baseScss = ''
    * {
      all: unset;
      font-family: "JetBrainsMono Nerd Font", "Font Awesome 6 Free", monospace;
      font-size: 13px;
    }

    .section-label {
      font-size: 0.9rem;
      font-weight: bold;
      color: rgba(0, 0, 0, 0.5);
      margin-bottom: 2px;
    }
  '';

  # Generate script file entries
  scriptFiles = lib.mapAttrs' (name: value: {
    name = ".config/eww/scripts/${name}";
    value = value;
  }) combinedScripts;
in {
  # Combine all home.file entries
  home.file = {
    # EWW widget definitions (yuck)
    ".config/eww/eww.yuck".text = combinedYuck;

    # Styles (scss)
    ".config/eww/eww.scss".text = ''
      ${baseScss}

      ${combinedScss}
    '';
  } // scriptFiles;
}
