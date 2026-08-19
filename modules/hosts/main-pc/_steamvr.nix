{pkgs, ...}: let
  launcher = "/home/ikovalev/.local/share/Steam/steamapps/common/SteamVR/bin/linux64/vrcompositor-launcher";
in {
  systemd.services.steamvr-cap-sys-nice = {
    description = "Grant SteamVR compositor realtime scheduling capability";
    wantedBy = ["multi-user.target"];
    script = ''
      if [[ -f "${launcher}" && ! -L "${launcher}" ]] \
        && [[ "$(${pkgs.libcap}/bin/getcap "${launcher}")" != *cap_sys_nice* ]]; then
        ${pkgs.libcap}/bin/setcap cap_sys_nice=eip "${launcher}"
      fi
    '';
    serviceConfig.Type = "oneshot";
  };

  systemd.paths.steamvr-cap-sys-nice = {
    description = "Watch for SteamVR compositor updates";
    wantedBy = ["multi-user.target"];
    pathConfig.PathChanged = launcher;
  };
}
