{self, ...}:
{ config, lib, ... }:
with lib;
with self.lib;
let
    cfg = config.wayland.windowManager.niri.settings.gestures;
in
{
    options.wayland.windowManager.niri.settings.gestures = {
        dnd-edge-view-scroll = {
            trigger-width = mkNullOr types.numbers.nonnegative;
            delay-ms = mkNullOr types.numbers.nonnegative;
            max-speed = mkNullOr types.numbers.nonnegative;
        };
        dnd-edge-workspace-switch = {
            trigger-height = mkNullOr types.numbers.nonnegative;
            delay-ms = mkNullOr types.numbers.nonnegative;
            max-speed = mkNullOr types.numbers.nonnegative;
        };
        hot-corners = mkOption {
            type = types.listOf (
                types.enum [
                    "top-left"
                    "top-right"
                    "bottom-left"
                    "bottom-right"
                ]
            );
            default = [ "top-left" ];
        };
    };
    config.wayland.windowManager.niri._raw_settings = {
        gestures = {
            dnd-edge-view-scroll = {
                trigger-width = mkIfNotNull cfg.dnd-edge-view-scroll.trigger-width;
                delay-ms = mkIfNotNull cfg.dnd-edge-view-scroll.delay-ms;
                max-speed = mkIfNotNull cfg.dnd-edge-view-scroll.max-speed;
            };
            dnd-edge-workspace-switch = {
                trigger-height = mkIfNotNull cfg.dnd-edge-workspace-switch.trigger-height;
                delay-ms = mkIfNotNull cfg.dnd-edge-workspace-switch.delay-ms;
                max-speed = mkIfNotNull cfg.dnd-edge-workspace-switch.max-speed;
            };
            hot-corners =
                if ((length cfg.hot-corners) > 0) then
                    {
                        top-left = mkIf (builtins.elem "top-left" cfg.hot-corners) [ ];
                        top-right = mkIf (builtins.elem "top-right" cfg.hot-corners) [ ];
                        bottom-left = mkIf (builtins.elem "bottom-left" cfg.hot-corners) [ ];
                        bottom-right = mkIf (builtins.elem "bottom-right" cfg.hot-corners) [ ];
                    }
                else
                    { off = [ ]; };
        };
    };
}
