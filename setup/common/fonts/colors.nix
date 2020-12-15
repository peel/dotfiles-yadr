{ theme ? "dark" }:

let themes = rec {

  "dark" = themes."gotham";
  "light" = themes."nord-light";

  # https://github.com/wasamasa/gotham-theme
  "gotham" = rec {
    dark = true;
    foreground =   "#98d1ce";
    background =   "#0a0f14";
    cursorColor =  "#98d1ce";

    #black
    black   = color0;
    color0  = "#0a0f14";
    color8  = "#10151b";
    #red
    red     = color1;
    color1  = "#c33027";
    color9  = "#d26939";
    #green
    green   = color2;
    color2  = "#26a98b";
    color10 = "#081f2d";
    #yellow
    yellow  = color3;
    color3  = "#edb54b";
    color11 = "#245361";
    #blue
    blue    = color4;
    color4  = "#195465";
    color12 = "#093748";
    #magenta
    magenta = color5;
    color5  = "#4e5165";
    color13 = "#888ba5";
    #cyan
    cyan    = color6;
    color6  = "#33859d";
    color14 = "#599caa";
    #white
    white   = color7;
    color7  = "#98d1ce";
    color15 = "#d3ebe9";
  };
  "gotham-light" = themes."gotham" // {
    dark = false;
  };

  # https://arcticicestudio.github.io/nord/
  "nord" = rec {
    dark = true;
    foreground =   "#3B4252";
    background =   "#E5E9F0";
    cursorColor =  "#2E3440";

    #black
    black   = color0;
    color0  = "#2E3440";
    color8  = "#4C566A";
    #red
    red     = color1;
    color1  = "#BF616A";
    color9  = "#BF616A";
    #green
    green   = color2;
    color2  = "#A3BE8C";
    color10 = "#A3BE8C";
    #yellow
    yellow  = color3;
    color3  = "#EBCB8B";
    color11 = "#EBCB8B";
    #blue
    blue    = color4;
    color4  = "#81A1C1";
    color12 = "#81A1C1";
    #magenta
    magenta = color5;
    color5  = "#B48EAD";
    color13 = "#B48EAD";
    #cyan
    cyan    = color6;
    color6  = "#88C0D0";
    color14 = "#8FBCBB";
    #white
    white   = color7;
    color7  = "#E5E9F0";
    color15 = "#ECEFF4";
  };
  "nord-light" = themes."nord" // {
    dark = false;
    foreground =   "#D8DEE9";
    background =   "#2E3440";
    cursorColor =  "#D8DEE9";
  };

}; in themes.${theme} or themes."gotham"

