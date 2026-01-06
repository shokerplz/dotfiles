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
        font-family: "SF Pro Display", "Helvetica Neue", "JetBrainsMono Nerd Font", sans-serif;
        font-size: 14px;
      }

      window {
        background-color: rgba(30, 30, 30, 0.95);
        border-radius: 12px;
        border: 1px solid rgba(255, 255, 255, 0.1);
      }

      #input {
        background-color: rgba(255, 255, 255, 0.1);
        border: none;
        border-radius: 8px;
        margin: 12px;
        padding: 12px 16px;
        color: #ffffff;
        font-size: 18px;
      }

      #input:focus {
        outline: none;
        box-shadow: none;
      }

      #inner-box {
        margin: 0 12px 12px 12px;
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
        padding: 10px 12px;
        margin: 2px 0;
        border-radius: 8px;
        color: #ffffff;
      }

      #entry:selected {
        background-color: rgba(0, 122, 255, 0.8);
      }

      #entry:hover {
        background-color: rgba(255, 255, 255, 0.1);
      }

      #text {
        margin-left: 8px;
        color: #ffffff;
      }

      #img {
        margin-right: 4px;
      }
    '';
  };
}
