{ lib, common }:
let
  inherit (common) names;
  render = p: lib.generators.toINI { } ({
    General = { Description = p.name; Opacity = 1; Blur = false; ColorRandomization = false; };
  } // lib.mapAttrs (_: hex: { Color = lib.concatMapStringsSep "," toString (common.rgb hex); }) (common.roles p {
    background = "Background BackgroundIntense BackgroundFaint";
    foreground = "Foreground ForegroundIntense";
    muted = "ForegroundFaint";
  } // lib.mergeAttrsList (lib.genList (i:
    let key = "Color${toString i}"; ansi = builtins.elemAt p.ansi i;
    in { ${key} = ansi; "${key}Faint" = ansi; "${key}Intense" = builtins.elemAt p.bright i; }) 8)));
in {
  label = "Konsole";
  platform = "Linux";
  native = {
    konsolerc = {
      # Konsole resolves these by General/Name, not by profile filename.
      LightDarkTheme = {
        SyncProfileWithSystemTheme = true;
        LightThemeProfile = names.light;
        DarkThemeProfile = names.dark;
      };
    };
  };
  config = _: {
    xdg.dataFile = lib.mkMerge (lib.mapAttrsToList (mode: palette: {
      "konsole/${names.${mode}}.colorscheme".text = render palette;
      "konsole/${names.${mode}}.profile" = {
        text = lib.generators.toINI { } {
          General = { Name = names.${mode}; Parent = "FALLBACK/"; };
          Appearance.ColorScheme = names.${mode};
        };
      };
    }) common.palettes);
  };
}
