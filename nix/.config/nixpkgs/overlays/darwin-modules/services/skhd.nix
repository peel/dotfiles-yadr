{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.skhd;

in {

  options = {
    services.skhd.enable = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to enable the skhd hotkey daemon.";
    };

    services.skhd.package = mkOption {
      type = types.package;
      example = literalExample "pkgs.skhd";
      description = "This option specifies the skhd package to use.";
    };

    services.skhd.skhdConfig = mkOption {
      type = types.lines;
      default = "";
      example = "alt + shift - r   :   chunkc quit";
      description = "Config to use for <filename>skhdrc</filename>.";
    };
  };

  config = mkIf cfg.enable {

    security.accessibilityPrograms = [ "${cfg.package}/bin/skhd" ];

    environment.etc."skhdrc".text = cfg.skhdConfig;

    launchd.user.agents.skhd = {
      path = [ cfg.package config.environment.systemPath ];

      serviceConfig.ProgramArguments = [ "${cfg.package}/bin/skhd" ]
        ++ optionals (cfg.skhdConfig != "") [ "-c" "/etc/skhdrc" ];
      serviceConfig.KeepAlive = true;
      serviceConfig.ProcessType = "Interactive";
      serviceConfig.StandardOutPath = "/tmp/skhd.out";
      serviceConfig.StandardErrorPath = "/tmp/skhd.err";
      # serviceConfig.Sockets.Listeners =
      #   { SockServiceName = "3021";
      #     SockType = "dgram";
      #     SockFamily = "IPv4";
      #   };
    };

  };
}
