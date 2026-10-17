{ lib, common }:
let
  inherit (common) lookAndFeel names;
in {
  label = "KDE Plasma";
  platform = "Linux";
  native = {
    kdeglobals.KDE = {
      AutomaticLookAndFeel = true;
      DefaultLightLookAndFeel = lookAndFeel.light;
      DefaultDarkLookAndFeel = lookAndFeel.dark;
    };
    kded6rc."Module-lookandfeelautoswitcher".autoload = true;
  };
  config = _: {
    xdg.dataFile = lib.concatMapAttrs (mode: palette: let id = lookAndFeel.${mode}; in {
      "color-schemes/${names.${mode}}.colors".text = common.kde palette;
      "plasma/look-and-feel/${id}/metadata.json".text = builtins.toJSON {
        KPackageStructure = "Plasma/LookAndFeel";
        KPlugin = { Id = id; Name = palette.name; Description = "Gruvbox color scheme"; };
      };
      "plasma/look-and-feel/${id}/contents/defaults".text =
        lib.generators.toINI { } { "kdeglobals][General".ColorScheme = names.${mode}; };
    }) common.palettes;
  };
}
