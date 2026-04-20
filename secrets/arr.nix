{config, ...}: let
  arrSecretFile = ./arr.yaml;
in {
  sops.secrets.sonarrApiKey = {
    sopsFile = arrSecretFile;
  };

  sops.secrets.radarrApiKey = {
    sopsFile = arrSecretFile;
  };

  sops.templates.sonarr_env = {
    content = ''
      SONARR__AUTH__APIKEY="${config.sops.placeholder.sonarrApiKey}"
    '';
  };

  sops.templates.radarr_env = {
    content = ''
      RADARR__AUTH__APIKEY="${config.sops.placeholder.radarrApiKey}"
    '';
  };
}
