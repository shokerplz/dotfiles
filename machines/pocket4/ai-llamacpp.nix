{
  config,
  pkgs,
  lib,
  ...
}:

let
  # Define the path to the llama-cpp package with overrides
  llamaCppPackage = pkgs.llama-cpp.override {
    rocmSupport = false;
    vulkanSupport = true;
  };

  # Define the model path
  modelPath = "/var/lib/llama-cpp/Qwen3-Coder-30B-A3B-Instruct-UD-Q8_K_XL.gguf";

  # Define extra flags
  extraFlags = [
    "-ngl" "99"
    "-c" "192000"
    "-np" "4"
    "--host" "0.0.0.0"
    "--port" "28560"
  ];
in {
  # Disable the default services.llama-cpp module to manually configure systemd units
  services.llama-cpp.enable = lib.mkForce false;

  system.activationScripts.llama-cpp-data-dir = ''
    mkdir -p /var/lib/llama-cpp
  '';

  systemd.services.llama-cpp = {
    description = "Llama.cpp AI server";
    # Removed wantedBy as it will be socket activated
    # This service will be started by the socket unit
    requires = [ "llama-cpp.socket" ];
    bindsTo = [ "llama-cpp.socket" ];
    socketActivation = true;

    serviceConfig = {
      ExecStart = "${llamaCppPackage}/bin/server -m ${modelPath} ${lib.concatStringsSep " " extraFlags}";
      Restart = "on-failure";
      User = "ikovalev"; # Assuming iikovalev is the desired user, as in previous context
      Group = "users";
      SupplementaryGroups = ["video" "render"];
      AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ]; # Needed for binding to privileged ports, if necessary
    };

    environment = {
      HOME = "/var/lib/llama-cpp";
    };
  };

  systemd.sockets.llama-cpp = {
    description = "Llama.cpp AI server socket";
    listenStreams = [ "0.0.0.0:28560" ];
    wantedBy = [ "sockets.target" ];
  };

  # Preserve the firewall rules, as they are still necessary for external access
  networking.firewall.extraCommands = ''
    iptables -A nixos-fw -p tcp --dport 28560 -s 10.0.0.0/16 -j nixos-fw-accept
  '';
  networking.firewall.extraStopCommands = ''
    iptables -D nixos-fw -p tcp --dport 28560 -s 10.0.0.0/16 -j nixos-fw-accept || true
  '';
}
