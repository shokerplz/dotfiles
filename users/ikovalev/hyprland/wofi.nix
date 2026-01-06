# Wofi and Rofi launcher configuration
{pkgs, ...}: {
  programs.rofi = {
    enable = true;
    package = pkgs.rofi;
    theme = "solarized";
  };

  programs.wofi = {
    enable = true;
    settings = {
      width = 600;
      height = 400;
      location = "center";
      show = "drun";
      prompt = "Search...";
      filter_rate = 100;
      allow_markup = true;
      no_actions = true;
      halign = "fill";
      orientation = "vertical";
      content_halign = "fill";
      insensitive = true;
      allow_images = true;
      image_size = 24;
      columns = 1;
    };

    style = ''
      * {
        font-family: "JetBrainsMono Nerd Font", "Font Awesome 6 Free", monospace;
        font-size: 13px;
      }

      window {
        background-color: rgba(135, 135, 135, 1);
        border-radius: 0.9rem;
        border: none;
      }

      #input {
        background-color: rgba(0, 0, 0, 0.06);
        border: none;
        border-radius: 0.6rem;
        margin: 10px;
        padding: 10px 14px;
        color: #000000;
        font-size: 14px;
      }

      #input:focus {
        outline: none;
        box-shadow: none;
      }

      #inner-box {
        margin: 0 10px 10px 10px;
      }

      #outer-box {
        margin: 0;
        padding: 0;
      }

      #scroll {
        margin: 0;
        padding: 0;
      }

      #entry {
        padding: 8px 12px;
        margin: 2px 0;
        border-radius: 4px;
        color: rgba(0, 0, 0, 0.8);
      }

      #entry:selected {
        background-color: rgba(0, 0, 0, 0.15);
        color: #000000;
      }

      #entry:hover {
        background-color: rgba(0, 0, 0, 0.1);
      }

      #text {
        margin-left: 8px;
        color: rgba(0, 0, 0, 0.9);
      }

      #img {
        margin-right: 4px;
      }
    '';
  };
}
