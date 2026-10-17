{ lib, common }:
let
  inherit (common) palettes;
  rules = p: ''
    :root {
    ${lib.concatStrings (lib.mapAttrsToList (name: hex: "  --${name}: #${hex} !important;\n") (common.roles p {
      background = "lwt-accent-color toolbar-field-background-color sidebar-background-color";
      surface = "toolbar-bgcolor tab-selected-bgcolor arrowpanel-background";
      raised = "toolbar-field-focus-background-color";
      border = "arrowpanel-border-color chrome-content-separator-color";
      blue = "toolbar-field-focus-border-color tab-line-color focus-outline-color";
      foreground = lib.concatStringsSep " " [
        "lwt-text-color toolbar-color toolbar-field-color toolbar-field-focus-color"
        "tab-selected-textcolor arrowpanel-color sidebar-text-color"
      ];
    }))}}
    #navigator-toolbox, #TabsToolbar {
      background-color: #${p.background} !important;
      color: #${p.foreground} !important;
    }
    #nav-bar, #PersonalToolbar, .tab-background[selected] {
      background-color: #${p.surface} !important;
      color: #${p.foreground} !important;
    }
  '';
  render = ''
      @media (prefers-color-scheme: light) { ${rules palettes.light} }
      @media (prefers-color-scheme: dark) { ${rules palettes.dark} }
    '';
in {
  label = "Firefox";
  options = {
    profiles = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Home Manager Firefox profile names to style. No profiles are discovered on disk.";
    };
  };
  config = { target, config, ... }: {
    assertions = [
      { assertion = config.programs.firefox.enable;
        message = "colorscheme: enable programs.firefox separately; use package = null to configure a system Firefox."; }
      { assertion = target.profiles != [ ];
        message = "colorscheme: explicitly set colorscheme.firefox.profiles."; }
    ];
    programs.firefox = {
      profiles =
        (lib.genAttrs target.profiles (_: {
          userChrome = lib.mkAfter render;
          settings = {
            "layout.css.prefers-color-scheme.content-override" = 2;
          };
        }));
    };
  };
}
