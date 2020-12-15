{ config, lib, ...}:

with lib;

let
  cfg = config.peel.setup;
  home = builtins.getEnv "HOME";
in {
  options.peel.setup.host = mkOption {
    description = "Machine name";
  };
  options.peel.setup.user = mkOption {
    default = "peel";    
    description = "Main user name";    
  };
  config = {
    networking.hostName = cfg.host;
    nix.maxJobs = lib.mkDefault 12;
    environment.darwinConfig = "${home}/.config/nix/machines/${cfg.host}/configuration.nix";
    system.stateVersion = 3;
    nixpkgs.overlays =
    let path = ../../overlays; in with builtins;
      map (n: import (path + ("/" + n)))
          (filter (n: match ".*\\.nix" n != null ||
                      pathExists (path + ("/" + n + "/default.nix")))
            (attrNames (readDir path)));
      # ++ [ (import "${home}/.config/nurpkgs/overlay.nix") ];
  };
}
