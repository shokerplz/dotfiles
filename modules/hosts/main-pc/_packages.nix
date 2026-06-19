{
  pkgs,
  pkgs-unstable,
  pkgs-current,
  ...
}: {
  environment.systemPackages = [
    pkgs-current.neovim
    pkgs-current.git
    pkgs-current.wl-clipboard
    pkgs-current.appimage-run
    pkgs-current.gnome-randr
    pkgs-current.sunshine
    pkgs-current.libxtst
    pkgs-current.libxi
    pkgs-current.alacritty
    pkgs-current.solaar
    pkgs-current.libnotify
    pkgs-current.adwaita-icon-theme
    pkgs-unstable.ddgr
    pkgs-current.vagrant
    pkgs-current.devenv
    (pkgs-current.python3.withPackages (python-pkgs:
      with python-pkgs; [
        requests
        uv
      ]))
    pkgs-current.nodejs
    pkgs-current.bun
    pkgs-current.uv
    pkgs-current.gdb
  ];

  # That will allow apps to have LD_LIBRARY_PATH
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc.lib
  ];
}
