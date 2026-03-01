{ config, lib, ... }:
with lib;
let
    cfg = config.wayland.windowManager.niri.settings.outputs;
in
{
    options.wayland.windowManager.niri.settings.outputs = mkOption {
        type = types.attrsOf (
            types.submodule (
                { ... }:
                {
                    options = {
                        enable = mkBool true;
                        mode = mkOption { type = types.str; };
                        scale = mkOptDefault numberType 1;
                        transform = mkEnum [
                            "normal"
                            "90"
                            "180"
                            "270"
                            "flipped"
                            "flipped-90"
                            "flipped-180"
                            "flipped-270"
                        ];
                        position = mkOption {
                            type = types.submodule (
                                { ... }:
                                {
                                    options = {
                                        x = mkOptDefault types.int 0;
                                        y = mkOptDefault types.int 0;
                                    };
                                }
                            );
                            default = {
                                x = 0;
                                y = 0;
                            };
                        };
                        variable-refresh-rate = {
                            enable = mkBool true;
                            on-demand = mkBool true;
                        };
                        focus-at-startup = mkBool false;
                        backdrop-color = mkNullOr types.str;
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
                        layout = mkNullOr (mkLayoutOptions { });
                        raw_layout = mkNullOr types.attrs;
                    };
                }
            )
        );
        default = { };
    };
    config.wayland.windowManager.niri._raw_settings = {
        output = mapAttrsToList (name: value: {
            _args = [ name ];
            mode = value.mode;
            scale = value.scale;
            transform = value.transform;
            position._props = value.position;
            variable-refresh-rate = mkIf value.variable-refresh-rate.enable (
                if value.variable-refresh-rate.on-demand then { _props.on-demand = true; } else [ ]
            );
            focus-at-startup = mkIf value.focus-at-startup [ ];
            backdrop-color = mkIfNotNull value.backdrop-color;
            hot-corners =
                if ((length value.hot-corners) > 0) then
                    {
                        top-left = mkIf (builtins.elem "top-left" value.hot-corners) [ ];
                        top-right = mkIf (builtins.elem "top-right" value.hot-corners) [ ];
                        bottom-left = mkIf (builtins.elem "bottom-left" value.hot-corners) [ ];
                        bottom-right = mkIf (builtins.elem "bottom-right" value.hot-corners) [ ];
                    }
                else
                    { off = [ ]; };
            layout = mkIf ((!isNull value.layout) || (!isNull value.raw_layout)) (
                if !isNull value.raw_layout then value.raw_layout else (renderLayout value.layout)
            );
        }) cfg;
    };
}
