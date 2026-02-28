{ self, ... }:
{
    config,
    lib,
    pkgs,
    niri-unstable,
    niri-unstable-blur,
    ...
}:
with lib;
let
    cfg = config.wayland.windowManager.niri;
    variants = {
        stable = pkgs.niri;
        unstable = niri-unstable.packages.${pkgs.stdenv.hostPlatform.system}.niri;
        unstable-blur = niri-unstable-blur.packages.${pkgs.stdenv.hostPlatform.system}.niri;
    };
in
{
    options.wayland.windowManager.niri = {
        enable = mkEnableOption "Niri, a scrollable tiling Wayland compositor";

        variant = mkOption {
            type = types.nullOr (types.enum [
                "stable"
                "unstable"
                "unstable-blur"
            ]);
            default = null;
            description = ''
                Which supported variant to choose, if not overridden by `programs.niri.package`.
                - stable: use niri stable from nixpkgs
                - unstable: build niri from the repository's main branch
                - unstable-blur: build niri with the unstable blur branch
            '';
        };
        package = mkOption {
            type = types.nullOr types.package;
            default = if isNull cfg.variants then null else variants.${cfg.variants};
            description = "Custom niri package to use. If specified, this overrides `programs.niri.variant`";
        };

        _raw_settings = mkOption {
            type =
                with lib.types;
                let
                    valueType =
                        nullOr (oneOf [
                            bool
                            int
                            float
                            str
                            path
                            (attrsOf valueType)
                            (listOf valueType)
                        ])
                        // {
                            description = "Niri configuration value";
                        };
                in
                types.submodule {
                    freeformType = valueType;
                };
            default = { };
            description = ''
                KDL configuration for Niri written in Nix.
            '';
        };

        extraConfig = mkOption {
            type = types.lines;
            default = "";
            description = ''
                Extra configuration lines to be added verbatim.
            '';
        };

        validation.enable = mkEnableOption "niri config validation" // {
            description = ''
                Enable niri config validation using the `niri validate` command.
            '';
            default = true;
        };

        finalConfig = mkOption {
            type = types.lines;
            default = (self.lib.mkNiriKDL cfg._raw_settings) + "\n" + cfg.extraConfig;
            defaultText = literalExpression ''(self.lib.mkNiriKDL cfg.settings) + "\n" + cfg.extraConfig'';
            description = ''
                The final config applied to niri.
            '';
        };

        systemd = {
            variables = mkOption {
                type = types.listOf types.str;
                default = [
                    "DISPLAY"
                    "HYPRLAND_INSTANCE_SIGNATURE"
                    "WAYLAND_DISPLAY"
                    "XDG_CURRENT_DESKTOP"
                ];
                example = [ "--all" ];
                description = ''
                    Environment variables to be imported in the systemd & D-Bus user
                    environment.
                '';
            };
        };
    };

    config = mkIf cfg.enable {
        home.packages = mkIf (cfg.package != null) [ cfg.package ];

        xdg.configFile."niri/config.kdl" = {
            text =
                if cfg.validation.enable then
                    self.validatedConfigFor cfg.package cfg.finalConfig
                else
                    cfg.finalConfig;
        };
    };
}
