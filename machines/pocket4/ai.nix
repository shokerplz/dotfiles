{
  lib,
  ...
}: {
  virtualisation.oci-containers.containers.llama-cpp = {
    image = "llama-cpp-rocm7.0rc";
    ports = ["28560:28560"];
    volumes = [
      "/var/lib/llama-cpp:/models"
    ];
    cmd = [
      "--model"
      "/models/Qwen3-Coder-30B-A3B-Instruct-UD-Q8_K_XL.gguf"
      "-ngl"
      "99"
      "-c"
      "192000"
      "-np"
      "4"
      "--host"
      "0.0.0.0"
      "--port"
      "28560"
      "--jinja"
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