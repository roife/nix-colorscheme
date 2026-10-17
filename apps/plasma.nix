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
  config = { pkgs, ... }: {
    xdg.dataFile = lib.concatMapAttrs (mode: palette: let
      id = lookAndFeel.${mode};
      metadata = pkgs.writeText "${id}-metadata.json" (builtins.toJSON {
        KPackageStructure = "Plasma/LookAndFeel";
        KPlugin = { Id = id; Name = palette.name; Description = "Gruvbox color scheme"; };
      });
      defaults = pkgs.writeText "${id}-defaults" (
        lib.generators.toINI { mkSectionName = name: name; } {
          "kdeglobals][General".ColorScheme = names.${mode};
        });
      colors = pkgs.writeText "${id}-colors" (common.kde palette);
    in {
      "color-schemes/${names.${mode}}.colors".text = common.kde palette;
      # KPackage rejects files whose symlinks resolve outside the package root.
      # Link the entire directory; its contents must be real files inside it.
      "plasma/look-and-feel/${id}".source = pkgs.runCommand id { } ''
        mkdir -p "$out/contents"
        cp ${metadata} "$out/metadata.json"
        cp ${defaults} "$out/contents/defaults"
        cp ${colors} "$out/contents/colors"
      '';
    }) common.palettes;
  };
}
