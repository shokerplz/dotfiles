{ ... }:

{

  services.n8n = {
    enable = true;
    settings = {
      host = "0.0.0.0";
      port = 5678;
    };
    webhookUrl = "https://n8n.ikovalev.nl/";
  };

  networking.firewall.extraCommands = ''
    iptables -A nixos-fw -p tcp --dport 5678 -s 10.0.0.0/16 -j nixos-fw-accept
  '';
  networking.firewall.extraStopCommands = ''
    iptables -D nixos-fw -p tcp --dport 5678 -s 10.0.0.0/16 -j nixos-fw-accept || true
  '';

}
