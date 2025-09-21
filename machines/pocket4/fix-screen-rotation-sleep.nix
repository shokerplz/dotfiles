{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    gnome-randr
  ];
  systemd.services.gnome-randr-wakeup = {
    description = "Run gnome-randr after waking up from sleep";
    wantedBy = ["sleep.target"];
    unitConfig = {
      After = "systemd-suspend.service systemd-hybrid-sleep.service systemd-hibernate.service";
    };
    serviceConfig = {
      Type = "oneshot";
      User = "ikovalev";
      Environment = [
        "DISPLAY=:0"
        "XDG_RUNTIME_DIR=/run/user/1000"
        "DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus"
      ];
      ExecStart = "${pkgs.gnome-randr}/bin/gnome-randr modify --primary -r normal eDP-1";
    };
  };
}
