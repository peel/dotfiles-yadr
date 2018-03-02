{ config, pkgs, ... }:

{
  programs.tmux.tmuxConfig = ''
    # Bigger history
    set -g history-limit 10000

    #### status and window appearance and style
    set-option -g status-justify "left"
    set-option -g status-left-length 200
    set-option -g status-right-length 200
    set -g status-fg brightwhite
    set -g status-bg black
    set -g pane-border-fg blue
    set -g pane-active-border-fg blue
    set -g message-fg black
    set -g message-bg white
    set -g message-attr bold

    # start indexing windows from 1, just like tabs
    set -g base-index 1
    setw -g pane-base-index 1

    #### status bar
    setw -g window-status-format "#[bg=black, fg=cyan, noreverse] #I #[bg=brightblack, fg=brightcyan, noreverse] #W "
    setw -g window-status-current-format "#[bg=brightblue, fg=white, noreverse] #I #[fg=brightcyan, bg=brightgreen] #W "
    setw -g window-status-current-attr dim
    setw -g window-status-bg green
    setw -g window-status-fg black
    set -g window-status-attr reverse
    set -g window-status-activity-attr bold

    set-option -g status-left '#[fg=black, fg=cyan, noreverse]λ '
    set-option -g status-right "#(~/.tmux/prompt.sh right)"

    #### bindings
    # screen prefix
    unbind C-b
    set -g prefix C-a
    bind a send-prefix

    # resize panes
    bind-key -r < resize-pane -L 5
    bind-key -r > resize-pane -R 5
    bind-key -r + resize-pane -U 10
    bind-key -r = resize-pane -D 10

    # visual notification of activity in other windows
    setw -g monitor-activity on
    set -g visual-activity on

    # splits and vertical splits
    bind-key | split-window -h -p 50 -c "#{pane_current_path}"
    bind-key - split-window -p 50 -c "#{pane_current_path}"

    # force a reload of the config file
    unbind r
    bind r source-file ~/.tmux.conf \; display "Reloaded!"
    # quick pane cycling
    unbind ^A
    bind ^A select-pane -t :.+

    set -g @tpm_plugins '             \
      tmux-plugins/tpm                \
      tmux-plugins/tmux-resurrect     \
      tmux-plugins/tmux-yank          \
      tmux-plugins/tmux-copycat       \
    '

    run '~/.tmux/plugins/tpm/tpm'
  '';
  programs.tmux.enableSensible = true;
  programs.tmux.enableMouse = true;
  programs.tmux.enableVim = true;
  programs.bash.enable = true;
  services.mopidy.package = "/usr/local";
  services.mopidy.enable = true;
  services.mopidy.mediakeys.package = "/usr/local";
  services.mopidy.mediakeys.enable = true;

  environment.variables.HOMEBREW_CASK_OPTS = "--appdir=/Applications/cask";
  environment.variables.TERMINFO = "/usr/share/terminfo";

  system.defaults = {
    dock = {
      autohide = true;
      orientation = "bottom";
      showhidden = true;
    };
    finder = {
      AppleShowAllExtensions = true;
      FXEnableExtensionChangeWarning = false;
    };
  };
  services.activate-system.enable = true;
  services.nix-daemon.enable = true;
  services.chunkwm.enable = true;
  services.chunkwm.package = pkgs.chunkwm.core;
  services.chunkwm.plugins.dir = "/run/current-system/sw/bin/chunkwm-plugins/";
  services.chunkwm.plugins."tiling".config = ''
    chunkc set desktop_padding_step_size     0
    chunkc set desktop_gap_step_size         0
    chunkc set global_desktop_offset_top     0
    chunkc set global_desktop_offset_bottom  0
    chunkc set global_desktop_offset_left    0
    chunkc set global_desktop_offset_right   0
    chunkc set global_desktop_offset_gap     0
    chunkc set bsp_spawn_left                1
    chunkc set bsp_optimal_ratio             1.618
    chunkc set bsp_split_mode                optimal
    chunkc set bsp_split_ratio               0.66
    chunkc set window_focus_cycle            all
    chunkc set mouse_follows_focus           1
    chunkc set window_region_locked          1
  '';
  services.chunkwm.extraConfig = ''
    chunkc tiling::rule --owner Emacs --state tile
    chunkc tiling::rule --owner Emacs.* --state tile
    chunkc tiling::rule --owner .*Emacs --state tile
  '';
  services.skhd.enable = true;
  services.skhd.package =  pkgs.skhd;
  services.skhd.skhdConfig = ''
    #  NOTE(koekeishiya): A list of all built-in modifier and literal keywords can
    #                     be found at https://github.com/koekeishiya/skhd/issues/1
    #
    #                     A hotkey is written according to the following rules:
    #
    #                       hotkey   = <keysym> ':' <command> |
    #                                  <keysym> '->' ':' <command>
    #
    #                       keysym   = <mod> '-' <key> | <key>
    #
    #                       mod      = 'built-in mod keyword' | <mod> '+' <mod>
    #
    #                       key      = <literal> | <keycode>
    #
    #                       literal  = 'single letter or built-in keyword'
    #
    #                       keycode  = 'apple keyboard kVK_<Key> values (0x3C)'
    #
    #                       ->       = keypress is not consumed by skhd
    #
    #                       command  = command is executed through '$SHELL -c' and
    #                                  follows valid shell syntax. if the $SHELL environment
    #                                  variable is not set, it will default to '/bin/bash'.
    #                                  when bash is used, the ';' delimeter can be specified
    #                                  to chain commands.
    #
    #                                  to allow a command to extend into multiple lines,
    #                                  prepend '\' at the end of the previous line.
    #
    #                                  an EOL character signifies the end of the bind.


    # restart chunkwm
    cmd + alt + ctrl - q : killall chunkwm

    # open terminal, blazingly fast compared to iTerm/Hyper
    cmd - return : open -na /Applications/iTerm.app

    # close focused window
    alt - w : chunkc tiling::window --close

    # focus window
    alt - h : chunkc tiling::window --focus west
    alt - j : chunkc tiling::window --focus south
    alt - k : chunkc tiling::window --focus north
    alt - l : chunkc tiling::window --focus east

    cmd - j : chunkc tiling::window --focus prev
    cmd - k : chunkc tiling::window --focus next

    # equalize size of windows
    shift + alt - 0 : chunkc tiling::desktop --equalize

    # swap window
    shift + alt - h : chunkc tiling::window --swap west
    shift + alt - j : chunkc tiling::window --swap south
    shift + alt - k : chunkc tiling::window --swap north
    shift + alt - l : chunkc tiling::window --swap east

    # move window
    shift + cmd - h : chunkc tiling::window --warp west
    shift + cmd - j : chunkc tiling::window --warp south
    shift + cmd - k : chunkc tiling::window --warp north
    shift + cmd - l : chunkc tiling::window --warp east

    # make floating window fill screen
    shift + alt - up     : chunkc tiling::window --grid-layout 1:1:0:0:1:1

    # make floating window fill left-half of screen
    shift + alt - left   : chunkc tiling::window --grid-layout 1:2:0:0:1:1

    # make floating window fill right-half of screen
    shift + alt - right  : chunkc tiling::window --grid-layout 1:2:1:0:1:1

    # send window to desktop
    shift + alt - x : chunkc tiling::window --send-to-desktop $(chunkc get _last_active_desktop)
    shift + alt - z : chunkc tiling::window --send-to-desktop prev
    shift + alt - c : chunkc tiling::window --send-to-desktop next
    shift + alt - 1 : chunkc tiling::window --send-to-desktop 1
    shift + alt - 2 : chunkc tiling::window --send-to-desktop 2
    shift + alt - 3 : chunkc tiling::window --send-to-desktop 3
    shift + alt - 4 : chunkc tiling::window --send-to-desktop 4
    shift + alt - 5 : chunkc tiling::window --send-to-desktop 5
    shift + alt - 6 : chunkc tiling::window --send-to-desktop 6

    # focus monitor
    ctrl + alt - z  : chunkc tiling::monitor -f prev
    ctrl + alt - c  : chunkc tiling::monitor -f next
    ctrl + alt - 1  : chunkc tiling::monitor -f 1
    ctrl + alt - 2  : chunkc tiling::monitor -f 2
    ctrl + alt - 3  : chunkc tiling::monitor -f 3

    # send window to monitor and follow focus
    ctrl + cmd - z  : chunkc tiling::window --send-to-monitor prev; chunkc tiling::monitor -f prev
    ctrl + cmd - c  : chunkc tiling::window --send-to-monitor next; chunkc tiling::monitor -f next
    ctrl + cmd - 1  : chunkc tiling::window --send-to-monitor 1; chunkc tiling::monitor -f 1
    ctrl + cmd - 2  : chunkc tiling::window --send-to-monitor 2; chunkc tiling::monitor -f 2
    ctrl + cmd - 3  : chunkc tiling::window --send-to-monitor 3; chunkc tiling::monitor -f 3

    # increase region size
    shift + alt - a : chunkc tiling::window --use-temporary-ratio 0.1 --adjust-window-edge west
    shift + alt - s : chunkc tiling::window --use-temporary-ratio 0.1 --adjust-window-edge south
    shift + alt - w : chunkc tiling::window --use-temporary-ratio 0.1 --adjust-window-edge north
    shift + alt - d : chunkc tiling::window --use-temporary-ratio 0.1 --adjust-window-edge east

    # decrease region size
    shift + cmd - a : chunkc tiling::window --use-temporary-ratio -0.1 --adjust-window-edge west
    shift + cmd - s : chunkc tiling::window --use-temporary-ratio -0.1 --adjust-window-edge south
    shift + cmd - w : chunkc tiling::window --use-temporary-ratio -0.1 --adjust-window-edge north
    shift + cmd - d : chunkc tiling::window --use-temporary-ratio -0.1 --adjust-window-edge east

    # set insertion point for focused container
    ctrl + alt - f : chunkc tiling::window --use-insertion-point cancel
    ctrl + alt - h : chunkc tiling::window --use-insertion-point west
    ctrl + alt - j : chunkc tiling::window --use-insertion-point south
    ctrl + alt - k : chunkc tiling::window --use-insertion-point north
    ctrl + alt - l : chunkc tiling::window --use-insertion-point east

    # rotate tree
    alt - r : chunkc tiling::desktop --rotate 90

    # mirror tree y-axis
    alt - y : chunkc tiling::desktop --mirror vertical

    # mirror tree x-axis
    alt - x : chunkc tiling::desktop --mirror horizontal

    # toggle desktop offset
    alt - a : chunkc tiling::desktop --toggle offset

    # toggle window fullscreen
    alt - f : chunkc tiling::window --toggle fullscreen

    # toggle window native fullscreen
    shift + alt - f : chunkc tiling::window --toggle native-fullscreen

    # toggle window parent zoom
    alt - d : chunkc tiling::window --toggle parent

    # toggle window split type
    alt - e : chunkc tiling::window --toggle split

    # float / unfloat window and center on screen
    alt - t : chunkc tiling::window --toggle float;\
              chunkc tiling::window --grid-layout 4:4:1:1:2:2

    # toggle sticky, float and resize to picture-in-picture size
    alt - s : chunkc tiling::window --toggle sticky;\
              chunkc tiling::window --grid-layout 5:5:4:0:1:1

    # float next window to be tiled
    shift + alt - t : chunkc set window_float_next 1

    # change layout of desktop
    ctrl + alt - a : chunkc tiling::desktop --layout bsp
    ctrl + alt - s : chunkc tiling::desktop --layout monocle
    ctrl + alt - d : chunkc tiling::desktop --layout float

    ctrl + alt - w : chunkc tiling::desktop --deserialize ~/.chunkwm_layouts/dev_1
  '';
}
