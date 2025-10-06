{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (import ../lib {inherit lib;}) customPackages;
  pkgSelector = customPackages.mkSelector {inherit pkgs;};
in {
  # Default packages that should be installed everywhere
  environment.systemPackages = pkgSelector.resolveList [
    "neovim"
    "wget"
    "tcpdump"
    "htop"
    "curl"
    "acpi"
    "smartmontools"
    "dig"
    "inetutils"
    "lshw"
    "pciutils"
    "iotop"
    "lsof"
    "jq"
    "btop"
    "dmidecode"
    "file"
  ];
}
