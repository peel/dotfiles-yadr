self: super: {

installApplication = 
  { name, appname ? name, version, src, description, homepage, 
    postInstall ? "", sourceRoot ? ".", ... }:
  with super; stdenv.mkDerivation {
    name = "${name}-${version}";
    version = "${version}";
    src = src;
    buildInputs = [ undmg unzip ];
    sourceRoot = sourceRoot;
    phases = [ "unpackPhase" "installPhase" ];
    installPhase = ''
      mkdir -p "$out/Applications/${appname}.app"
      cp -pR * "$out/Applications/${appname}.app"
    '' + postInstall;
    meta = with stdenv.lib; {
      description = description;
      homepage = homepage;
      platforms = platforms.darwin;
    };
  };

Calibre = self.installApplication rec {
  name = "Calibre";
  version = "3.40.1";
  sourceRoot = "Calibre.app";
  src = super.fetchurl {
    url = "https://download.calibre-ebook.com/${version}/calibre-${version}.dmg";
    sha256 = "1afcc552c1a53a65423da64bc59cff4fe5f27dc51dce67bd15b63a3851e6f121";
    # date = 2018-03-10T23:36:13-0700;
  };
  description = "Calibre is a one stop solution for all your ebook needs.";
  homepage = https://calibre-ebook.com;
  # appcast = https://github.com/kovidgoyal/calibre/releases.atom;
};

Dash = self.installApplication rec {
  name = "Dash";
  version = "5.5.0";
  sourceRoot = "Dash.app";
  src = super.fetchurl {
    url = https://kapeli.com/downloads/v5/Dash.zip;
    sha256 = "0hgxg2r141162cd4nzpx65v77m6ag10i6wg35hv0r9a4f0xxsxxv";
    # date = 2018-09-28T23:36:13-0700;
  };
  description = "Dash is an API Documentation Browser and Code Snippet Manager";
  homepage = https://kapeli.com/dash;
};

Docker = self.installApplication rec {
  name = "Docker";
  version = "2.0.0.3";
  versionId = "31259";
  sourceRoot = "Docker.app";
  src = super.fetchurl {
    url = "https://download.docker.com/mac/stable/${versionId}/Docker.dmg";
    sha256 = "09gwqdppnzw7hhlmgxakczxql4jfknk4ayc5z09g4kr8agqn4m55";
    # date = 2018-09-28T11:14:33-0700;
  };
  description = ''
    Docker CE for Mac is an easy-to-install desktop app for building,
    debugging, and testing Dockerized apps on a Mac
  '';
  homepage = https://store.docker.com/editions/community/docker-ce-desktop-mac;
};
}
