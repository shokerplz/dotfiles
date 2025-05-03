{ config, pkgs, ... }:

{
  # This is a hack - service that plays inaudible sound to start pipewire and wireplumber
  systemd.user.services.hdmiKeepAlive = {
    description = "Keep DisplayPort / HDMI audio clock alive";
    wantedBy    = [ "default.target" ];   # enabled for every login

    serviceConfig = {
      ExecStart = "${pkgs.sox}/bin/play -q -n -c2 synth 0.9 sine 40 gain -160";
      Restart   = "always";
      Nice      = 19;
    };
  };
}
