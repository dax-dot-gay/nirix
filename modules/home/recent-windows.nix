{ config, lib, ... }:
with lib;
let
    cfg = config.wayland.windowManager.niri.settings.recent-windows;
in
{
    options.wayland.windowManager.niri.settings.recent-windows = {
        enable = mkBool true;
        debounce-ms = mkNullOr types.ints.unsigned;
        open-delay-ms = mkNullOr types.ints.unsigned;
        highlight = {
            active-color = mkNullOr types.str;
            urgent-color = mkNullOr types.str;
            padding = mkNullOr types.numbers.nonnegative;
            corner-radius = mkNullOr types.numbers.nonnegative;
        };
        previews = {
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
            if cfg.recent-windows.enable then
                {
                    debounce-ms = mkNullOr cfg.debounce-ms;
                    open-delay-ms = mkNullOr cfg.open-delay-ms;
                    highlight = with cfg.highlight; {
                        active-color = mkNullOr active-color;
                        urgent-color = mkNullOr urgent-color;
                        padding = mkNullOr padding;
                        corner-radius = mkNullOr corner-radius;
                    };
                    previews = with cfg.previews; {
                        max-height = mkNullOr max-height;
                        max-scale = mkNullOr max-scale;
                    };
                    binds = mapAttrs (bind: action: {
                        next-window = mkIf (action.action == "next-window") { _props.filter = mkIfNotNull action.filter; };
                        previous-window = mkIf (action.action == "previous-window") {
                            _props.filter = mkIfNotNull action.filter;
                        };
                    }) cfg.binds;
                }
            else
                { off = [ ]; };
    };
}
