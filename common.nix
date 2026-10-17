{ lib }:
let
  # Gruvbox. The accents double as the bright ANSI colors; ANSI 1-6 are shared by both variants.
  palettes = builtins.mapAttrs (_: p: p // {
    ansi = [ p.background "cc241d" "98971a" "d79921" "458588" "b16286" "689d6a" p.muted ];
    bright = [ "928374" p.red p.green p.yellow p.blue p.purple p.aqua p.foreground ];
  }) {
    dark = {
      name = "Gruvbox Dark"; background = "282828"; surface = "3c3836"; raised = "504945"; border = "665c54";
      foreground = "ebdbb2"; muted = "a89984"; orange = "fe8019";
      red = "fb4934"; green = "b8bb26"; yellow = "fabd2f"; blue = "83a598"; purple = "d3869b"; aqua = "8ec07c";
    };
    light = {
      name = "Gruvbox Light"; background = "fbf1c7"; surface = "ebdbb2"; raised = "d5c4a1"; border = "bdae93";
      foreground = "3c3836"; muted = "7c6f64"; orange = "af3a03";
      red = "9d0006"; green = "79740e"; yellow = "b57614"; blue = "076678"; purple = "8f3f71"; aqua = "427b58";
    };
  };
  common = {
    inherit palettes;
    names = { light = "NixGruvboxLight"; dark = "NixGruvboxDark"; };
    lookAndFeel = { light = "org.nix-colorscheme.gruvbox.light"; dark = "org.nix-colorscheme.gruvbox.dark"; };

    # Each file returns { label; platform?; options?; config; native?; }, wired up by flake.nix.
    apps = lib.genAttrs [ "darktable" "chromium" "plasma" "konsole" "digikam" "squirrel" "firefox" ]
      (name: import ./apps/${name}.nix { inherit lib common; });

    rgb = hex: map (offset: lib.fromHexString (builtins.substring offset 2 hex)) [ 0 2 4 ];
    # Expands { role = "key key"; } into { key = p.role; }: formats reuse a few roles for many keys.
    roles = p: lib.concatMapAttrs (role: keys: lib.genAttrs (lib.splitString " " keys) (_: p.${role}));
    defineColors = colors: lib.concatStrings (lib.mapAttrsToList (name: hex: "@define-color ${name} #${hex};\n") colors);

    # Plasma and digiKam consume the same KDE color-scheme format.
    kde = p:
      let
        colors = background: foreground: lib.mapAttrs (_: hex: "#${hex}") ({
          BackgroundNormal = background;
          ForegroundNormal = foreground;
        } // common.roles p {
          surface = "BackgroundAlternate";
          muted = "ForegroundInactive";
          orange = "ForegroundActive";
          blue = "ForegroundLink DecorationFocus";
          purple = "ForegroundVisited";
          red = "ForegroundNegative";
          yellow = "ForegroundNeutral";
          green = "ForegroundPositive";
          aqua = "DecorationHover";
        });
      in lib.generators.toINI { } (
        lib.genAttrs [ "Colors:Window" "Colors:View" ] (_: colors p.background p.foreground)
        // lib.genAttrs [ "Colors:Button" "Colors:Complementary" "Colors:Header" ] (_: colors p.surface p.foreground)
        // {
          General = { Name = p.name; shadeSortColumn = true; };
          KDE.contrast = 4;
          "Colors:Selection" = colors p.blue p.background // { BackgroundAlternate = "#${p.blue}"; };
          "Colors:Tooltip" = colors p.raised p.foreground;
          "ColorEffects:Disabled" = { Enable = true; ColorEffect = 0; ContrastEffect = 1; ContrastAmount = 0.55; IntensityEffect = 0; };
          "ColorEffects:Inactive" = { Enable = false; ChangeSelectionColor = true; };
          WM = {
            activeBackground = "#${p.surface}";
            activeForeground = "#${p.foreground}";
            inactiveBackground = "#${p.background}";
            inactiveForeground = "#${p.muted}";
          };
        });
  };
in
common
