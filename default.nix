{ pkgs ? import <nixpkgs> {}
, machine ? "fff666"
, repoUrl ? "https://github.com/peel/dotfiles.git"
, nurpkgs ? "https://github.com/peel/nur-packages.git"
, channel ? "nixpkgs-unstable"
, targetDir ? "$HOME/wrk"
}:

let
  rebuildCmd = "${if pkgs.stdenvNoCC.isDarwin then "darwin" else "nixos"}-rebuild --option extra-builtins-file ${targetDir}/dotfiles/common/secrets/extra-builtins.nix";
  darwin = ''
    echo >&2
    echo >&2 "Building initial configuration..."
    echo >&2
    #FIXME #OMG
    if test -n $TRAVIS_OS_NAME; then sudo launchctl kickstart system/org.nixos.nix-daemon; fi
    if test -e /etc/static/bashrc; then . /etc/static/bashrc; fi
    /run/current-system/sw/bin/darwin-rebuild switch --flake $HOME/wrk/machines/$1
  '';
  install = pkgs.writeScript "install" ''
    set -e

    echo >&2
    echo >&2 "Installing..."
    echo >&2

    ${pkgs.lib.optionalString pkgs.stdenvNoCC.isDarwin ''
    echo "Setting up/tm nix-darwin..."
    if (! command -v darwin-rebuild); then
        echo >&2 "Installing nix-darwin..."
        mkdir -p ./nix-darwin && cd ./nix-darwin
        nix-build https://github.com/LnL7/nix-darwin/archive/master.tar.gz -A installer
        yes | ./result/bin/darwin-installer
        cd .. && rm -rf ./nix-darwin
    fi
    ''}

    if [ ! -d ${targetDir}/dotfiles ]; then
        echo "Setting up dotfiles repository" >&2
        mkdir -p ${targetDir}/dotfiles
        git clone ${repoUrl} ${targetDir}/dotfiles
    fi

    ${pkgs.lib.optionalString pkgs.stdenvNoCC.isDarwin darwin} "$@"
  '';
  unlink = pkgs.writeScript "unlink" ''
    set -e

    echo >&2
    echo >&2 "Unlinking..."
    echo >&2
    if test -e ~/.config/nixpkgs; then rm -rf ~/.config/nixpkgs; fi
    if test -e /etc/nixos; then sudo rm /etc/nixos; fi
    if test -e /etc/nixos.bak; then sudo mv /etc/nixos.bak /etc/nixos; fi
  '';
in pkgs.stdenvNoCC.mkDerivation {
  name = "dotfiles";
  preferLocalBuild = true;
  propagatedBuildInputs = [ pkgs.git ];
  propagatedUserEnvPkgs = [ pkgs.git ];
  
  unpackPhase = ":";

  installPhase = ''
    mkdir -p $out/bin
    echo "$shellHook" > $out/bin/dotfiles
    chmod +x $out/bin/dotfiles
  '';

  shellHook = ''
    set -e

    while [ "$#" -gt 0 ]; do
        i="$1"
        case "$i" in
            install)
                shift
                ${install} "$@"
                exit
                ;;
            uninstall)
                ${unlink}
                exit
                ;;
            help)
                echo "dotfiles: [help] [install machine-name] [uninstall]"
                exit
                ;;
            *)
               ${rebuildCmd} "$@"
               exit
               ;;
        esac
    done
    exit
  '';

  passthru.check = pkgs.stdenvNoCC.mkDerivation {
     name = "run-dotfiles-test";
     shellHook = ''
        set -e
        echo >&2 "running dotfiles tests..."
        echo >&2
        echo >&2 "checking repository"
        test -d ${targetDir}
        exit
    '';
  };
}
