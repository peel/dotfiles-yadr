{ config, pkgs, lib, ... }:

/* The function is a set of sane defaults for my own use with NixOS/Nix-Darwin.
 * Machine specific configuration must be set in extras attributes.
 * Extras take precedence over what is in mkConfiguration.
 */
let
  extras = {
    # mbp config
    # Use the systemd-boot EFI boot loader.
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    # mbp config
    boot.initrd.luks.devices = [
      {
        name = "root";
        device = "/dev/sdb3";
        preLVM = true;
      }
    ];

    # mbp config
    boot.extraModprobeConfig = ''
      #options libata.force=noncq
      options hid_apple iso_layout=0
      #options resume=/dev/sdb3
      #options snd_hda_intel index=0 model=intel-mac-auto id=PCH
      #options snd_hda_intel index=1 model=intel-mac-auto id=HDMI
      #options snd_hda_intel model=mbp101
      #options hid_apple fnmode=2
    '';

    # mbp config
    hardware = {
      enableRedistributableFirmware = true;
      cpu.intel.updateMicrocode = true;
      facetimehd.enable = true;
      opengl.enable = true;
      opengl.driSupport32Bit = true;
      opengl.extraPackages = with pkgs; [ vaapiIntel ];
      pulseaudio.enable = true;
      pulseaudio.package = pkgs.pulseaudioFull;
      pulseaudio.systemWide = false;
      pulseaudio.support32Bit = true;
      pulseaudio.daemon.config = {
        flat-volumes = "no";
      };
      bluetooth.enable = true;
    };
    sound.mediaKeys.enable = true;

    # mbp config
    # Enable the backlight on rMBP
    # Disable USB-based wakeup
    # see: https://wiki.archlinux.org/index.php/MacBookPro11,x
    systemd.services.mbp-fixes = {
      description = "Fixes for MacBook Pro";
      wantedBy = [ "multi-user.target" "post-resume.target" ];
      after = [ "multi-user.target" "post-resume.target" ];
      script = ''
        if [[ "$(cat /sys/class/dmi/id/product_name)" == "MacBookPro11,3" ]]; then
          if [[ "$(${pkgs.pciutils}/bin/setpci  -H1 -s 00:01.00 BRIDGE_CONTROL)" != "0000" ]]; then
            ${pkgs.pciutils}/bin/setpci -v -H1 -s 00:01.00 BRIDGE_CONTROL=0
          fi
          echo 5 > /sys/class/leds/smc::kbd_backlight/brightness
          if ${pkgs.gnugrep}/bin/grep -q '\bXHC1\b.*\benabled\b' /proc/acpi/wakeup; then
            echo XHC1 > /proc/acpi/wakeup
          fi
        fi
      '';
      serviceConfig.Type = "oneshot";
    };

    # mbp config
    services.mbpfan = {
      enable = true;
      lowTemp = 61;
      highTemp = 65;
      maxTemp = 84;
    };
  };
in rec {
  mkConfiguration =
    { hostName ? "fff666"
    , username ? "peel"
    , extras ? {}
    , ...
    } @ attrs:

    let
      wallpaper = pkgs.copyPathToStore ../art/the-technomancer.png;
      mkOverlay = username: overlay: builtins.toPath "/home/${username}/.config/nixpkgs/overlays/${overlay}.nix";
    in
    {
      imports = [
          ../hardware-configuration.nix
          ./common.nix
          ./nixos.nix
          ./packages.nix
          ./emacs.nix
        ] ++ import (mkOverlay username "modules/module-list");

      # shared config
      boot.cleanTmpDir = true;

      # shared config
      nixpkgs.config.allowUnfree = true;
      nixpkgs.overlays = [ (import (mkOverlay username username)) ];
      nix.useSandbox = true;
      nix.binaryCaches = [ https://cache.nixos.org ];

      # shared config
      networking.hostName = hostName;
      networking.networkmanager.enable = true;
      networking.wireless.enable = false;
      networking.firewall.enable = true;


      # Select internationalisation properties.
      # i18n = {
      #   consoleFont = "Lat2-Terminus16";
      #   consoleKeyMap = "us";
      #   defaultLocale = "en_US.UTF-8";
      # };

      # shared config
      time.timeZone = "Europe/Warsaw";

      # environment.variables.NO_AT_BRIDGE = "1";

      # shared config
      powerManagement.enable = true;
      programs.light.enable = true;
      services.tlp.enable = true;
      services.thermald.enable = true;
      services.acpid.enable = true;

      # shared config
      services.batteryNotifier.enable = true;

      # services.openssh.enable = true;
      # services.printing.enable = true;

      # shared config
      services.locate.enable = true;
      services.nixosManual.showManual = true;

      # mbp config / shared config
      services.xserver = {
        enable = true;
        xkbOptions = "eurosign:e";
        dpi = 168;
        xrandrHeads = [
          {
            output = "eDP1";
            primary = true;
            monitorConfig = ''
              Option "mode" "2560x1600"
              Option "pos" "3840x0"
              Option "rotate" "normal"
            '';
          }
          {
            output = "HDMI2";
            monitorConfig = ''
              Option "mode" "3840x2160"
              Option "pos" "0x0"
              Option "rotate" "normal"
            '';
          }
        ];
        multitouch.enable = true;
        multitouch.invertScroll = true;
        autoRepeatDelay = 200;
        autoRepeatInterval = 33; # 30hz

        deviceSection = ''
          Option   "NoLogo"         "TRUE"
          Option   "DPI"            "168 x 168"
          Option   "Backlight"      "gmux_backlight"
          Option   "RegistryDwords" "EnableBrightnessControl=1"
        '';
        synaptics = {
          enable = true;
          tapButtons = true;
          fingersMap = [ 1 1 1 ];
          buttonsMap = [ 1 3 2 ];
          twoFingerScroll = true;
          scrollDelta = 250;
        };
        windowManager = {
          default = "xmonad";
          xmonad = {
            enable = true;
            enableContribAndExtras = true;
          };
        };
        desktopManager = {
          xterm.enable = false;
          default = "none";
        };
        displayManager.lightdm = {
          enable = true;
          background = wallpaper;
          autoLogin.enable = true;
          autoLogin.user = username;
        };
      };


      # shared config
      security.sudo.enable = true;
      security.sudo.wheelNeedsPassword = true;
      security.sudo.extraConfig = ''
        ALL ALL = (root) NOPASSWD: ${pkgs.iw}/bin/iw
        ALL ALL = (root) NOPASSWD: ${pkgs.light}/bin/light
        ALL ALL = (root) NOPASSWD: ${pkgs.systemd}/bin/shutdown
        ALL ALL = (root) NOPASSWD: ${pkgs.systemd}/bin/reboot
      '';

      # shared config
      users.extraUsers."${username}" = {
        isNormalUser = true;
        uid = 1000;
        home = builtins.toPath "/home/${username}";
        extraGroups = [
          "wheel"
          "docker"
          "networkmanager"
          "messagebus"
          "systemd-journal"
          "disk"
          "audio"
          "video"
        ];
        createHome = true;
        shell = pkgs.fish;
      };


      # shared config
      fonts = {
        fontconfig.enable = true;
        fontconfig.dpi = 180;
        enableFontDir = true;
        enableGhostscriptFonts = true;
        fonts = with pkgs; [
          pragmatapro
          source-code-pro
          emojione
          font-awesome-ttf
        ];
      };

      # shared config
      virtualisation.docker.enable = true;

      # shared config
      services.keybase.enable = true;
      services.kbfs = {
        enable = true;
        mountPoint = "/keybase";
      };

      # shared config
      services.compton = {
        enable = true;
        # refreshRate = 144;
        inactiveOpacity = "0.95";
        menuOpacity = "0.8";
        fade = true;
        fadeDelta = 3;
        shadow = true;
        shadowOffsets = [ (-8) (-8) ];
        # shadowOpacity = ".5";
        fadeSteps = ["0.25" "0.25"];
        vSync = "opengl-swc";
        extraOptions = ''
          unredir-if-possible = true;
          no-dock-shadow = true;
          clear-shadow = true;
          shadow-radius = 10;
          detect-rounded-corners = true;
          shadow-ignore-shaped = true;
          # Window type settings
          wintypes:
          {
            notify = { fade = true; shadow = true; opacity = 0.9; focus = true; };
            tooltip = { fade = true; shadow = true; opacity = 0.9; focus = true; };
          };
        '';
      };

      # shared config
      services.actkbd.enable = true;
      services.actkbd.bindings = [
        { keys = [ 224 ]; events = [ "key" "rep" ]; command = "${pkgs.light}/bin/light -U 4"; }
        { keys = [ 225 ]; events = [ "key" "rep" ]; command = "${pkgs.light}/bin/light -A 4"; }
        { keys = [ 229 ]; events = [ "key" "rep" ]; command = "${pkgs.kbdlight}/bin/kbdlight down"; }
        { keys = [ 230 ]; events = [ "key" "rep" ]; command = "${pkgs.kbdlight}/bin/kbdlight up"; }
      ];

      # shared config
      services.logind.extraConfig = ''
          HandlePowerKey=suspend
        '';
      # shared config
      services.redshift = {
        enable = true;
        latitude = "54.372158";
        longitude = "18.638306";
      };
      programs.browserpass.enable = true;
      services.avahi = {
        enable = true;
        nssmdns = true;
      };
      services.dunst.enable = true;
      services.autocutsel.enable = true;
      services.udiskie.enable = true;

      # shared config - packages with config
      nixpkgs.config.packageOverrides = pkgs : rec {
        bluez = pkgs.bluez5;
        rofi = import ../rofi/rofi.nix { inherit pkgs; terminal = "urxvt"; };
        urxvt = import ../urxvt/urxvt.nix { inherit pkgs; };
        dunst = import ../dunst/dunst.nix { inherit pkgs; browser = "firefox"; };
        stalonetray = import ../stalonetray/stalonetray.nix { inherit pkgs; };
      };
    } // extras;
}
