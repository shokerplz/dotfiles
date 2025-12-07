{
  config,
  pkgs,
  ...
}: {
  sops.secrets.nix_cache_private_key = {
    sopsFile = ./nix-cache.yaml;
    key = "private_key";
    owner = "nix-local-cache";
    group = "nix-local-cache";
  };
}
