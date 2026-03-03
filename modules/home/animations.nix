{ config, lib, ... }:
with lib;
let 
    selflib = import ./lib.nix { inherit lib; };
in
with selflib;
let
    cfg = config.wayland.windowManager.niri.settings.animations;
    animationSubmoduleType =
        supports-shader:
        types.submodule (
            { ... }:
            {
                options = {
                    enable = mkBool true;
                    duration-ms = mkNullOr types.ints.unsigned;
                    curve = mkNullOr types.enum [
                        "ease-out-quad"
                        "ease-out-cubic"
                        "ease-out-expo"
                        "linear"
                    ];
                    custom-curve = mkNullOr (
                        types.submodule (
                            { ... }:
                            {
                                options = {
                                    x1 = mkOption { type = types.numbers.between 0.0 1.0; };
                                    y1 = mkOption { type = types.number; };
                                    x2 = mkOption { type = types.numbers.between 0.0 1.0; };
                                    y2 = mkOption { type = types.number; };
                                };
                            }
                        )
                    );
                    spring = mkNullOr (
                        types.submodule (
                            { ... }:
                            {
                                options = {
                                    damping-ratio = mkOption { type = types.numbers.between 0.1 10.0; };
                                    stiffness = mkOption { type = types.number; };
                                    epsilon = mkOption { type = types.number; };
                                };
                            }
                        )
                    );
                    custom-shader = mkIf supports-shader (mkNullOr types.str);
                };
            }
        );
    mkAnimationOption =
        {
            default,
            supports-shader ? false,
        }:
        mkOption {
            type = animationSubmoduleType;
            default = default;
            check = types.addCheck (animationSubmoduleType supports-shader) (
                opts:
                (builtins.any (o -> o) [
                    (opts.enable == false)
                    (
                        opts.enable
                        && (!isNull opts.duration-ms)
                        && (!isNull opts.curve)
                        && (isNull opts.custom-curve)
                        && (isNull opts.spring)
                    )
                    (
                        opts.enable
                        && (!isNull opts.duration-ms)
                        && (!isNull opts.custom-curve)
                        && (isNull opts.curve)
                        && (isNull opts.spring)
                    )
                    (
                        opts.enable
                        && (!isNull opts.spring)
                        && (isNull opts.curve)
                        && (isNull opts.custom-curve)
                        && (isNull opts.duration-ms)
                    )
                ])
            );
        };

    renderAnimation =
        opt:
        if opt.enable then
            {
                duration-ms = mkIfNotNull opt.duration-ms;
                curve = mkIf ((!isNull opt.curve) || (!isNull opt.custom-curve)) (
                    if !isNull opt.curve then
                        opt.curve
                    else
                        {
                            _args = (
                                with opt.custom-curve;
                                [
                                    x1
                                    y1
                                    x2
                                    y2
                                ]
                            );
                        }
                );
                spring = mkIf (!isNull opt.spring) {
                    _props = { inherit (opt.spring) damping-ratio stiffness epsilon; };
                };
                custom-shader = mkIf (
                    (hasAttr "custom-shader" opt) && (!isNull opt.custom-shader)
                ) opt.custom-shader;
            }
        else
            { off = [ ]; };
in
{
    options.wayland.windowManager.niri.settings.animations = optionalBlock {
        enable = mkBool true;
        slowdown = mkNullOr types.numbers.nonnegative;
        workspace-switch = mkAnimationOption {
            default = {
                enable = true;
                spring = {
                    damping-ratio = 1.0;
                    stiffness = 1000;
                    epsilon = 0.0001;
                };
            };
        };
        window-open = mkAnimationOption {
            default = {
                enable = true;
                duration-ms = 150;
                curve = "ease-out-expo";
            };
            supports-shader = true;
        };
        window-close = mkAnimationOption {
            default = {
                enable = true;
                duration-ms = 150;
                curve = "ease-out-quad";
            };
            supports-shader = true;
        };
        horizontal-view-movement = mkAnimationOption {
            default = {
                enable = true;
                spring = {
                    damping-ratio = 1.0;
                    stiffness = 800;
                    epsilon = 0.0001;
                };
            };
        };
        window-movement = mkAnimationOption {
            default = {
                enable = true;
                spring = {
                    damping-ratio = 1.0;
                    stiffness = 800;
                    epsilon = 0.0001;
                };
            };
        };
        window-resize = mkAnimationOption {
            default = {
                enable = true;
                spring = {
                    damping-ratio = 1.0;
                    stiffness = 800;
                    epsilon = 0.0001;
                };
            };
            supports-shader = true;
        };
        config-notification-open-close = mkAnimationOption {
            default = {
                enable = true;
                spring = {
                    damping-ratio = 0.6;
                    stiffness = 1000;
                    epsilon = 0.0001;
                };
            };
        };
        exit-confirmation-open-close = mkAnimationOption {
            default = {
                enable = true;
                spring = {
                    damping-ratio = 0.6;
                    stiffness = 500;
                    epsilon = 0.0001;
                };
            };
        };
        screenshot-ui-open = mkAnimationOption {
            default = {
                enable = true;
                duration-ms = 200;
                curve = "ease-out-quad";
            };
        };
        overview-open-close = mkAnimationOption {
            default = {
                enable = true;
                spring = {
                    damping-ratio = 1.0;
                    stiffness = 800;
                    epsilon = 0.0001;
                };
            };
        };
        recent-windows-close = mkAnimationOption {
            default = {
                enable = true;
                spring = {
                    damping-ratio = 1.0;
                    stiffness = 800;
                    epsilon = 0.0001;
                };
            };
        };
    };
    config.wayland.windowManager.niri._raw_settings = {
        animations = {
            workspace-switch = renderAnimation cfg.workspace-switch;
            window-open = renderAnimation cfg.window-open;
            window-close = renderAnimation cfg.window-close;
            horizontal-view-movement = renderAnimation cfg.horizontal-view-movement;
            window-movement = renderAnimation cfg.window-movement;
            window-resize = renderAnimation cfg.window-resize;
            config-notification-open-close = renderAnimation cfg.config-notification-open-close;
            exit-confirmation-open-close = renderAnimation cfg.exit-confirmation-open-close;
            screenshot-ui-open = renderAnimation cfg.screenshot-ui-open;
            overview-open-close = renderAnimation cfg.overview-open-close;
            recent-windows-close = renderAnimation cfg.recent-windows-close;
        };
    };
}
