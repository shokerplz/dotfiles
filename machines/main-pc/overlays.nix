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

        postInstall =
          (old.postInstall or "")
          + ''
            mv $out/bin/orca-slicer $out/bin/.orca-slicer-wrapped
            echo "env __GLX_VENDOR_LIBRARY_NAME=mesa __EGL_VENDOR_LIBRARY_FILENAMES=/run/opengl-driver/share/glvnd/egl_vendor.d/50_mesa.json MESA_LOADER_DRIVER_OVERRIDE=zink GALLIUM_DRIVER=zink WEBKIT_DISABLE_DMABUF_RENDERER=1 $out/bin/.orca-slicer-wrapped" > $out/bin/orca-slicer
            chmod +x $out/bin/orca-slicer
          '';
      });
    })
  ];
}
