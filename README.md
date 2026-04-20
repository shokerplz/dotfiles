# NixOS Setup

## Everyday Commands

Inspect the exported outputs:

```bash
nix flake show --all-systems --no-write-lock-file
```

Evaluate a host without building it:

```bash
nix eval .#nixosConfigurations.rpi5.config.system.build.toplevel.drvPath
```

Build a host:

```bash
nix build .#nixosConfigurations.rpi5.config.system.build.toplevel
```

Switch locally on the machine itself:

```bash
sudo nixos-rebuild switch --flake .#main-pc
```

Build locally and deploy remotely over SSH agent forwarding:

```bash
CONFIG=rpi5
SSH_HOST=ikovalev@rpi5.home

NIX_SSHOPTS="-A" nixos-rebuild switch -j auto --sudo --build-host localhost --target-host "$SSH_HOST" --flake ".#$CONFIG"
```

Use the flake attribute name for `CONFIG` and the actual SSH destination for
`SSH_HOST`.

Format all Nix files:

```bash
nix-shell -p nixfmt-rfc-style --run "nixfmt ."
```

## Adding A New Host

1. Create `modules/hosts/<name>/configuration.nix` and export
   `flake.nixosModules.<Something>Configuration`.
2. Create `modules/hosts/<name>/default.nix` and export
   `flake.nixosConfigurations.<name>` with `withSystem`.
3. Keep machine-local files next to it, for example
   `_hardware-configuration.nix`, `_packages.nix`, `_overlays.nix`, or
   `_disko.nix`.
4. Import shared modules from `self.nixosModules.*` inside the host config.
5. Build the host with
   `nix build .#nixosConfigurations.<name>.config.system.build.toplevel` before
   switching it.

## Secrets

Secrets are managed with `sops-nix`, which is imported by `commonDefault`.

Current setup:

- encrypted data lives in `secrets/*.yaml`
- matching `secrets/*.nix` files declare `sops.secrets` and `sops.templates`
- hosts decrypt with `/etc/ssh/ssh_host_ed25519_key`
- general secrets are shared with `rpi5`, `media-server`, `main-pc`, `pocket4`,
  and `ikovalev`
- Xray secrets are intentionally split so each relay host only gets the material
  it needs

Create a personal age key:

```bash
mkdir -p ~/.config/sops/age
age-keygen -o ~/.config/sops/age/keys.txt
```

Private key location:

```text
~/.config/sops/age/keys.txt
```

Create or edit a secret file:

```bash
nix-shell -p sops --run "sops secrets/newsecret.yaml"
```

### Adding A Secret To Nix Code

The pattern in this repository is to keep the encrypted file and its Nix wrapper
side by side.

Example from `secrets/cloudflare.nix`:

```nix
{ config, ... }: let
  cloudflareSecretFile = ./cloudflare.yaml;
in {
  sops.secrets.cloudflare_api_token = {
    sopsFile = cloudflareSecretFile;
    uid = 1000;
    group = "acme";
    mode = "440";
  };

  sops.templates.cloudflare-ddns_api_token = {
    content = ''
      CLOUDFLARE_API_TOKEN="${config.sops.placeholder.cloudflare_api_token}"
    '';
    owner = "cloudflare-ddns";
  };
}
```

Then import that wrapper from the module that needs it:

```nix
imports = [ ../../secrets/cloudflare.nix ];

services.cloudflare-ddns.credentialsFile =
  config.sops.templates.cloudflare-ddns_api_token.path;
```

Useful rule of thumb:

- use `config.sops.secrets.<name>.path` when a service can read a secret file
  directly
- use `sops.templates` when a service needs an env file or a rendered config
  file

### Adding A New Machine To SOPS

1. Get the host public key as an age key:

```bash
nix-shell -p ssh-to-age --run "ssh-keyscan new-machine.home | grep -i ed25519 | ssh-to-age"
```

2. Add it to `.sops.yaml` under `keys`, for example `- &new-machine age1...`.
3. Add `*new-machine` to the matching `creation_rules` entry.
4. Run `sops updatekeys secrets/needed-secret.yaml`.

### macOS SOPS Fix

If SOPS looks for the key here:

```text
/Users/admin/Library/Application Support/sops/age/keys.txt
```

create the compatibility symlink:

```bash
mkdir -p "/Users/admin/Library/Application Support/sops/age/"
ln -s ~/.config/sops/age/keys.txt "/Users/admin/Library/Application Support/sops/age/keys.txt"
```

## Reverse Proxy Notes

The reverse proxy is modeled as one service module plus per-site modules.

- base module: `modules/services/reverse-proxy/default.nix`
- site modules: `modules/services/reverse-proxy/sites/*.nix`
- host-facing options live under `dotfiles.services.reverseProxy.*`

## Xray Relay Hosts

Current design:

- native `services.xray` module
- native `services.haproxy` module
- secret-backed rendered config via `sops.templates`
- `disko` layout for fresh installs
- static networking encoded from the current VPS setup

Behavior notes:

- HAProxy listens on `:80` and `:443`
- xray itself only listens on `127.0.0.1:7443`
- logs go to journald
- relay secrets are split between `secrets/xray-role-entry.yaml` and
  `secrets/xray-role-exit.yaml`

### Install With nixos-anywhere-zram

This flake provides `nixos-anywhere-zram`, a wrapped `nixos-anywhere` that
enables zram before the install, which is useful on low-memory VPSes.

This command repartitions the target machine and replace the current OS:

```bash
nix run .#nixos-anywhere-zram -- --flake .#vm-0 --target-host user@target_ip --build-on remote --copy-host-keys
```

`--copy-host-keys` matters because these secrets are encrypted to the current
host SSH keys and `sops-nix` decrypts through `/etc/ssh/ssh_host_ed25519_key`.

### Remote Switch After Install

```bash
nixos-rebuild switch --flake .#vm-0 --target-host user@target_ip --sudo
```
