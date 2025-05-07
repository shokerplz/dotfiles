{ pkgs, ... }:

{
  # Default packages that should be installed everywhere
  environment.systemPackages = with pkgs; [
    neovim
    wget
    tcpdump
    htop
    curl
    acpi
    smartmontools
    dig
    inetutils
    lshw
    pciutils
    iotop
    lsof
    jq
    btop
    dmidecode
  ];
}
