{...}: {
  users.users.mgmt = {
    isNormalUser = true;
    description = "Management";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
      "input"
    ];
    hashedPassword = "$y$j9T$vanF2RIrnI.ubDRcY9NT90$y4UgUVn2hq/32L7kiubzHiv8gl5JgEdhEwS/C2pSJ64";
  };
}
