{
  pkgs,
  config,
  ...
}: {
  networking.nat.enable = true;
  networking.nat = {
    externalInterface = "enp14s0";
    internalInterfaces = ["enp13s0"];
    internalIPs = ["10.0.100.0/24"];
  };
  networking.interfaces.enp13s0.ipv4.addresses = [
    {
      address = "10.0.100.1";
      prefixLength = 24;
    }
  ];
}
