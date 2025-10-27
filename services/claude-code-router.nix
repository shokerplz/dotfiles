{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.services.claude-code-router;
in
{
  options.services.claude-code-router = {
    enable = mkEnableOption "Claude Code Router service";

    port = mkOption {
      type = types.port;
      default = 8787;
      description = "Port for the Claude Code Router to listen on";
    };

    openrouterApiKeyFile = mkOption {
      type = types.str;
      description = "Path to file containing OpenRouter API key";
    };

    model = mkOption {
      type = types.str;
      default = "anthropic/claude-3.5-sonnet";
      description = "Model to use for routing requests";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.claude-code-router = {
      description = "Claude Code Router";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      serviceConfig = {
        Type = "simple";
        User = "claude-router";
        Group = "claude-router";
        Restart = "on-failure";
        RestartSec = "5s";

        LoadCredential = "openrouter-key:${cfg.openrouterApiKeyFile}";

        ExecStart = ''
          ${pkgs.bash}/bin/bash -c 'export OPENROUTER_API_KEY=$(cat $CREDENTIALS_DIRECTORY/openrouter-key) && \
            ${pkgs.nodejs}/bin/npx -y claude-code-router \
            --port ${toString cfg.port} \
            --provider openrouter \
            --model ${cfg.model}'
        '';
      };
    };

    users.users.claude-router = {
      isSystemUser = true;
      group = "claude-router";
      description = "Claude Code Router service user";
    };

    users.groups.claude-router = { };

    # Open firewall port
    networking.firewall.allowedTCPPorts = [ cfg.port ];
  };
}
