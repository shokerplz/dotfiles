{ config, pkgs, ... }:

{
  nixpkgs.overlays = with pkgs; [
    (final: prev: {
      # Overlay for orca-slicer. Without this package would fail to build
      orca-slicer = prev.orca-slicer.overrideAttrs (oldAttrs: {
        cmakeFlags = oldAttrs.cmakeFlags ++ [
          (lib.cmakeFeature "CUDA_TOOLKIT_ROOT_DIR" "${prev.cudaPackages.cudatoolkit}")
        ];
      });
    })
  ];

}
