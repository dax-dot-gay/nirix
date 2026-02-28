{ config, lib, ... }:
with lib;
let
    cfg = config.wayland.windowManager.niri.settings.input;

    pointer-options = {
        enable = mkBool true;
        natural-scroll = mkBool true;
        accel-speed = mkNullOr types.float;
        accel-profile = mkEnum [
            "adaptive"
            "flat"
        ];
        scroll-method = mkNullOr (
            types.enum [
                "no-scroll"
                "two-finger"
                "edge"
                "on-button-down"
            ]
        );
        scroll-button = mkNullOr types.int;
        scroll-button-lock = mkBool false;
        left-handed = mkBool false;
        middle-emulation = mkBool false;
    };
    scroll-factor = types.either types.float types.submodule (
        { ... }:
        {
            options = {
                horizontal = mkOption {
                    type = types.float;
                    default = 1.0;
                };
                vertical = mkOption {
                    type = types.float;
                    default = 1.0;
                };
            };
        }
    );
    mkPointer =
        {
            device,
            extra ? { },
        }:
        if cfg.${device}.enable == true then
            (
                {
                    natrual-scroll = mkIf cfg.${device}.natural-scroll [ ];
                    scroll-button-lock = mkIf cfg.${device}.scroll-button-lock [ ];
                    left-handed = mkIf cfg.${device}.left-handed [ ];
                    middle-emulation = mkIf cfg.${device}.middle-emulation [ ];
                    accel-speed = mkIfNotNull cfg.${device}.accel-speed;
                    accel-profile = cfg.${device}.accel-profile;
                    scroll-method = mkIfNotNull cfg.${device}.scroll-method;
                    scroll-button = mkIfNotNull cfg.${device}.scroll-button;
                }
                // extra
            )
        else
            { off = [ ]; };
in
{
    options.wayland.windowManager.niri.settings.input = {
        keyboard = {
            xkb = {
                layout = mkNullOr types.str;
                variant = mkNullOr types.str;
                options = mkNullOr types.str;
                model = mkNullOr types.str;
                rules = mkNullOr types.str;
                file = mkNullOr types.str;
            };
            repeat-delay = mkNullOr types.int;
            repeat-rate = mkNullOr types.int;
            track-layout = mkEnum [
                "global"
                "window"
            ];
            numlock = mkBool true;
        };
        touchpad = {
            tap = mkBool true;
            dwt = mkBool false;
            drag = mkBool false;
            drag-lock = mkBool false;
            tap-button-map = mkNullOr (
                types.enum [
                    "left-right-middle"
                    "left-middle-right"
                ]
            );
            click-method = mkNullOr (
                types.enum [
                    "button-areas"
                    "clickfinger"
                ]
            );
            disabled-on-external-mouse = mkBool false;
            scroll-factor = mkNullOr scroll-factor;
        }
        // pointer-options;
        trackpoint = pointer-options;
        trackball = pointer-options;
        mouse = {
            scroll-factor = mkNullOr scroll-factor;
        }
        // pointer-options;
        tablet = {
            enable = mkBool false;
            map-to-output = mkNullOr types.str;
            left-handed = mkBool false;
            calibration-matrix = mkNullOr (types.listOf types.float);
        };
        touch = {
            enable = mkBool false;
            map-to-output = mkNullOr types.str;
            calibration-matrix = mkNullOr (types.listOf types.float);
        };
        disable-power-key-handling = mkBool false;
        warp-mouse-to-focus = mkNullOr (
            types.either types.bool (mkSub {
                mode = mkEnum [
                    "center-xy"
                    "center-xy-always"
                ];
            })
        );
        focus-follows-mouse = mkNullOr (
            types.either types.bool (mkSub {
                max-scroll-amount = mkOption {
                    type = types.str;
                    default = "10%";
                };
            })
        );
        workspace-auto-back-and-forth = mkBool false;
        mod-key = mkNullOr types.str;
        mod-key-nested = mkNullOr types.str;
    };
    config.wayland.windowManager.niri._raw_settings = {
        input = {
            keyboard = {
                xkb =
                    if (isNull cfg.keyboard.xkb.file) then
                        {
                            layout = mkIfNotNull cfg.keyboard.xkb.layout;
                            variant = mkIfNotNull cfg.keyboard.xkb.variant;
                            options = mkIfNotNull cfg.keyboard.xkb.options;
                            model = mkIfNotNull cfg.keyboard.xkb.model;
                            rules = mkIfNotNull cfg.keyboard.xkb.rules;
                        }
                    else
                        {
                            file = cfg.keyboard.xkb.file;
                        };

                repeat-delay = mkIfNotNull cfg.keyboard.repeat-delay;
                repeat-rate = mkIfNotNull cfg.keyboard.repeat-rate;
                track-layout = cfg.keyboard.track-layout;
                numlock = mkIf cfg.keyboard.numlock [ ];
            };
        };
        touchpad = mkPointer {
            device = "touchpad";
            extra = {
                tap = mkIf cfg.touchpad.tap [ ];
                dwt = mkIf cfg.touchpad.dwt [ ];
                drag = mkIf cfg.touchpad.drag [ ];
                drag-lock = mkIf cfg.touchpad.drag-lock [ ];
                tap-button-map = mkIfNotNull cfg.touchpad.tap-button-map;
                click-method = mkIfNotNull cfg.touchpad.click-method;
                disabled-on-external-mouse = mkIf cfg.touchpad.disabled-on-external-mouse [ ];
                scroll-factor = mkIf (!isNull cfg.touchpad.scroll-factor) (
                    if isFloat cfg.touchpad.scroll-factor then
                        cfg.touchpad.scroll-factor
                    else
                        {
                            _props = {
                                horizontal = cfg.touchpad.scroll-factor.horizontal;
                                vertical = cfg.touchpad.scroll-factor.vertical;
                            };
                        }
                );
            };
        };
        trackpoint = mkPointer { device = "trackpoint"; };
        trackball = mkPointer { device = "trackball"; };
        tablet =
            if cfg.tablet.enable then
                {
                    map-to-output = mkIfNotNull cfg.tablet.map-to-output;
                    calibration-matrix = mkIfNotNull cfg.tablet.calibration-matrix;
                    left-handed = mkIf cfg.tablet.left-handed [ ];
                }
            else
                { off = [ ]; };
        touch =
            if cfg.touch.enable then
                {
                    map-to-output = mkIfNotNull cfg.tablet.map-to-output;
                    calibration-matrix = mkIfNotNull cfg.tablet.calibration-matrix;
                }
            else
                { off = [ ]; };

        disable-power-key-handling = mkIf cfg.disable-power-key-handling [ ];
        warp-mouse-to-focus =
            mkIf
                (
                    (!isNull cfg.warp-mouse-to-focus)
                    && (
                        ((isBool cfg.warp-mouse-to-focus) && cfg.warp-mouse-to-focus) || (isAttrs cfg.warp-mouse-to-focus)
                    )
                )
                (
                    if isBool cfg.warp-mouse-to-focus then
                        [ ]
                    else
                        {
                            _props.mode = cfg.warp-mouse-to-focus.mode;
                        }
                );
        focus-follows-mouse =
            mkIf
                (
                    (!isNull cfg.focus-follows-mouse)
                    && (
                        ((isBool cfg.focus-follows-mouse) && cfg.focus-follows-mouse) || (isAttrs cfg.focus-follows-mouse)
                    )
                )
                (
                    if isBool cfg.focus-follows-mouse then
                        [ ]
                    else
                        {
                            _props.max-scroll-amount = cfg.focus-follows-mouse.max-scroll-amount;
                        }
                );
        workspace-auto-back-and-forth = mkIf cfg.workspace-auto-back-and-forth [ ];
        mod-key = mkIfNotNull cfg.mod-key;
        mod-key-nested = mkIfNotNull cfg.mod-key-nested;
    };
}
