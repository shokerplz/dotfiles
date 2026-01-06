# Screenshot and recording scripts
{pkgs}: {
  screenshot = pkgs.writeShellScript "screenshot-menu" ''
    #!/usr/bin/env bash
    export PATH="$PATH:/run/current-system/sw/bin:$HOME/.nix-profile/bin"

    # Ensure directories exist
    mkdir -p "$HOME/Pictures/Screenshots"
    mkdir -p "$HOME/Videos/Recordings"

    # Check if recording is active (gpu-screen-recorder is the full process name)
    if pgrep -f "gpu-screen-recorder" > /dev/null; then
      # Stop recording by sending SIGINT
      pkill -SIGINT -f "gpu-screen-recorder"
      notify-send "Recording Stopped" "Video saved to ~/Videos/Recordings"
      exit 0
    fi

    # Menu options
    options="󰹑  Full Screen
󰩭  Region/Window
󰑊  Record (select source)"

    # Show menu
    selected=$(echo -e "$options" | wofi --dmenu --prompt "Screenshot" --width 300 --height 160 --cache-file /dev/null)

    # Get timestamp for filenames
    timestamp=$(date +%Y%m%d_%H%M%S)

    case "$selected" in
      "󰹑  Full Screen")
        grimblast --notify copysave screen "$HOME/Pictures/Screenshots/$timestamp.png"
        ;;
      "󰩭  Region/Window")
        # Single click on window = capture window, drag = capture region
        grimblast --notify copysave area "$HOME/Pictures/Screenshots/$timestamp.png"
        ;;
      "󰑊  Record (select source)")
        # Portal handles screen/window/region selection with proper permissions
        notify-send "Recording" "Select what to record in the dialog"
        gpu-screen-recorder -w portal -f 60 -a default_output -o "$HOME/Videos/Recordings/$timestamp.mp4" &
        disown
        sleep 1
        if pgrep -f "gpu-screen-recorder" > /dev/null; then
          notify-send "Recording Started" "Press PrintScreen to stop"
        fi
        ;;
    esac
  '';
}
