{ config, pkgs, ...}:

let
  vtermIntegration = ''
    __vterm_printf(){
    # https://github.com/akermu/emacs-libvterm#shell-side-configuration
        if [ -n "$TMUX" ]; then
            printf "\ePtmux;\e\e]%s\007\e\\" "$1"
        elif [ "''${TERM%%-*}" = "screen" ]; then
            printf "\eP\e]%s\007\e\\" "$1"
        else
            printf "\e]%s\e\\" "$1"
        fi
    }
  '';
  vtermClearScrollback = ''
    if [[ "$INSIDE_EMACS" = 'vterm' ]]; then
        function clear(){
            __vterm_printf "51;Evterm-clear-scrollback";
            tput clear;
        }
    fi
  '';
  vtermPromptTracking = ''
    vterm_prompt_end(){
        __vterm_printf "51;A$(whoami)@$(hostname):$(pwd)"
    }
    PS1=$PS1'\[$(vterm_prompt_end)\]'
  '';
in {
  environment.shells = [ pkgs.bashInteractive  ];
  environment.systemPackages = [
    pkgs.coreutils
    pkgs.ripgrep
  ];
  environment.variables.SHELL = "/run/current-system/sw/bin/bash";
  programs.bash = {
    enableCompletion = true;
    interactiveShellInit = ''
      shopt -s checkwinsize # track terminal window resize
      shopt -s extglob      # extended globbing capabilities
      shopt -s cdspell      # fix minor typos when cd'ing
      shopt -s cmdhist      # preserve new lines in history
      if [[ $BASH_VERSION == 4* ]] ; then
        shopt -s autocd       # type 'dir' instead 'cd dir'
        shopt -s dirspell     # correct typos when tab-completing names
        shopt -s globstar     # enable **
      fi
      
      __prompt_nix() {
        [ -z "$IN_NIX_SHELL" ] && echo "λ" || echo ""
      }
      PS1='\W$(__git_ps1 " - %s") $(__prompt_nix) '
      ${vtermIntegration}
      ${vtermClearScrollback}
      ${vtermPromptTracking}
    '';
  };

  environment.shellAliases = {
    d = "docker";
    dc = "docker-compose";
    less = "less -R";
    ls = "ls -Gh";
    ll = "ls -al";
    df = "df -h";
    ns = "nix-shell";
  };
  
}
