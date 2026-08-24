{config, ...}: let
  musicSecretFile = ./music.yaml;
  slskdDownloadsDir = "/mnt/zfs-pool0/music/slskd/downloads";
in {
  sops.secrets.soulseek_username = {
    sopsFile = musicSecretFile;
  };

  sops.secrets.soulseek_password = {
    sopsFile = musicSecretFile;
  };

  sops.secrets.slskd_web_username = {
    sopsFile = musicSecretFile;
  };

  sops.secrets.slskd_web_password = {
    sopsFile = musicSecretFile;
  };

  sops.secrets.slskd_api_key = {
    sopsFile = musicSecretFile;
  };

  sops.templates.slskd_env = {
    content = ''
      SLSKD_SLSK_USERNAME="${config.sops.placeholder.soulseek_username}"
      SLSKD_SLSK_PASSWORD="${config.sops.placeholder.soulseek_password}"
      SLSKD_USERNAME="${config.sops.placeholder.slskd_web_username}"
      SLSKD_PASSWORD="${config.sops.placeholder.slskd_web_password}"
      SLSKD_API_KEY="${config.sops.placeholder.slskd_api_key}"
    '';
  };

  sops.templates.soularr_config = {
    owner = "ikovalev";
    mode = "0400";
    content = ''
      [Slskd]
      api_key = ${config.sops.placeholder.slskd_api_key}
      host_url = http://localhost:5030
      download_dir = ${slskdDownloadsDir}
    '';
  };
}
