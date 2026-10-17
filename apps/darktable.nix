{ lib, common }:
let
  render = p: common.defineColors (common.roles p {
    background = "bg_color bauhaus_bg field_bg field_selected_fg scroll_bar_bg";
    surface = "plugin_bg_color button_bg field_active_bg tooltip_bg_color";
    raised = "collapsible_bg_color bauhaus_bg_hover button_hover_bg";
    border = "border_color bauhaus_border button_border scroll_bar_inactive";
    foreground = lib.concatStringsSep " " [
      "fg_color base_color text_color section_label tooltip_fg_color"
      "bauhaus_fg bauhaus_fg_hover button_fg button_hover_fg field_fg field_active_fg"
    ];
    muted = "plugin_label_color disabled_fg_color placeholder_text_color scroll_bar_active";
    blue = "selected_bg_color bauhaus_fill field_selected_bg";
    yellow = "bauhaus_fg_selected";
  });
in {
  label = "darktable";
  options = {
    variant = lib.mkOption {
      type = lib.types.enum [ "dark" "light" ];
      default = "dark";
      description = "Fixed darktable variant; darktable does not natively switch these CSS tweaks with the system.";
    };
    extraCss = lib.mkOption { type = lib.types.lines; default = ""; description = "Additional darktable CSS tweaks."; };
  };
  config = { target, ... }: {
    xdg.configFile = {
      "darktable/user.css".text = render common.palettes.${target.variant} + target.extraCss;
      "darktable/darktablerc-common".text = lib.mkAfter "themes/usercss=TRUE\n";
    };
  };
}
