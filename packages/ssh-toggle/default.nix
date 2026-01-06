{
  lib,
  python3Packages,
  wrapGAppsHook3,
  gobject-introspection,
  libappindicator-gtk3,
  libnotify,
  gtk3,
}:

python3Packages.buildPythonApplication {
  pname = "ssh-toggle";
  version = "1.0.0";

  src = ./.;

  format = "other";

  nativeBuildInputs = [
    wrapGAppsHook3
    gobject-introspection
  ];

  buildInputs = [
    gtk3
    libappindicator-gtk3
    libnotify
  ];

  propagatedBuildInputs = with python3Packages; [
    pygobject3
  ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    mkdir -p $out/share/applications
    mkdir -p $out/share/icons/hicolor/scalable/apps

    cp ssh-toggle.py $out/bin/ssh-toggle
    chmod +x $out/bin/ssh-toggle

    cat > $out/share/applications/ssh-toggle.desktop << EOF
    [Desktop Entry]
    Name=SSH Toggle
    Comment=Enable SSH server while this app is running
    Exec=ssh-toggle
    Icon=network-server
    Terminal=false
    Type=Application
    Categories=System;Network;
    Keywords=ssh;server;remote;
    EOF

    runHook postInstall
  '';

  meta = with lib; {
    description = "System tray app to toggle SSH server";
    license = licenses.mit;
    platforms = platforms.linux;
    mainProgram = "ssh-toggle";
  };
}
