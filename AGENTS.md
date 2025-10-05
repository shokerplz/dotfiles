# Repository Guidelines

## Project Structure & Module Organization
- `modules/` hosts reusable Nix modules for services and roles.
- `machines/` defines host entrypoints that compose modules and secrets.
- `common/` collects shared profiles (desktop, gui, docker, etc.).
- `packages/` contains overlays and custom derivations used across hosts.
- `services/`, `users/`, and `secrets/` hold specialized configs; keep encrypted data in `secrets/` managed by sops.

## Build, Test, and Development Commands
- `nix develop` enters the flake dev shell with formatting and deployment tooling.
- `nix flake show` lists available machines, modules, and package outputs.
- `nix flake check` validates flake metadata, lint hooks, and evaluations.
- `nix build .#HOSTNAME` performs a dry-run build for a target host before deployment.
- `NIX_SSHOPTS="-A" nixos-rebuild switch --flake .#HOSTNAME --target-host user@host` deploys to a remote machine; adjust placeholders per host.

## Coding Style & Naming Conventions
- Format Nix code with `nixfmt` (RFC style) prior to commits.
- Use two-space indentation, lowercase attribute names, and hyphenated filenames (e.g., `cloudflare-ddns.nix`).
- Organize modules with imports first, followed by options and service definitions.
- Name secrets descriptively (`cloudflare_api_token`, not `token`), matching usage in modules.

## Testing Guidelines
- Run `nix flake check` after modifying modules, packages, or overlays.
- For host-specific updates, evaluate with `nix eval .#HOSTNAME.config.system.build.toplevel` to confirm builds succeed.
- When changing overlays, build impacted packages locally via `nix build .#packages.x86_64-linux.<name>`.

## Commit & Pull Request Guidelines
- Write imperative, present-tense commit subjects under ~60 characters (e.g., `Add matrix client`).
- Reference affected machines or modules in commit bodies for traceability.
- PRs should outline scope, impacted hosts, manual verification steps, and any screenshots/log excerpts.
- Link related issues or deployment tickets and note required secret updates explicitly.

## Secrets & Security Notes
- Manage encrypted values with `sops`; keep age keys in `~/.config/sops/age/keys.txt`.
- After adding hosts, update `.sops.yaml` and execute `sops updatekeys` on relevant secret files.
- Never commit decrypted secrets or temporary plaintext outputs; remove local copies after verification.
