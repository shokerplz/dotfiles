{...}: {
  flake.nixosModules.serviceJellyfin = {
    pkgs-unstable,
    ...
  }: let
    jellyfinTranscodeDir = "/mnt/ssd/kino/jellyfin/transcodes";
    jellyfinPkgs = pkgs-unstable.extend (final: prev: {
      jellyfin-web = prev.jellyfin-web.overrideAttrs (_finalAttrs: _previousAttrs: {
        installPhase = ''
          runHook preInstall

          sed -i "s#</head>#<script src=\"configurationpage?name=skip-intro-button.js\"></script></head>#" dist/index.html

          mkdir -p $out/share
          cp -a dist $out/share/jellyfin-web

          runHook postInstall
        '';
      });
    });
  in {
    services.jellyfin = {
      enable = true;
      user = "jellyfin";
      package = jellyfinPkgs.jellyfin;
      dataDir = "/mnt/zfs-pool0/kino/jellyfin";
      configDir = "/mnt/zfs-pool0/kino/jellyfin/config";
      cacheDir = "/mnt/zfs-pool0/kino/jellyfin/cache";
    };

    system.activationScripts.createJellyfinDir = ''
      mkdir -p /mnt/zfs-pool0/kino/data
      mkdir -p /mnt/zfs-pool0/kino/jellyfin/config
      mkdir -p /mnt/zfs-pool0/kino/jellyfin/cache
      mkdir -p ${jellyfinTranscodeDir}
      chown -R jellyfin /mnt/zfs-pool0/kino/data
      chown -R jellyfin:jellyfin /mnt/zfs-pool0/kino/jellyfin
      chown -R jellyfin:jellyfin ${jellyfinTranscodeDir}
    '';

    systemd.services.jellyfin.preStart = ''
      if [ -f /mnt/zfs-pool0/kino/jellyfin/config/encoding.xml ]; then
        sed -i 's#<TranscodingTempPath>.*</TranscodingTempPath>#<TranscodingTempPath>${jellyfinTranscodeDir}</TranscodingTempPath>#' /mnt/zfs-pool0/kino/jellyfin/config/encoding.xml
      fi
    '';

    users.users.jellyfin.extraGroups = [
      "video"
      "render"
    ];

    environment.systemPackages = [
      jellyfinPkgs.jellyfin-web
      jellyfinPkgs.jellyfin-ffmpeg
    ];

    networking.firewall.extraCommands = ''
      iptables -A nixos-fw -p tcp --dport 8096 -s 10.0.0.0/16 -j nixos-fw-accept
    '';

    networking.firewall.extraStopCommands = ''
      iptables -D nixos-fw -p tcp --dport 8096 -s 10.0.0.0/16 -j nixos-fw-accept || true
    '';
  };
}
