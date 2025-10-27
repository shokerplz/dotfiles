# Claude Code Router Setup

This configuration sets up `claude-code-router` as a systemd service on the main-pc machine. The router acts as a proxy that routes Claude API requests through OpenRouter.

## What was configured

1. **Service Definition** (`services/claude-code-router.nix`):
   - Systemd service that runs claude-code-router
   - Uses OpenRouter as the provider
   - Defaults to using `anthropic/claude-3.5-sonnet` model
   - Listens on port 8787 by default

2. **Machine Configuration** (`machines/main-pc/claude-code-router.nix`):
   - Enables the service on main-pc
   - Connects to the existing OpenRouter API key from sops

3. **Secrets** (`secrets/main-pc.nix`):
   - Reuses the existing `openrouter_key` from homemanager.yaml
   - Makes it available to the claude-router system user

## How to use

### Deploy the configuration

1. Build and test locally:
   ```bash
   nix build .#main-pc
   ```

2. Deploy to main-pc:
   ```bash
   sudo nixos-rebuild switch --flake .#main-pc
   ```

### Using the router

Once deployed, the claude-code-router service will be running on `localhost:8787`. You can configure your applications to use this endpoint:

```bash
export ANTHROPIC_API_URL="http://localhost:8787"
export ANTHROPIC_API_KEY="your-openrouter-key"  # Uses the key from sops
```

For the Codex CLI (which you already have installed), you can configure it to use the router:

```bash
codex config set api.base-url http://localhost:8787
```

### Check service status

```bash
sudo systemctl status claude-code-router
sudo journalctl -u claude-code-router -f  # Follow logs
```

### Configuration options

You can customize the service in `machines/main-pc/claude-code-router.nix`:

- `port`: Change the listening port (default: 8787)
- `model`: Change the model (default: "anthropic/claude-3.5-sonnet")
- Other available OpenRouter models:
  - `anthropic/claude-3-opus`
  - `anthropic/claude-3-haiku`
  - `anthropic/claude-2.1`
  - See https://openrouter.ai/docs for full list

## Troubleshooting

### Service fails to start

Check that the OpenRouter API key is correctly configured:
```bash
sudo cat /run/secrets/openrouter_key
```

### Connection refused

Verify the service is running and listening:
```bash
sudo systemctl status claude-code-router
sudo ss -tlnp | grep 8787
```

### Check logs for errors

```bash
sudo journalctl -u claude-code-router --no-pager -n 50
```
