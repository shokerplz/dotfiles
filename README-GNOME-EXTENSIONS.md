# Auto-Enable GNOME Extensions

This branch implements automatic enabling of GNOME Shell extensions via home-manager.

## Changes Made

### `users/ikovalev/home.nix`
- Added `lib` to function parameters
- Added `dconf.settings` block to auto-enable installed extensions
- Configured dash-to-dock to appear at the bottom

### `docs/gnome-extensions-guide.md`
- Created documentation for managing GNOME extensions
- Instructions for finding extension UUIDs
- Troubleshooting guide

## Important: Verify Extension UUIDs

The extension UUIDs in `home.nix` are based on common patterns, but **you must verify them** after deploying:

1. Deploy the configuration:
   ```bash
   nixos-rebuild switch --flake .#HOSTNAME
   ```

2. Find the actual UUIDs:
   ```bash
   ls /run/current-system/sw/share/gnome-shell/extensions/
   ```

3. Update `users/ikovalev/home.nix` with correct UUIDs if needed

4. Redeploy to apply corrections

## Extensions Configured

- dash-to-dock
- appindicator (system tray)
- clipboard-history
- system-monitor
- easyeffects-preset-selector
- notification-timeout
- window-is-ready-remover
- gsconnect (KDE Connect)

## Testing

After deployment:
1. Log out and log back in
2. Open Extensions app (`gnome-extensions-app`)
3. Verify all extensions are enabled
4. If not, check the UUIDs match what's in `/run/current-system/sw/share/gnome-shell/extensions/`

## Alternative: Query Nixpkgs

You can also check extension metadata from nixpkgs source to find correct UUIDs before deployment.
