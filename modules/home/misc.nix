{ config, lib, ... }:
with lib;
let 
    selflib = import ./lib.nix { inherit lib; };
in
with selflib;
let
    cfg = config.wayland.windowManager.niri.settings;
in
{
    options.wayland.windowManager.niri.settings = {
        spawn-at-startup = mkOption {
            type = types.listOf types.str;
            default = [ ];
            description = ''
                This is `spawn-sh-at-startup`. Raw `spawn-at-startup` isn't supported, as I don't see it as a useful pattern.
            '';
        };
        prefer-no-csd = mkBool true;
        screenshot-path = mkOptDefault types.str "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";
        environment = mkOptDefault (types.attrsOf (types.nullOr types.str)) { };
        cursor = optionalBlock {
            xcursor-theme = mkNullOr types.str;
            xcursor-size = mkNullOr types.int;
            hide-when-typing = mkBool false;
            hide-after-inactive-ms = mkNullOr types.int;
        };
        overview = optionalBlock {
            zoom = mkNullOr types.float;
            backdrop-color = mkNullOr types.str;
            workspace-shadow = optionalBlock {
                enable = mkBool true;
                softness = mkOptDefault numberType 40;
                spread = mkOptDefault numberType 10;
                offset = mkNullOr (mkSub {
                    x = mkOptDefault numberType 0;
                    y = mkOptDefault numberType 0;
                });
                color = mkNullOr types.str;
            };
        };
        xwayland-satellite = mkOptDefault (types.nullOr types.str) "xwayland-satellite";
        clipboard.disable-primary = mkBool false;
        hotkey-overlay = optionalBlock {
            skip-at-startup = mkBool false;
            hide-not-bound = mkBool false;
        };
        config-notification.disable-failed = mkBool false;
        debug = mkNullOr types.attrs;
    };
    config.wayland.windowManager.niri._raw_settings = {
        spawn-sh-at-startup = mkIf ((length cfg.spawn-at-startup) > 0) (map (v: [ v ]) cfg.spawn-at-startup);
        prefer-no-csd = mkIf cfg.prefer-no-csd [ ];
        screenshot-path = cfg.screenshot-path;
        environment = mkIf ((length (attrNames cfg.environment)) > 0) cfg.environment;
        cursor =
            let
                cu = cfg.cursor;
            in
            mkIfNotEmpty {
                xcursor-theme = mkIfNotNull cu.xcursor-theme;
                xcursor-size = mkIfNotNull cu.xcursor-size;
                hide-when-typing = mkIf cu.hide-when-typing [ ];
                hide-after-inactive-ms = mkIfNotNull cu.hide-after-inactive-ms;
            };
        overview =
            let
                ov = cfg.overview;
            in
            mkIfNotEmpty {
                zoom = mkIfNotNull ov.zoom;
                backdrop-color = mkIfNotNull ov.backdrop-color;
                workspace-shadow =
                    let
                        ws = ov.workspace-shadow;
                    in
                    (
                        if ws.enable then
                            {
                                softness = ws.softness;
                                spread = ws.spread;
                                offset = mkIf (!isNull ws.offset) {_props = ws.offset;};
                                color = mkIfNotNull ws.color;
                            }
                        else
                            { off = [ ]; }
                    );
            };
        xwayland-satellite =
            if isNull cfg.xwayland-satellite then { off = [ ]; } else { path = cfg.xwayland-satellite; };
        clipboard = mkIf cfg.clipboard.disable-primary {disable-primary = [ ];};
        hotkey-overlay = mkIfNotEmpty (
            let
                hk = cfg.hotkey-overlay;
            in
            {
                skip-at-startup = mkIf hk.skip-at-startup [ ];
                hide-not-bound = mkIf hk.hide-not-bound [ ];
            });
        config-notification = mkIf cfg.config-notification.disable-failed {disable-failed = [ ];};
        debug = mkIfNotNull cfg.debug;
    };
}
