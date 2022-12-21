final: prev: {
  
  ubootImx8 = prev.ubootImx8.overrideAttrs (old: {
    patches = old.patches ++ [
      ./bsp/u-boot/imx8qm/patches/0001-Add-support-for-Display-VM.patch
    ];
  });

}
