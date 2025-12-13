{
  lib,
  nixpkgs-unstable,
  ...
}: {
  services.llama-cpp = {
    package = nixpkgs-unstable.llama-cpp.override {
      rocmSupport = false;
      vulkanSupport = true;
    };
    enable = true;
    model = "/var/lib/llama-cpp/Qwen3-Coder-30B-A3B-Instruct-UD-Q8_K_XL.gguf";
    extraFlags = [
      "-ngl"
      "99"
      "-c"
      "192000"
      "--host"
      "0.0.0.0"
      "--port"
      "28560"
      "--no-mmap"
      "-fa"
      "1"
      "--chat-template-file"
      "/var/lib/llama-cpp/Qwen3-Coder-30B-A3B-Instruct-UD-Q8_K_XL.template"
      "--jinja"
    ];
  };

  systemd.services.llama-cpp.wantedBy = lib.mkForce [];

  networking.firewall.extraCommands = ''
    iptables -A nixos-fw -p tcp --dport 28560 -s 10.0.0.0/16 -j nixos-fw-accept
  '';
  networking.firewall.extraStopCommands = ''
    iptables -D nixos-fw -p tcp --dport 28560 -s 10.0.0.0/16 -j nixos-fw-accept || true
  '';
}
