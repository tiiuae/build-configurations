{ waypipe, lib, stdenv, lz4, zstd, ... }:

 waypipe.overrideAttrs ( prevAttrs: {
    buildInputs = [ lz4 zstd ];
    mesonFlags = [
  "-Dwith_video=disabled"
  "-Dwith_systemtap=false"
  "-Dwith_vaapi=disabled"
  "-Dwith_dmabuf=disabled"
  ];

})

