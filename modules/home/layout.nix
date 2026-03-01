{ config, lib, ... }:
with lib;
let
    cfg = config.wayland.windowManager.niri.settings.layout;
    niri = config.wayland.windowManager.niri;
    raw = config.wayland.windowManager.niri._raw_settings;
in
{
    options.wayland.windowManager.niri.settings.layout = mkLayoutOptions { };
    config.wayland.windowManager.niri._raw_settings = {
        layout = renderLayout cfg;
    };
}
