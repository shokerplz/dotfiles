{ config, pkgs, ... }:

{
  config.system.activationScripts.Ollama =
    let
      docker = config.virtualisation.oci-containers.backend;
      dockerBin = "${pkgs.${docker}}/bin/${docker}";
    in
    ''
      mkdir -p /var/data/ollama;
      mkdir -p /var/data/openwebui;

      ${dockerBin} network inspect ai >/dev/null 2>&1 || ${dockerBin} network create ai
    '';

  # Define the OCI containers configuration inside `config.virtualisation.oci-containers`
  config.virtualisation.oci-containers.containers = {
    ollama = {
      image = "ollama/ollama:latest";
      ports = [ "127.0.0.1:7869:11434" ];
      volumes = [ "/var/data/ollama:/root/.ollama" ];
      extraOptions = [
        "--network=ai"
        "--gpus=all"
      ];
    };
    open-web-ui = {
      image = "ghcr.io/open-webui/open-webui:main";
      ports = [ "3000:8080" ];
      volumes = [ "/var/data/openwebui:/app/backend/data" ];
      extraOptions = [ "--network=ai" ];
    };
  };
}
