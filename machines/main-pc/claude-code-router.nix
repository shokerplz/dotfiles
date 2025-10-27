{ config, ... }:
{
  imports = [
    ../../services/claude-code-router.nix
  ];

  services.claude-code-router = {
    enable = true;
    port = 8787;
    openrouterApiKeyFile = config.sops.secrets.openrouter_key.path;
    model = "anthropic/claude-3.5-sonnet";
  };
}
