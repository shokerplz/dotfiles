{
  config,
  pkgs,
  ...
}: {
  systemd.user.services.solaar = {
    Unit = {
      Description = "Solaar Logitech Receiver Daemon";
      After = ["graphical-session.target"];
    };
    Service = {
      ExecStart = "${pkgs.solaar}/bin/solaar -w hide";
      Restart = "on-failure";
    };
    Install = {
      WantedBy = ["default.target"];
    };
  };
}
