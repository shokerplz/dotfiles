{ lib }:
let
  customPackages = import ./custom-packages.nix { inherit lib; };
 in
{
  inherit customPackages;
}
