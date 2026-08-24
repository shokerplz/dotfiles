{ ... }:
{
  flake.nixosModules.serviceSlskd =
    { config, ... }:
    let
      musicBaseDir = "/mnt/zfs-pool0/music";
      musicDataDir = "${musicBaseDir}/data";
      slskdDir = "${musicBaseDir}/slskd";
      slskdDownloadsDir = "${slskdDir}/downloads";
      slskdIncompleteDir = "${slskdDir}/incomplete";
      listenPort = 50300;
    in
    {
      imports = [
        ../../secrets/music.nix
      ];

      services.slskd = {
        enable = true;

        environmentFile = config.sops.templates.slskd_env.path;

        settings = {
          web.port = 5030;
          soulseek.listen_port = listenPort;
          shares.directories = [ musicDataDir ];
          directories = {
            downloads = slskdDownloadsDir;
            incomplete = slskdIncompleteDir;
          };
        };
      };

      sops.templates.slskd_env.restartUnits = [ "slskd.service" ];

      systemd.services.slskd.serviceConfig.UMask = "0002";

      # listen_port sits inside net.ipv4.ip_local_port_range, so without this an
      # ephemeral outbound socket can steal it before slskd binds.
      boot.kernel.sysctl."net.ipv4.ip_local_reserved_ports" = toString listenPort;

      systemd.tmpfiles.rules = [
        "d ${musicDataDir} 2775 root arr -"
        "d ${slskdDir} 2775 slskd arr -"
        "d ${slskdDownloadsDir} 2775 slskd arr -"
        "d ${slskdIncompleteDir} 2775 slskd arr -"
      ];

      networking.firewall.extraCommands = ''
        iptables -A nixos-fw -p tcp --dport 5030 -s 10.0.0.0/16 -j nixos-fw-accept
        iptables -A nixos-fw -p tcp --dport ${toString listenPort} -j nixos-fw-accept
      '';

      networking.firewall.extraStopCommands = ''
        iptables -D nixos-fw -p tcp --dport 5030 -s 10.0.0.0/16 -j nixos-fw-accept || true
        iptables -D nixos-fw -p tcp --dport ${toString listenPort} -j nixos-fw-accept || true
      '';
    };
}
