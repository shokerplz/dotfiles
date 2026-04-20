{pkgs, ...}: {
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
    file
    xxd
    usbutils
    home-manager
  ];
}
