{ config, pkgs, ... }:

let
  home = builtins.getEnv "HOME";
in {

  imports = [
    ../common
    ./gui.nix
  ];
  
  environment.systemPackages = [
    pkgs.docker
    pkgs.docker_compose
  ];

  environment.shellAliases = {
    nixos-rebuild = "nixos-rebuild --option extra-builtins-file ${home}/setup/common/secrets/extra-builtins.nix";
  };
}
