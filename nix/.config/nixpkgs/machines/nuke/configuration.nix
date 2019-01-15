{ config, lib, pkgs, ... }:

with lib;

let
  username = "peel";
  hostName = "nuke";
  domain = builtins.readFile (<setup/secret/domain>);
  orgdomain = builtins.readFile (<setup/secret/org.domain>);
in {
  imports = let nur = (import <nurpkgs-peel/modules>); in [
    ./hardware-configuration.nix
    <setup/common.nix>
    <setup/nixos.nix>
    <setup/ha.nix>
  ] ++ [
    nur.udiskie
  ];

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowBroken = true;
  nix.nixPath = [
    "nixpkgs=channel:nixos-18.09"
    "nixos-config=/etc/nixos/configuration.nix"
    "nurpkgs-peel=$HOME/.config/nurpkgs"
    "nixpkgs-overlays=$HOME/.config/nixpkgs/overlays"
    "setup=$HOME/.config/nixpkgs/setup"
  ];
  nixpkgs.overlays = 
    let path = <nixpkgs-overlays> ; in with builtins;
      map (n: import (path + ("/" + n)))
          (filter (n: match ".*\\.nix" n != null ||
                      pathExists (path + ("/" + n + "/default.nix")))
                  (attrNames (readDir path)))
    ++[ (import <nurpkgs-peel/overlay.nix>) ];
  nix.useSandbox = true;
  nix.binaryCaches = [ https://cache.nixos.org https://peel.cachix.org ];
  nix.trustedUsers = [ "${username}" "root" ];
    
  # hardware ▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁
  hardware.enableAllFirmware = true;
  boot.kernelModules = [ "iwlwifi" ]; 
  boot.loader = {
    efi.efiSysMountPoint = "/efi";
    grub = {
      device = "nodev"; # do not install Grub for BIOS booting
      efiSupport = true; 
      extraInitrd = "/boot/initrd.keys.gz";  # add LUKS key to the initrd
      enableCryptodisk = true; # allow Grub to boot from LUKS devices
      zfsSupport = true;
    };
    grub.efiInstallAsRemovable = true;
  };
  boot.initrd.luks.devices.nvme = {
   device = "/dev/disk/by-uuid/47543190-aed6-44d1-bc69-ef1f65df0bbd";
   keyFile = "/keyfile.bin";
  };
  sound.enable = true;
  hardware.pulseaudio.enable = true;
  hardware.bluetooth.enable = true;

  # os ▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁
  system.stateVersion = "18.09";
  nix.gc = {
    automatic = true;
    options = "--delete-older-than 30d";
  };

  networking = {
    hostId = "675e1435";
    hostName = hostName;
    wireless.enable = false;
    networkmanager.enable = true;
    firewall.enable = false;
  };

  i18n = {
    consoleFont = "${pkgs.terminus_font}/share/consolefonts/ter-u28n.psf.gz";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

  environment.systemPackages = with pkgs; [ emacs docker ];

  users.extraUsers = {
    "${username}"= {
      home = "/home/${username}";
      isNormalUser = true;
      extraGroups = [ "wheel" "docker" ];
      uid = 1000;
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC1hNlicWZhVgkYg6DlSs1CkjbU710RFhIc9uUFdSlk3MLtjidI0Zfbn3bfqyerXwRzOuyL7/bEuqC9lvu7b6KmvEpj1nhuOr0U1ttgIzUvgmz/cwVcVdtLv9Cr21Y2yMRDkAjj3EyLgXXZ+2sii39pYlMHcf7KFCGwgvAlHiI8ThXIW+ZbGqU6NtyoxIBPSZSbZiUz4wz02azipwFGtmGKT37sMeL635YjWqMYMJD453vPdW2F2rpq4B1NZX5L/chZs0FRytjtJJWrm1IEaqUqZXvhktKC6pDLMm/2fuqLgU8DxltXBf5vqimsJ1LPMXGOgQ0OKExiF/Gkv1Ub9x80qcEfpXninz2cvGw0xWpr7FbEShkbalt5MN7kvLIzB4Kmw71L7Af4CxcyJ0cHGGjzg8B92k1gk1rItqM8e8mGeLMrEFPJxMUCJvIE7Ywgbu7kUM8WB5x+Ni4ZmeIUHAtUUad+Z6Xd1Y7lB7190HeWWUR9+yySxOH4pUA3161sCOa5xG/mnW7QtBbD4Tqnc7ouIUq57JpSvOtilTgQAQfS3NZkNbsOv2lHDltPCqk8F4039UCxps6EbJkgNmtV31jqTiDDdQ0fCmOcl8dNygA5cTkWgMjdf1U+va68s92fVsCrwQiKm3zFNGC6VHsSAkEMc29a4d70lWCZlrcWAglZdw== piotr@codearsonist.com"
      ];
    };
  };

  services = {
    openssh = {
      enable = true;
      permitRootLogin = "yes";
    };
    avahi = {
      enable = true;
      nssmdns = true;
      publish.addresses = true;
      publish.enable = true;
      publish.workstation = true;
      publish.domain = true;
    };
    xserver.enable = false;
    nixosManual.enable = false;
  };


  # monitoring  ▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁
  services.datadog-agent = {
    enable = true;
    apiKeyFile = <setup/secret/datadog.key>;
  };

  # general routes  ▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁
  services.ddclient = {
    enable = true;
    protocol = "duckdns";
    domains = [ "${domain}" ];
    password = builtins.readFile (<setup/secret/ddclient.password>);
  };
  services.fail2ban.enable = true;
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    
    # syno
    virtualHosts."drive.${orgdomain}" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "https://datavism.local:5001";
        proxyWebsockets = true;
      };
    };

    # hass
    virtualHosts."ha.${orgdomain}" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:8123";
        proxyWebsockets = true;
      };
    };
  };
  
  # containers ▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    autoPrune.enable = true;
    liveRestore = true;
  };
  
  # enable access to external network from containers
  networking.nat.enable = true;
  networking.nat.internalInterfaces = ["ve-+"];
  networking.nat.externalInterface = "eth0";
  networking.networkmanager.unmanaged = [ "interface-name:ve-*" ];
  
  containers = {
    # hass = {
    #   config = import <setup/ha.nix>;
    #   autoStart = true;
    # };
    # plex = {
    #   config = import <setup/plex.nix>;
    #   autoStart = true;
    # };
    # vault = {};
  };
  
}
