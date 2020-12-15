self: super:

with super.lib;

let 
  theme = "dark";
in {
  colors = {} // (import ./colors.nix { });
  fonts = {} // import ./fonts.nix;
} // optionalAttrs (files.contains "private.zip" ./pragmatapro) {
  pragmatapro = super.callPackage ./pragmatapro {};
}
