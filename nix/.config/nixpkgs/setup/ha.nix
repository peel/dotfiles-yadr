{ config, lib, pkgs, ... }:

let
  hass = let
   nixpkgs = import (builtins.fetchTarball {
              url = "https://github.com/NixOS/nixpkgs/archive/cc1d13ae0f0d7c2bb6d6be9e64349a628ca0512f.tar.gz";
              sha256 = "0j8ml871rikpd243dy23r6k9cw5mq3z560yd2s3s454k7pdk50i6";
            }) { config = { }; };
  in {
    cfg = pkgs.callPackage (pkgs.fetchFromGitHub {
      owner = "peel";
      repo = "hassio";
      sha256 = "1y2zb5gipzyjzkhbzy6432g7l6bdnb9jfqlvxs4clnk91hxqqd5h";
      rev = "0.0.4";
    }) { pkgs = nixpkgs; };
    image = "homeassistant/home-assistant";
    version = "0.84.6";
  };
  z2m = {
    image = "koenkk/zigbee2mqtt";
    version = "1.0.1";
  };
in {
  services.mosquitto = {
    enable = true;
    allowAnonymous = true;
    host = "0.0.0.0";
    users.zigbee2mqtt = {
      acl = [ "topic readwrite homeassistant/#" "topic readwrite zigbee2mqtt/#" ];
      password = builtins.readFile (<setup/secret/mosquitto.zigbee2mqtt.password>);
    };
  };
  systemd.services.hassCfg = {
    enable = true;
    after = [ "network.target" ];
    before = [ "home-assistant.target" "zigbee2mqtt.target" ];
    wants = [ "home-assistant.target" "zigbee2mqtt.target" ];
    wantedBy = [ "multi-user.target" ];
    script = ''
      mkdir -p /var/lib/hass
      mkdir -p /var/lib/zigbee2mqtt
      ls ${hass.cfg}/var/lib/hass
      cp -r ${hass.cfg}/var/lib/hass/* /var/lib/hass/
      cp ${hass.cfg}/zigbee2mqtt/* /var/lib/zigbee2mqtt/
      chmod -R a+x+w /var/lib/hass
      chmod -R a+x+w /var/lib/zigbee2mqtt
    '';
  };
  systemd.services.zigbee2mqtt = {
    enable = true;
    after =  [ "network.target" "docker.service" ];
    wants = [ "network.target" "docker.service" ];
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.docker ];
    serviceConfig = {
      Restart = "always";
      ExecStartPre = [
      "-${pkgs.docker}/bin/docker stop zigbee2mqtt"
      "-${pkgs.docker}/bin/docker rm zigbee2mqtt"
      "${pkgs.docker}/bin/docker pull ${z2m.image}:${z2m.version}"
      ];
      ExecStart = ''
        ${pkgs.docker}/bin/docker run --rm \
          --name="zigbee2mqtt" \
          -e DEBUG=* \
          -v /var/lib/zigbee2mqtt:/app/data \
          --device=/dev/ttyACM0 \
          ${z2m.image}:${z2m.version}
      '';
    };
  };
  
  systemd.services.home-assistant = {
    enable = true;
    after =  [ "hassCfg.target" "network.target" "docker.service" ];
    wants = [ "hassCfg.target" "network.target" "docker.service" ];
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.docker ];
    serviceConfig = {
      Restart = "always";
      ExecStartPre = [
        "-${pkgs.docker}/bin/docker stop home-assistant"
        "-${pkgs.docker}/bin/docker rm home-assistant"
        "${pkgs.docker}/bin/docker pull ${hass.image}:${hass.version}"
      ];
      ExecStart = ''
        ${pkgs.docker}/bin/docker run --rm \
          --name="home-assistant" \
          -v /var/lib/hass:/config \
          -v /etc/localtime:/etc/localtime:ro \
          --net=host \
          ${hass.image}:${hass.version}
      '';
    };
  };
}
  
