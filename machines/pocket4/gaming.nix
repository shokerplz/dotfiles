{ config, pkgs, ... }:

{
  programs.steam.gamescopeSession.args = [
    "-h 720"
    "-H 1080"
    "-F fsr"
    "-f"
  ];
}
