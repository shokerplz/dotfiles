{pkgs-current, ...}: {
  boot.kernelParams = [
    "mem_sleep_default=deep"
    "amd_pstate=active"
  ];

  systemd.services.sync-before-sleep = {
    description = "Sync filesystems before suspend";
    before = ["systemd-suspend.service" "systemd-hibernate.service"];
    wantedBy = ["sleep.target"];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs-current.coreutils}/bin/sync";
    };
  };
}
