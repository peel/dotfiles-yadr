{ config, pkgs, lib, ... }:

with (import ./setup/make-configuration.nix {inherit config pkgs lib; }); mkConfiguration {
  username = "peel";
  hostName = "fff66602";
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
}
