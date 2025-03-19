{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Create docker network for RPI5
  system.activationScripts.createDockerNetwork =
    let
      docker = config.virtualisation.oci-containers.backend;
      dockerBin = "${pkgs.${docker}}/bin/${docker}";
    in
    ''
      ${dockerBin} network inspect monitoring >/dev/null 2>&1 || ${dockerBin} network create monitoring
    '';
}
