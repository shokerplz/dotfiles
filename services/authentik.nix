{
  config,
  pkgs,
  ...
}: {
  imports = [
    ../secrets/authentik.nix
  ];
  services.authentik = {
    enable = true;
    environmentFile = config.sops.templates."authentik_env".path;
    settings = {
      email = {
        host = "smtp.eu.mailgun.org";
        port = 587;
        username = "auth@mail.ikovalev.nl";
        use_tls = true;
        use_ssl = false;
        from = "auth@mail.ikovalev.nl";
      };
      disable_startup_analytics = true;
      avatars = "initials";
    };
  };
}
