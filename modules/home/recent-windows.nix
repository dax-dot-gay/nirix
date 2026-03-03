{ config, lib, ... }:
with lib;
let 
    selflib = import ./lib.nix { inherit lib; };
in
with selflib;
let
    cfg = config.wayland.windowManager.niri.settings.recent-windows;
in
{
    options.wayland.windowManager.niri.settings.recent-windows = optionalBlock {
        enable = mkBool true;
        debounce-ms = mkNullOr types.ints.unsigned;
        open-delay-ms = mkNullOr types.ints.unsigned;
        highlight = optionalBlock {
            active-color = mkNullOr types.str;
            urgent-color = mkNullOr types.str;
            padding = mkNullOr types.numbers.nonnegative;
            corner-radius = mkNullOr types.numbers.nonnegative;
        };
        previews = optionalBlock {
            max-height = mkNullOr types.numbers.nonnegative;
            max-scale = mkNullOr types.numbers.nonnegative;
        };
        binds = mkOption {
            type = types.attrsOf (
                types.submodule (
                    { ... }:
                    {
                        options = {
                            action = mkOption {
                                type = types.enum [
                                    "next-window"
                                    "previous-window"
                                ];
                            };
                            filter = mkNullOr types.str;
                        };
                    }
                )
            );
            default = { };
        };
    };
    config.wayland.windowManager.niri._raw_settings = {
        recent-windows =
            if cfg.enable then
                mkIfNotEmpty {
                    debounce-ms = mkIfNotNull cfg.debounce-ms;
                    open-delay-ms = mkIfNotNull cfg.open-delay-ms;
                    highlight = mkIfNotEmpty (with cfg.highlight; {
                        active-color = mkIfNotNull active-color;
                        urgent-color = mkIfNotNull urgent-color;
                        padding = mkIfNotNull padding;
                        corner-radius = mkIfNotNull corner-radius;
                    });
                    previews = mkIfNotEmpty (with cfg.previews; {
                        max-height = mkIfNotNull max-height;
                        max-scale = mkIfNotNull max-scale;
                    });
                    binds = mkIfNotEmpty (mapAttrs (bind: action: {
                        next-window = mkIf (action.action == "next-window") { _props.filter = mkIfNotNull action.filter; };
                        previous-window = mkIf (action.action == "previous-window") {
                            _props.filter = mkIfNotNull action.filter;
                        };
                    }) cfg.binds);
                }
            else
                { off = [ ]; };
    };
}
