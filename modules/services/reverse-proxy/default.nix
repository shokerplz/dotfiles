{
  self,
  ...
}: {
  flake.nixosModules.serviceReverseProxy = {
    config,
    lib,
    ...
  }: let
    cfg = config.dotfiles.services.reverseProxy;
  in {
    imports = [
      ../../../secrets/cloudflare.nix
      self.nixosModules.reverseProxySiteBuilder
      self.nixosModules.reverseProxySiteFiles
      self.nixosModules.reverseProxySiteGit
      self.nixosModules.reverseProxySiteHomeAssistant
      self.nixosModules.reverseProxySiteJobs
      self.nixosModules.reverseProxySiteKino
      self.nixosModules.reverseProxySiteMonitoring
      self.nixosModules.reverseProxySiteMusic
      self.nixosModules.reverseProxySiteN8N
      self.nixosModules.reverseProxySiteNixCache
      self.nixosModules.reverseProxySiteSearxNG
    ];

    options.dotfiles.services.reverseProxy.enable = lib.mkEnableOption "edge nginx reverse proxy";

    config = lib.mkIf cfg.enable {
      environment.etc."myacme/cloudflare".text = ''
        CLOUDFLARE_DNS_API_TOKEN_FILE="${config.sops.secrets.cloudflare_api_token.path}"
      '';

      security.acme = {
        acceptTerms = true;
        defaults = {
          dnsProvider = "cloudflare";
          extraLegoFlags = [
            "--dns.propagation-wait"
            "120s"
          ];
          dnsResolver = "8.8.8.8:53";
          environmentFile = "/etc/myacme/cloudflare";
          email = "ivan@ikovalev.nl";
        };
      };

      services.logrotate.settings.nginx.rotate = 5;

      services.nginx = {
        enable = true;
        resolver = {
          addresses = ["10.0.1.1"];
          ipv6 = false;
        };
        recommendedProxySettings = true;
        recommendedTlsSettings = true;
        commonHttpConfig = let
          realIpsFromList = lib.strings.concatMapStringsSep "\n" (x: "set_real_ip_from  ${x};");
          fileToList = x: lib.strings.splitString "\n" (builtins.readFile x);
          cfipv4 = fileToList (builtins.fetchurl {
            url = "https://www.cloudflare.com/ips-v4";
            sha256 = "sha256-8Cxtg7wBqwroV3Fg4DbXAMdFU1m84FTfiE5dfZ5Onns=";
          });
          cfipv6 = fileToList (builtins.fetchurl {
            url = "https://www.cloudflare.com/ips-v6";
            sha256 = "sha256-np054+g7rQDE3sr9U8Y/piAp89ldto3pN9K+KCNMoKk=";
          });
        in ''
          ${realIpsFromList cfipv4}
          ${realIpsFromList cfipv6}
          real_ip_header CF-Connecting-IP;
          sendfile            on;
          tcp_nopush          on;
          tcp_nodelay         on;
          keepalive_timeout   65;
        '';
      };
    };
  };
}
