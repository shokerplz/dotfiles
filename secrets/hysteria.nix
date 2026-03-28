{config, ...}: let
  hysteriaSecretFile = ./hysteria.yaml;
in {
  sops = {
    secrets = {
      obfsPassword = {
        sopsFile = hysteriaSecretFile;
        key = "obfsPassword";
      };
      ivanPassword = {
        sopsFile = hysteriaSecretFile;
        key = "userPasswords/ivan";
      };
      chichaPassword = {
        sopsFile = hysteriaSecretFile;
        key = "userPasswords/chicha";
      };
      lenaPassword = {
        sopsFile = hysteriaSecretFile;
        key = "userPasswords/lena";
      };
      papaPassword = {
        sopsFile = hysteriaSecretFile;
        key = "userPasswords/papa";
      };
      mamaPassword = {
        sopsFile = hysteriaSecretFile;
        key = "userPasswords/mama";
      };
    };
    templates = {
      "hysteria_config.yaml" = {
        content = ''
          listen: 10.0.1.99:30003
          tls:
            cert: /var/lib/acme/hst.ikovalev.nl/fullchain.pem
            key: /var/lib/acme/hst.ikovalev.nl/key.pem
          acl:
            inline:
              - reject(10.0.0.0/8)
          auth:
            type: userpass
            userpass:
              ivan: ${builtins.toJSON config.sops.placeholder.ivanPassword}
              lena: ${builtins.toJSON config.sops.placeholder.lenaPassword}
              mama: ${builtins.toJSON config.sops.placeholder.mamaPassword}
              papa: ${builtins.toJSON config.sops.placeholder.papaPassword}
              chicha: ${builtins.toJSON config.sops.placeholder.chichaPassword}
          masquerade:
            type: proxy
            proxy:
              url: https://vk.com
              rewriteHost: true
          obfs:
            type: salamander
            salamander:
              password: ${builtins.toJSON config.sops.placeholder.obfsPassword}
          bandwidth:
            up: 25 mb
            down: 25 mb
          udpIdleTimeout: 45s
          resolver:
            type: udp
            udp:
              addr: 8.8.8.8:53
              timeout: 4s
        '';
        owner = "hysteria";
        group = "hysteria";
        mode = "0400";
      };
    };
  };
}
