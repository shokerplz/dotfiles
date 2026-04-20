{self, ...}: {
  flake.nixosModules.roleServer = {
    imports = [
      self.nixosModules.commonSSH
    ];

    services.openssh.settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PubkeyAuthentication = true;
      AuthenticationMethods = "publickey";
    };
  };
}
