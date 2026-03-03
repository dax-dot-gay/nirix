{self, ...}:
{ config, lib, ... }:
with lib;
with self.lib;
let
    cfg = config.wayland.windowManager.niri.settings.layout;
in
{
    options.wayland.windowManager.niri.settings.layout = mkLayoutOptions { };
    config.wayland.windowManager.niri._raw_settings = {
        layout = renderLayout cfg;
    };
}
