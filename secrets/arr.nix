{config, ...}: let
  arrSecretFile = ./arr.yaml;
in {
  sops = {
    secrets = {
      sonarrApiKey = {
        sopsFile = arrSecretFile;
      };
      radarrApiKey = {
        sopsFile = arrSecretFile;
      };
    };
    templates = {
      "sonarr_env" = {
        content = ''
          SONARR__AUTH__APIKEY="${config.sops.placeholder.sonarrApiKey}"
        '';
      };
      "radarr_env" = {
        content = ''
          RADARR__AUTH__APIKEY="${config.sops.placeholder.radarrApiKey}"
        '';
      };
    };
  };
}
