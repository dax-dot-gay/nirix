{ config, lib, ... }:
with lib;
let 
    selflib = import ./lib { inherit lib; };
in
with selflib;
let
    cfg = config.wayland.windowManager.niri.settings.workspaces;
in
{
    options.wayland.windowManager.niri.settings.workspaces = mkOption {
        type = types.attrsOf (
            types.submodule (
                { ... }:
                {
                    options = {
                        open-on-output = mkNullOr types.str;
                        layout = mkNullOr types.attrs;
                    };
                }
            )
        );
    };
    config.wayland.windowManager.niri._raw_settings = {
        workspace = mapAttrsToList (name: opts: {
            _args = [ name ];
            open-on-output = mkIfNotNull opts.open-on-output;
            layout = mkIfNotNull opts.layout;
        }) cfg.workspaces;
    };
}
