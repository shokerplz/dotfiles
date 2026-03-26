{
  config,
  pkgs,
  ...
}: {
  services.rustdesk-server = {
    enable = true;
    signal.enable = true;
    relay.enable = true;
    signal.relayHosts = ["rustdesk.ikovalev.nl"];
  };

  networking.firewall.interfaces.end0 = {
    allowedTCPPorts = [21114 21115 21116 21117 21118 21119];
    allowedUDPPorts = [21116];
  };
}
