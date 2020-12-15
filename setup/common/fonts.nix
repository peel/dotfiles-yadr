{ config, pkgs, lib, ... }:

let
  pragmatapro = pkgs.callPackage ./pragmatapro {};
in {
  fonts = {
    enableFontDir = true;
    fonts = [pragmatapro];
  } // lib.optionalAttrs pkgs.stdenvNoCC.isLinux {
    fontconfig.enable = true;
    fontconfig.dpi = 180;
  };
}
