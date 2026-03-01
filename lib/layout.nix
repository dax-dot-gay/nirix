{ lib, ... }:
with lib;
let
    numberType = types.either types.float types.int;
    sizeType =
        types.either
            (types.submodule (
                { ... }:
                {
                    options = {
                        proportion = mkOption {
                            type = numberType;
                            description = "A proportion (0.0-1.0) of the reference size";
                        };
                    };
                }
            ))
            (
                types.submodule (
                    { ... }:
                    {
                        options = {
                            fixed = mkOption {
                                type = numberType;
                                description = "A fixed size in logical pixels";
                            };
                        };
                    }
                )
            );
    gradientType = type.submodule (
        { ... }:
        {
            options = {
                from = mkOption {
                    type = types.str;
                };
                to = mkOption {
                    type = types.str;
                };
                angle = mkNullOr numberType;
                relative-to-workspace-view = mkBool false;
                color-space = mkNullOr types.str;
            };
        }
    );

    renderGradient = gradient: {
        _props = {
            from = gradient.from;
            to = gradient.to;
            angle = mkIfNotNull gradient.angle;
            relative-to = mkIf gradient.relative-to-workspace-view "workspace-view";
            "in" = mkIfNotNull gradient.color-space;
        };
    };

    renderSub =
        options: renderer: (if options.enable then ({ on = [ ]; } // renderer) else { off = [ ]; });
in
{
    sizeType = sizeType;
    gradientType = gradientType;
    renderGradient = renderGradient;
    numberType = numberType;
    mkLayoutOptions =
        { }:
        {
            gaps = mkOptDefault numberType 16;
            center-focused-column = mkNullEnum [
                "never"
                "always"
                "on-overflow"
            ];
            always-center-single-column = mkBool false;
            empty-workspace-above-first = mkBool false;
            default-column-display = mkNullEnum [
                "normal"
                "tabbed"
            ];
            background-color = mkNullOr types.str;
            preset-column-widths = mkOption {
                type = types.listOf sizeType;
                default = [ ];
            };
            default-column-width = mkNullOr sizeType;
            preset-window-heights = mkOption {
                type = types.listOf sizeType;
                default = [ ];
            };
            focus-ring = {
                enable = mkBool true;
                width = mkOptDefault numberType 4;
                active-color = mkNullOr types.str;
                inactive-color = mkNullOr types.str;
                urgent-color = mkNullOr types.str;
                active-gradient = mkNullOr gradientType;
                inactive-gradient = mkNullOr gradientType;
                urgent-gradient = mkNullOr gradientType;
            };
            border = {
                enable = mkBool false;
                width = mkOptDefault numberType 4;
                active-color = mkNullOr types.str;
                inactive-color = mkNullOr types.str;
                urgent-color = mkNullOr types.str;
                active-gradient = mkNullOr gradientType;
                inactive-gradient = mkNullOr gradientType;
                urgent-gradient = mkNullOr gradientType;
            };
            shadow = {
                enable = mkBool false;
                softness = mkNullOr numberType;
                spread = mkNullOr numberType;
                offset = mkNullOr (mkSubOpt {
                    x = mkOptDefault numberType 0;
                    y = mkOptDefault numberType 0;
                });
                draw-behind-window = mkBool false;
                color = mkNullOr types.str;
                inactive-color = mkNullOr types.str;
            };
            tab-indicator = {
                enable = mkBool true;
                hide-when-single-tab = mkBool true;
                place-within-column = mkBool true;
                gap = mkNullOr numberType;
                width = mkNullOr numberType;
                length = mkNullOr types.float;
                position = mkNullEnum [
                    "left"
                    "right"
                    "top"
                    "bottom"
                ];
                gaps-between-tabs = mkNullOr numberType;
                corner-radius = mkNullOr numberType;
                active-color = mkNullOr types.str;
                inactive-color = mkNullOr types.str;
                urgent-color = mkNullOr types.str;
                active-gradient = mkNullOr gradientType;
                inactive-gradient = mkNullOr gradientType;
                urgent-gradient = mkNullOr gradientType;
            };
            insert-hint = {
                enable = mkBool true;
                color = mkNullOr types.str;
                gradient = mkNullOr gradientType;
            };
            struts = {
                left = mkNullOr numberType;
                right = mkNullOr numberType;
                top = mkNullOr numberType;
                bottom = mkNullOr numberType;
            };
        };

    renderLayout = l: {
        gaps = mkIfNotNull l.gaps;
        center-focused-column = mkIfNotNull l.center-focused-column;
        always-center-single-column = mkIf l.always-center-single-column [ ];
        empty-workspace-above-first = mkIf l.empty-workspace-above-first [ ];
        default-column-display = mkIfNotNull l.default-column-display;
        background-color = mkIfNotNull l.background-color;
        preset-column-widths._children = mkIf ((length l.preset-column-widths) > 0) l.preset-column-widths;
        default-column-width = mkIfNotNull l.default-column-width;
        preset-window-heights._children = mkIf (
            (length l.preset-window-heights) > 0
        ) l.preset-window-heights;
        focus-ring = renderSub l.focus-ring {
            width = mkIfNotNull l.focus-ring.width;
            active-color = mkIfNotNull l.focus-ring.active-color;
            inactive-color = mkIfNotNull l.focus-ring.inactive-color;
            urgent-color = mkIfNotNull l.focus-ring.urgent-color;
            active-gradient = mkIf (!isNull l.focus-ring.active-gradient) (
                renderGradient l.focus-ring.active-gradient
            );
            inactive-gradient = mkIf (!isNull l.focus-ring.inactive-gradient) (
                renderGradient l.focus-ring.inactive-gradient
            );
            urgent-gradient = mkIf (!isNull l.focus-ring.urgent-gradient) (
                renderGradient l.focus-ring.urgent-gradient
            );
        };
        border = renderSub l.border {
            width = mkIfNotNull l.border.width;
            active-color = mkIfNotNull l.border.active-color;
            inactive-color = mkIfNotNull l.border.inactive-color;
            urgent-color = mkIfNotNull l.border.urgent-color;
            active-gradient = mkIf (!isNull l.border.active-gradient) (renderGradient l.border.active-gradient);
            inactive-gradient = mkIf (!isNull l.border.inactive-gradient) (
                renderGradient l.border.inactive-gradient
            );
            urgent-gradient = mkIf (!isNull l.border.urgent-gradient) (renderGradient l.border.urgent-gradient);
        };
        shadow = renderSub l.shadow {
            softness = mkIfNotNull l.shadow.softness;
            spread = mkIfNotNull l.shadow.spread;
            offset._props = mkIfNotNull l.shadow.offset;
            draw-behind-window = l.shadow.draw-behind-window;
            color = mkIfNotNull l.shadow.color;
            inactive-color = mkIfNotNull l.shadow.inactive-color;
        };
        tab-indicator = renderSub l.tab-indicator {
            hide-when-single-tab = mkIf l.tab-indicator.hide-when-single-tab [ ];
            place-within-column = mkIf l.tab-indicator.place-within-column [ ];
            gap = mkIfNotNull l.tab-indicator.gap;
            width = mkIfNotNull l.tab-indicator.width;
            length._props.total-proportion = mkIfNotNull l.tab-indicator.length;
            position = mkIfNotNull l.tab-indicator.position;
            gaps-between-tabs = mkIfNotNull l.tab-indicator.gaps-between-tabs;
            corner-radius = mkIfNotNull l.tab-indicator.corner-radius;
            active-color = mkIfNotNull l.tab-indicator.active-color;
            inactive-color = mkIfNotNull l.tab-indicator.inactive-color;
            urgent-color = mkIfNotNull l.tab-indicator.urgent-color;
            active-gradient = mkIf (!isNull l.tab-indicator.active-gradient) (
                renderGradient l.tab-indicator.active-gradient
            );
            inactive-gradient = mkIf (!isNull l.tab-indicator.inactive-gradient) (
                renderGradient l.tab-indicator.inactive-gradient
            );
            urgent-gradient = mkIf (!isNull l.tab-indicator.urgent-gradient) (
                renderGradient l.tab-indicator.urgent-gradient
            );
        };
        insert-hint = renderSub l.insert-hint {
            color = mkIfNotNull l.insert-hint.color;
            gradient = mkIf (!isNull l.insert-hint.gradient) (renderGradient l.insert-hint.gradient);
        };
        struts = {
            left = mkIfNotNull l.struts.left;
            right = mkIfNotNull l.struts.right;
            top = mkIfNotNull l.struts.top;
            bottom = mkIfNotNull l.struts.bottom;
        };
    };
}
