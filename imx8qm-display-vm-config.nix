{
  pkgs = import <nixpkgs> {
    overlays = [
      (import ./overlays/common.nix)
      (import ./overlays/imx8qm.nix)
      (import ./overlays/imx8qm_display_vm.nix)
    ];
  };
}
