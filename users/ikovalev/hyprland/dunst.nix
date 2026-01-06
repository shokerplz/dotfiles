# Dunst notification daemon configuration
{...}: {
  services.dunst = {
    enable = true;
    settings = {
      global = {
        # Geometry
        width = "(280, 400)";
        height = "(0, 300)";
        offset = "20x40";
        origin = "top-right";
        notification_limit = 5;
        gap_size = 8;

        # Appearance - macOS-inspired with your color scheme
        font = "JetBrainsMono Nerd Font 10";
        frame_width = 1;
        frame_color = "#a0a0a0";
        corner_radius = 14;
        transparency = 10;
        padding = 16;
        horizontal_padding = 16;
        text_icon_padding = 16;
        separator_height = 1;
        separator_color = "#a0a0a0";

        # Text formatting
        markup = "full";
        format = "<b>%s</b>\\n%b";
        alignment = "left";
        vertical_alignment = "center";
        word_wrap = true;
        ellipsize = "end";
        line_height = 4;

        # Progress bar (for volume/brightness)
        progress_bar = true;
        progress_bar_height = 6;
        progress_bar_frame_width = 0;
        progress_bar_corner_radius = 3;
        progress_bar_min_width = 200;
        progress_bar_max_width = 360;

        # Icons
        icon_position = "left";
        min_icon_size = 48;
        max_icon_size = 64;
        icon_corner_radius = 8;

        # Behavior
        sort = "yes";
        indicate_hidden = "yes";
        stack_duplicates = true;
        hide_duplicate_count = false;
        show_indicators = "no";
        sticky_history = "yes";

        # Mouse actions - left click triggers action then closes (for Telegram etc.)
        mouse_left_click = "do_action, close_current";
        mouse_middle_click = "close_current";
        mouse_right_click = "close_all";
      };

      urgency_low = {
        background = "#8a8a8a";
        foreground = "#1a1a1a";
        highlight = "#4a4a4a";
        frame_color = "#9a9a9a";
        timeout = 5;
      };

      urgency_normal = {
        background = "#8a8a8a";
        foreground = "#1a1a1a";
        highlight = "#4a4a4a";
        frame_color = "#9a9a9a";
        timeout = 8;
      };

      urgency_critical = {
        background = "#c62828";
        foreground = "#ffffff";
        highlight = "#ff5252";
        frame_color = "#b71c1c";
        timeout = 0;
      };
    };
  };
}
