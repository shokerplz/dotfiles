{ config, pkgs, ... }:

{
  # Ensure the data directory exists for the model cache
  system.activationScripts.vllm-data-dir = ''
    mkdir -p /var/lib/vllm
  '';

  virtualisation.oci-containers.containers.vllm = {
    image = "rocm/vllm:latest";
    autoStart = false; # User must start manually: sudo systemctl start docker-vllm
    ports = [ "8000:8000" ];
    volumes = [
      "/var/lib/vllm:/root/.cache/huggingface"
    ];
    environment = {
      # RDNA 3.5 (Ryzen AI 9) compatibility override
      HSA_OVERRIDE_GFX_VERSION = "11.0.0";
    };
    extraOptions = [
      "--device=/dev/kfd"
      "--device=/dev/dri"
      "--group-add=video"
      "--group-add=render"
      "--ipc=host"
    ];
    cmd = [
      "python3" "-m" "vllm.entrypoints.openai.api_server"
      "--model" "facebook/opt-125m"
      "--gpu-memory-utilization" "0.95"
      "--dtype" "half"
      "--enforce-eager"
    ];
  };

  # Allow local access to the API
  networking.firewall.allowedTCPPorts = [ 8000 ];
}
