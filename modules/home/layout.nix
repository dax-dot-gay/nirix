{ config, lib, ... }:
with lib;
let 
    selflib = import ./lib.nix { inherit lib; };
in
with selflib;
let
    cfg = config.wayland.windowManager.niri.settings.layout;
in
{
    options.wayland.windowManager.niri.settings.layout = optionalBlock (mkLayoutOptions { });
    config.wayland.windowManager.niri._raw_settings = {
        layout = renderLayout cfg;
    };
}
