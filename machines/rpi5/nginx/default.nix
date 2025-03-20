{
  config,
  pkgs,
  lib,
  ...
}:

{

  imports = [
    ../../../secrets/cloudflare.nix
    ./files.nix
    ./kino.nix
    ./monitoring.nix
    ./git.nix
  ];

  # Creating directories for static websites
  system.activationScripts.createWebsites = ''
    mkdir -p /var/www/websites
    chmod 0755 /var/www/websites/
    mkdir -p /var/www/websites/kino.ikovalev.nl/
    chmod o+x /var/www/websites/kino.ikovalev.nl/assets/
    chmod 0644 -R /var/www/websites/kino.ikovalev.nl/*
    chown -R nginx:nginx /var/www/websites
  '';

  # Create an env file with CF credentials
  environment.etc = {
    "myacme/cloudflare" = {
      text = ''
        CLOUDFLARE_DNS_API_TOKEN_FILE="${config.sops.secrets.cloudflare_api_token.path}"
      '';
    };
  };

  # Setup ACME to provide certificates automatically
  security.acme = {
    acceptTerms = true;
    defaults = {
      dnsProvider = "cloudflare";
      environmentFile = "/etc/myacme/cloudflare";
      email = "ivan@ikovalev.nl";
    };
  };

  # Base nginx LB config
  services.nginx = {
    enable = true;
    resolver = {
      addresses = [ "10.0.1.1" ];
      ipv6 = false;
    };
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    commonHttpConfig =
      let
        realIpsFromList = lib.strings.concatMapStringsSep "\n" (x: "set_real_ip_from  ${x};");
        fileToList = x: lib.strings.splitString "\n" (builtins.readFile x);
        cfipv4 = fileToList (
          pkgs.fetchurl {
            url = "https://www.cloudflare.com/ips-v4";
            hash = "sha256-8Cxtg7wBqwroV3Fg4DbXAMdFU1m84FTfiE5dfZ5Onns=";
          }
        );
        cfipv6 = fileToList (
          pkgs.fetchurl {
            url = "https://www.cloudflare.com/ips-v6";
            hash = "sha256-np054+g7rQDE3sr9U8Y/piAp89ldto3pN9K+KCNMoKk=";
          }
        );
      in
      ''
        ${realIpsFromList cfipv4}
        ${realIpsFromList cfipv6}
        real_ip_header CF-Connecting-IP;
        sendfile            on;
        tcp_nopush          on;
        tcp_nodelay         on;
        keepalive_timeout   65;
      '';
  };
}
