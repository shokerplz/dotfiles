{ config, pkgs, ... }:

{
  programs.steam.gamescopeSession.enable = true;
  programs.steam.gamescopeSession.args = [
    "-w 1680"
    "-h 1050"
    "-W 2560"
    "-H 1600"
    "-F fsr"
    "-f"
    "-e"
  ];
}
