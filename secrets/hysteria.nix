{config, ...}: let
  hysteriaSecretFile = ./hysteria.yaml;
in {
  sops = {
    secrets = {
      hysteriaPassword = {
        sopsFile = hysteriaSecretFile;
        key = "password";
      };
    };
    templates = {
      "hysteria_config.yaml" = {
        content = ''
          listen: 10.0.1.99:30003
          tls:
            cert: /var/lib/acme/hst.ikovalev.nl/fullchain.pem
            key: /var/lib/acme/hst.ikovalev.nl/key.pem
          auth:
            type: password
            password: ${builtins.toJSON config.sops.placeholder.hysteriaPassword}
        '';
        owner = "hysteria";
        group = "hysteria";
        mode = "0400";
      };
    };
  };
}
