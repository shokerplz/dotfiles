{ config, pkgs, ... }:

{
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.ikovalev = {
    isNormalUser = true;
    description = "Ivan Kovalev";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
      "input"
    ];
    packages = with pkgs; [ ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDkzKTLx/e5Jj5EnOqYHjvWWAeh9ySvvIvbdfAb+cWSu/cGN/lrSMQuXKYkCh1BYS62zdGBJzU35QAcBRYHpArrQLLYxZxoS8SAe4juLLDCmw5mAb7+NlrWeSmKfv7kd9JOnR5R5sD5gWVghY+/xwcHYCCYNAFSv3orHOy3euq4E3TcAqZ5y321PBFnbA/pBXa3WEF3FPsB9/3orxHlnZCoe7sl/Js/hNsIiZvUdLtvBCPdJ8/Fs9LrWNzVHjw0hFdS4u/mgRfoo1fMSVOS3D0oLtQc6lB0dxg1A/iGedhlC3E5qM6nOVYAlAgZj5PyMwfcUCSSNhSuy9T8dYWXVByoNh4T8E5XcVG+jkz5CJcFuCFKzSCI+tRKlH6TyiFe6vhL1Fo82hrmbCZ/qAsrHfCOkJ9Hzt83oHQaKU4tR6Y0ulqjTNmMrs5OPX0PKE7OVLPAEt5cyiQEPY4Y7soJ18SlbwFnvvU3HZOdG5Ls7oJg5xp8TT1CakLVGbO6WvuX/YE= shoke@DESKTOP-L8RIQHU"
    ];
  };
}
