{
  config,
  pkgs,
  ...
}: {
  # Create the shared monitoring network once Docker is available.
  system.activationScripts.createDockerNetwork = let
    docker = config.virtualisation.oci-containers.backend;
    dockerBin = "${pkgs.${docker}}/bin/${docker}";
  in ''
    ${dockerBin} network inspect monitoring >/dev/null 2>&1 || ${dockerBin} network create monitoring
  '';
}
