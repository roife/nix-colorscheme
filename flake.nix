{
  description = "Gruvbox colors for Home Manager applications on Linux and macOS";

  outputs = _: {
    homeModules.default = { config, options, pkgs, lib, ... }@args:
    let
      inherit (import ./common.nix { inherit lib; }) apps;
      cfg = config.colorscheme;
      host = pkgs.stdenv.hostPlatform;
      hasPlasmaManager = options.programs ? plasma;
      appArgs = name: args // { target = cfg.${name}; };
    in {
      config = lib.mkMerge (lib.mapAttrsToList (name: app:
        lib.mkIf cfg.${name}.enable (lib.mkMerge [
          (app.config (appArgs name))
          {
            assertions = lib.optional (app ? platform) {
              assertion = { Linux = host.isLinux; macOS = host.isDarwin; }.${app.platform};
              message = "colorscheme: ${app.label} integration is only supported on ${app.platform}.";
            } ++ lib.optional (app ? native) {
              assertion = !host.isLinux || hasPlasmaManager;
              message = "colorscheme: import plasma-manager.homeModules.plasma-manager for native ${app.label} settings.";
            };
          }
          # Native KDE settings are declared through plasma-manager when its module is imported.
          (lib.optionalAttrs (hasPlasmaManager && app ? native) {
            programs.plasma = lib.mkIf host.isLinux {
              enable = lib.mkDefault true;
              configFile = app.native;
            };
          })
        ])) apps);

      options.colorscheme = lib.mapAttrs (_: app:
        { enable = lib.mkEnableOption "${app.label} colors"; }
        // (app.options or { })) apps;
    };
  };
}
