{ stdenv, requireFile, unzip }:

let
  version = "0.828";
  installPath = "share/fonts/truetype/";
in stdenv.mkDerivation rec {
  name = "pragmatapro-${version}";
  src = (./. + "/PragmataPro-${version}.private.zip");
  buildInputs = [ unzip ];
  phases = [ "unpackPhase" "installPhase" ];
  pathsToLink = [ "/share/fonts/truetype/" ];
  sourceRoot = ".";
  installPhase = ''
    install_path=$out/${installPath}
    mkdir -p $install_path
    find 'Pragmata Pro Family' -name "*.ttf" -exec cp {} $install_path \;
  '';
  meta = with stdenv.lib; {
    homepage = "https://www.fsd.it/shop/fonts/pragmatapro/";
    description = ''
      PragmataPro™ is a condensed monospaced font optimized for screen,
      designed by Fabrizio Schiavi to be the ideal font for coding, math and engineering
    '';
    platforms = platforms.all;
    # broken = true;
  };
}
