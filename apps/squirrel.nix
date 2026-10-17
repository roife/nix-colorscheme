{ lib, common }:
let
  inherit (common) names;
  bgr = hex: "0x${builtins.substring 4 2 hex}${builtins.substring 2 2 hex}${builtins.substring 0 2 hex}";
  render = p: { inherit (p) name; author = "nix-colorscheme"; } // lib.mapAttrs (_: bgr) (common.roles p {
    background = "back_color hilited_candidate_text_color hilited_comment_text_color hilited_candidate_label_color";
    surface = "hilited_back_color";
    border = "border_color";
    foreground = "text_color candidate_text_color hilited_text_color";
    muted = "comment_text_color label_color";
    blue = "hilited_candidate_back_color";
  });
in {
  label = "Squirrel";
  platform = "macOS";
  options = {
    extraPatch = lib.mkOption {
      type = lib.types.attrsOf lib.types.anything;
      default = { };
      description = "Other squirrel.custom.yaml patches, merged with the theme.";
    };
  };
  config = { target, pkgs, ... }: {
    home.file."Library/Rime/squirrel.custom.yaml".source =
      (pkgs.formats.yaml { }).generate "squirrel.custom.yaml" {
        patch = lib.recursiveUpdate target.extraPatch {
          style = {
            color_scheme = names.light;
            color_scheme_dark = names.dark;
          };
          preset_color_schemes = lib.mapAttrs' (mode: palette:
            lib.nameValuePair names.${mode} (render palette)) common.palettes;
        };
      };
  };
}
