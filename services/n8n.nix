{ ... }:

{

  services.n8n = {
    enable = true;
    environment = {
      N8N_HOST = "0.0.0.0";
      N8N_PORT = "5678";
      WEBHOOK_URL = "https://n8n.ikovalev.nl/";
    };
  };

  networking.firewall.extraCommands = ''
    iptables -A nixos-fw -p tcp --dport 5678 -s 10.0.0.0/16 -j nixos-fw-accept
  '';
  networking.firewall.extraStopCommands = ''
    iptables -D nixos-fw -p tcp --dport 5678 -s 10.0.0.0/16 -j nixos-fw-accept || true
  '';

}
