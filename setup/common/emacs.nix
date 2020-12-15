{ config, pkgs, ... }:

let
  emacs = (import emacs/default.nix {inherit pkgs;});
in {
  environment.variables.EDITOR = "${emacs}/bin/emacsclient -tc";
  environment.variables.ALTERNATE_EDITOR = "${emacs}/bin/emacs";

  environment.systemPackages = [ emacs ];
  
  services.emacs = {
    enable = true;
    package = emacs;
  };
  environment.shellAliases = {
    vim = "${emacs}/bin/emacsclient -nw";
    e   = "${emacs}/bin/emacsclient -nw";
  };
}
