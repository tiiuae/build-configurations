# SPDX-FileCopyrightText: 2022 TII

{ pkgs ? import <nixpkgs> {} }: pkgs.pkgsStatic.callPackage (

{ lib, stdenv, gcc }:

let
  inherit (lib) cleanSource cleanSourceWith hasSuffix;
in

stdenv.mkDerivation {
  name = "memtest";

  src = cleanSourceWith {
    filter = name: _type: !(hasSuffix ".nix" name);
    src = cleanSource ./.;
  };

  doCheck = true;

}
) { }
