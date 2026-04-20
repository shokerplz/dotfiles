{lib, ...}: {
  virtualisation.oci-containers.containers.llama-cpp = {
    image = "llama-cpp-rocm7.0rc";
    ports = ["28560:28560"];
    environment = {
      HSA_OVERRIDE_GFX_VERSION = "11.5.1";
    };
    volumes = [
      "/var/lib/llama-cpp:/models"
    ];
    cmd = [
      "llama-server"
      "--model"
      "/models/Qwen3-Coder-30B-A3B-Instruct-UD-Q8_K_XL.gguf"
      "--chat-template-file"
      "/models/Qwen3-Coder-30B-A3B-Instruct-UD-Q8_K_XL.template"
      "-ngl"
      "99"
      "-fa"
      "1"
      "-c"
      "140000"
      "--host"
      "0.0.0.0"
      "--port"
      "28560"
      "--no-mmap"
      "--jinja"
      "--temp"
      "0.7"
      "--min-p"
      "0.01"
      "--top-p"
      "0.80"
      "--top-k"
      "20"
      "--repeat-penalty"
      "1.1"
    ];
    extraOptions = [
      "--device=/dev/kfd"
      "--device=/dev/dri"
    ];
  };

  systemd.services.docker-llama-cpp.wantedBy = lib.mkForce [];

  networking.firewall.extraCommands = ''
    iptables -A nixos-fw -p tcp --dport 28560 -s 10.0.0.0/16 -j nixos-fw-accept
  '';
  networking.firewall.extraStopCommands = ''
    iptables -D nixos-fw -p tcp --dport 28560 -s 10.0.0.0/16 -j nixos-fw-accept || true
  '';
}
