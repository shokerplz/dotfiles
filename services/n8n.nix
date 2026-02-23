{pkgs, lib, ...}: {
  services.n8n = {
    enable = true;
    environment = {
      N8N_HOST = "0.0.0.0";
      N8N_PORT = "5678";
      WEBHOOK_URL = "https://n8n.ikovalev.nl/";
      N8N_DIAGNOSTICS_ENABLED = "false";
      N8N_VERSION_NOTIFICATIONS_ENABLED = "false";
      N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS = "true";
      N8N_BLOCK_ENV_ACCESS_IN_NODE = "false";
      N8N_GIT_NODE_DISABLE_BARE_REPOS = "true";
      DB_SQLITE_POOL_SIZE = "2";
      N8N_NATIVE_PYTHON_RUNNER = lib.mkForce "false";
    };
  };
  systemd.services.n8n.path = [pkgs.python3 pkgs.bun pkgs.nodejs];

  networking.firewall.extraCommands = ''
    iptables -A nixos-fw -p tcp --dport 5678 -s 10.0.0.0/16 -j nixos-fw-accept
  '';
  networking.firewall.extraStopCommands = ''
    iptables -D nixos-fw -p tcp --dport 5678 -s 10.0.0.0/16 -j nixos-fw-accept || true
  '';
}
