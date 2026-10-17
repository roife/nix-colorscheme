{ lib, common }:
let
  inherit (common) names;
in {
  label = "digiKam";
  platform = "Linux";
  native = {
    digikamrc."General Settings".Theme = "";
  };
  # digiKam matches the KDE ColorScheme ID against General/Name.
  config = _: {
    xdg.dataFile = lib.mapAttrs' (mode: palette:
      lib.nameValuePair "digikam/colorschemes/${names.${mode}}.colors" {
        text = common.kde (palette // { name = names.${mode}; });
      }) common.palettes;
  };
}
