{ lib, ... }:
{
  label = "Chromium";
  platform = "Linux";
  native = lib.genAttrs [ "gtk-3.0/settings.ini" "gtk-4.0/settings.ini" ] (_: {
    Settings.gtk-theme-name = "Breeze";
  }) // {
    kded6rc."Module-gtkconfig".autoload = true;
  };
  config = { pkgs, ... }: {
    xdg.dataFile."themes/Breeze" = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
      source = "${pkgs.kdePackages.breeze-gtk}/share/themes/Breeze";
      recursive = true;
    };
  };
}
