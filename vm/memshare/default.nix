# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2021-2022 Alyssa Ross <hi@alyssa.is>
# SPDX-FileCopyrightText: 2022 Unikie
# SPDX-FileCopyrightText: 2022 TII

{ config ? import ../../../spectrum/nix/eval-config.nix {}
, terminfo ? config.pkgs.foot.terminfo
}:

config.pkgs.pkgsStatic.callPackage (

{ lib, stdenvNoCC, runCommand, writeReferencesToFile, buildPackages
, s6-rc, tar2ext4
, busybox, execline, kmod, mdevd, s6, s6-linux-init
}:

let
  inherit (lib) cleanSource cleanSourceWith concatMapStringsSep hasSuffix;

  scripts = import ../../../spectrum/scripts { inherit config; };

  packages = [
    execline kmod mdevd s6 s6-linux-init s6-rc

    (busybox.override {
      extraConfig = ''
        CONFIG_DEPMOD n
        CONFIG_INSMOD n
        CONFIG_LSMOD n
        CONFIG_MODINFO n
        CONFIG_MODPROBE n
        CONFIG_RMMOD n
      '';
    })
  ];

  packagesSysroot = runCommand "packages-sysroot" {
    inherit packages;
    passAsFile = [ "packages" ];
  } ''
    mkdir -p $out/usr/bin $out/usr/share
    ln -s ${concatMapStringsSep " " (p: "${p}/bin/*") packages} $out/usr/bin
    ln -s ${kernel}/lib "$out"
    ln -s ${terminfo}/share/terminfo $out/usr/share
    ln -s ${memtest}/memtest $out/usr/bin
  '';

  packagesTar = runCommand "packages.tar" {} ''
    cd ${packagesSysroot}
    tar -cf $out --verbatim-files-from \
        -T ${writeReferencesToFile packagesSysroot} .
  '';

  kernel = buildPackages.linux.override {
    kernelPatches = [ {
        name = "Shared memory patch";
        patch = ./memshare.patch;
     } ];
    structuredExtraConfig = with lib.kernel; {
      EFI_STUB = yes;
      EFI = yes;
      VIRTIO = yes;
      VIRTIO_PCI = yes;
      VIRTIO_BLK = yes;
      VIRTIO_CONSOLE = yes;
      VIRTIO_PMEM_CHAR = yes;
      EXT4_FS = yes;
      DRM_BOCHS = yes;
      DRM = yes;
      AGP = yes;
      LIBNVDIMM = yes;
    };
  };

  memtest = config.pkgs.pkgsStatic.callPackage ./memtest/memtest.nix { };
in

stdenvNoCC.mkDerivation {
  name = "appvm-memshare";

  src = cleanSourceWith {
    filter = name: _type:
      name != "${toString ./.}/build" &&
        name != "${toString ./.}/memtest" &&
      !(hasSuffix ".nix" name);
    src = cleanSource ./.;
  };

  nativeBuildInputs = [ s6-rc tar2ext4 ];

  PACKAGES_TAR = packagesTar;
  VMLINUX = "${kernel.dev}/vmlinux";
  IMAGE = "${kernel}/Image";

  makeFlags = [ "SCRIPTS=${scripts}" ];
  installPhase = ''
    mv build/svc $out
  '';

  enableParallelBuilding = true;

  passthru = { inherit kernel; };

  meta = with lib; {
    license = licenses.eupl12;
    platforms = platforms.linux;
  };
}
) {}
