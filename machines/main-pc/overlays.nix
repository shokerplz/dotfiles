{
  config,
  pkgs,
  nixpkgs-unstable,
  lib,
  ...
}: {
  nixpkgs.overlays = with pkgs; [
    (final: prev: {
      # Overlay for orca-slicer. Without this orca-slicer would not work properly
      orca-slicer = prev.orca-slicer.overrideAttrs (old: rec {
        cmakeFlags =
          (old.cmakeFlags or [])
          ++ [
            (prev.lib.cmakeFeature "CUDA_TOOLKIT_ROOT_DIR" "${prev.cudaPackages.cudatoolkit}")
          ];

        nativeBuildInputs = (old.nativeBuildInputs or []) ++ [prev.makeWrapper];

        postFixup =
          (old.postFixup or "")
          + ''
            wrapProgram "$out/bin/orca-slicer" \
              --set __EGL_VENDOR_LIBRARY_FILENAMES "${prev.pkgs.mesa}/share/glvnd/egl_vendor.d/50_mesa.json" \
              --set WEBKIT_DISABLE_DMABUF_RENDERER "1" \
              --set MESA_LOADER_DRIVER_OVERRIDE "zink" \
              --set GALLIUM_DRIVER "zink" \
              --set __GLX_VENDOR_LIBRARY_NAME "mesa" \
              --set GBM_BACKEND "dri"
          '';
      });
    })
  ];
}
