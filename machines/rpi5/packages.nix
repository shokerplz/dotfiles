{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    cloudflare-ddns
    git
  ];
}
