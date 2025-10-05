{ lib, ... }:
{
  options.environment.packageSelector = lib.mkOption {
    type = lib.types.nullOr lib.types.unspecified;
    default = null;
    example = lib.literalExpression "(import ./lib { inherit lib; }).customPackages.mkSelector { inherit pkgs; }";
    description = ''
      Helper instance used to resolve packages from multiple channels or pinned
      sources using the utilities in ``lib/custom-packages.nix``.
    '';
  };
}
