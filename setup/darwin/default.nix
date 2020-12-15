{ config, pkgs, ... }:

let
  home = builtins.getEnv "HOME";
in {
  imports = [
    ./config.nix
    ../common
    ./defaults.nix
    ./keyboard.nix
    ./wm.nix
    ./bloop.nix
  ];

  environment.shellAliases = {
    o = "open";
    darwin-rebuild = "darwin-rebuild --option extra-builtins-file ${home}/.config/nixpkgs/setup/common/secrets/extra-builtins.nix";
  };

  nix.package = pkgs.nixFlakes;
  nix.extraOptions = ''
    builders = @/etc/nix/machines
    experimental-features = nix-command flakes
  '';

  networking.knownNetworkServices = ["Wi-Fi" "Bluetooth PAN" "Thunderbolt Bridge"];
  networking.dns = ["1.1.1.1" "1.0.0.1" "2606:4700:4700::1111" "2606:4700:4700::1001"];
  
  services.activate-system.enable = true;
  services.nix-daemon.enable = true;
  programs.nix-index.enable = true;

  peel.keybindings.mappings  = {
    "C-l" = "centerSelectionInVisibleArea:";
    "C-/" = "undo:";
    "C- " = "setMark:";
    "C-w" = "deleteToMark:";
    "M-f" = "moveWordForward:";
    "M-b" = "moveWordBackward:";
    "M-<" = "moveToBeginningOfDocument:";
    "M->" = "moveToEndOfDocument:";
    "M-v" = "pageUp:";
    "M-/" = "complete:";
    "M-c" = [ "capitalizeWord:" "moveForward:" "moveForward:"];
    "M-u" = [ "uppercaseWord:" "moveForward:" "moveForward:"];
    "M-l" = [ "lowercaseWord:" "moveForward:" "moveForward:"];
    "M-d" = "deleteWordForward:";
    "C-M-h" = "deleteWordBackward:";
    "M-Bksp" = "deleteWordBackward:";
    "M-t" = "transposeWords:";
    "M-\@" = ["setMark:" "moveWordForward:" "swapWithMark"];
    "M-h" = ["setMark:" "moveToEndOfParagraph:" "swapWithMark"];
    "C-x" = {
      "h" = "selectAll:";
      "k" = "performClose:";
      "u" = "undo:";
      "C-f" = "openDocument:";
      "C-x" = "swapWithMark:";
      "C-m" = "selectToMark:";
      "C-s" = "saveDocument:";
      "C-w" = "saveDocumentAs:";
    };
  };
}
