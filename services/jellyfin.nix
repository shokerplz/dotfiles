{ config, pkgs, ... }:

{
	# Jellyfin service
  services.jellyfin = {
		enable = true;
		user = "jellyfin";
    dataDir = "/mnt/zfs-pool0/kino/jellyfin";
    configDir = "/mnt/zfs-pool0/kino/jellyfin/config";
    cacheDir = "/mnt/zfs-pool0/kino/jellyfin/cache";
	};

  system.activationScripts.createJellyfinDir =
    ''
			mkdir -p /mnt/zfs-pool0/kino/data
			mkdir -p /mnt/zfs-pool0/kino/jellyfin/config
			mkdir -p /mnt/zfs-pool0/kino/jellyfin/cache
      chown -R jellyfin /mnt/zfs-pool0/kino/data
			chown -R jellyfin:jellyfin /mnt/zfs-pool0/kino/jellyfin
    '';

  # Add user to render and video group for hw transcoding
  users.users.jellyfin.extraGroups = [
    "video"
    "render"
  ];

	# This is needed for skipper plugin
  nixpkgs.overlays = with pkgs; [
    (
      final: prev:
        {
          jellyfin-web = prev.jellyfin-web.overrideAttrs (finalAttrs: previousAttrs: {
            installPhase = ''
              runHook preInstall

              # this is the important line
              sed -i "s#</head>#<script src=\"configurationpage?name=skip-intro-button.js\"></script></head>#" dist/index.html

              mkdir -p $out/share
              cp -a dist $out/share/jellyfin-web

              runHook postInstall
            '';
          });
        }
    )
  ];

	# Install necessary packages for Jellyfin
  environment.systemPackages = [
    pkgs.jellyfin
    pkgs.jellyfin-web
    pkgs.jellyfin-ffmpeg
  ];

  # Jellyfin firewall
  networking.firewall.extraCommands = ''
    iptables -A nixos-fw -p tcp --dport 8096 -s 10.0.0.0/16 -j nixos-fw-accept
  '';
  networking.firewall.extraStopCommands = ''
    iptables -D nixos-fw -p tcp --dport 8096 -s 10.0.0.0/16 -j nixos-fw-accept || true
  '';


}
