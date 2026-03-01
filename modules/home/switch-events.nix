{ config, lib, ... }:
with lib;
let
    cfg = config.wayland.windowManager.niri.settings.switch-events;
in
{
    options.wayland.windowManager.niri.settings.switch-events = {
        lid-close = mkNullOr (types.listOf types.str);
        lid-open = mkNullOr (types.listOf types.str);
        tablet-mode-on = mkNullOr (types.listOf types.str);
        tablet-mode-off = mkNullOr (types.listOf types.str);
    };
    config.wayland.windowManager.niri._raw_settings = {
        switch-events = {
            lid-close = mkIf (!isNull cfg.lid-close) { spawn._args = cfg.lid-close; };
            lid-open = mkIf (!isNull cfg.lid-open) { spawn._args = cfg.lid-open; };
            tablet-mode-on = mkIf (!isNull cfg.tablet-mode-on) { spawn._args = cfg.tablet-mode-on; };
            tablet-mode-off = mkIf (!isNull cfg.tablet-mode-off) { spawn._args = cfg.tablet-mode-off; };
        };
    };
}
