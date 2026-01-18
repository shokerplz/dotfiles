{
  config,
  lib,
  pkgs,
  ...
}: {
  boot.kernelParams = [
    "mem_sleep_default=deep"
  ];

  systemd.services.nvidia-unlock-before-sleep = {
    description = "Unlock NVIDIA memory clocks before suspend";
    before = ["systemd-suspend.service" "systemd-hibernate.service" "nvidia-suspend.service"];
    wantedBy = ["sleep.target"];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${config.hardware.nvidia.package.bin}/bin/nvidia-smi --reset-memory-clocks";
    };
  };

  systemd.services.nvidia-lock-after-wake = {
    description = "Re-lock NVIDIA memory clocks after resume";
    after = ["systemd-suspend.service" "systemd-hibernate.service" "nvidia-resume.service"];
    wantedBy = ["sleep.target"];
    serviceConfig = {
      Type = "oneshot";
      # Use same value as nvidia-lock-memclk service in nvidia.nix
      ExecStart = "${config.hardware.nvidia.package.bin}/bin/nvidia-smi --lock-memory-clocks=9501";
    };
  };

  systemd.services.sync-before-sleep = {
    description = "Sync filesystems before suspend";
    before = ["systemd-suspend.service" "systemd-hibernate.service"];
    wantedBy = ["sleep.target"];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.coreutils}/bin/sync";
    };
  };
}
