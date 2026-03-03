{ config, lib, ... }:
with lib;
let 
    selflib = import ./lib { inherit lib; };
in
with selflib;
let
    cfg = config.wayland.windowManager.niri.settings.window-rules;

    matcherType = types.submodule (
        { ... }:
        {
            title = mkNullOr types.str;
            app-id = mkNullOr types.str;
            is-active = mkNullOr types.bool;
            is-focused = mkNullOr types.bool;
            is-active-in-column = mkNullOr types.bool;
            is-floating = mkNullOr types.bool;
            is-window-cast-target = mkNullOr types.bool;
            is-urgent = mkNullOr types.bool;
            at-startup = mkNullOr types.bool;
        }
    );

    renderMatcher = variant: matcher: {
        ${variant}._props = {
            title = mkIf (!isNull matcher.title) {
                _raw = ''r#"${matcher.title}"#'';
            };
            app-id = mkIf (!isNull matcher.app-id) {
                _raw = ''r#"${matcher.app-id}"#'';
            };
            is-active = mkIfNotNull matcher.is-active;
            is-focused = mkIfNotNull matcher.is-focused;
            is-active-in-column = mkIfNotNull matcher.is-active-in-column;
            is-floating = mkIfNotNull matcher.is-floating;
            is-window-cast-target = mkIfNotNull matcher.is-window-cast-target;
            is-urgent = mkIfNotNull matcher.is-urgent;
            at-startup = mkIfNotNull matcher.at-startup;
        };
    };

    mkChild = value: key: optional (!isNull value.${key}) {${key} = value.${key};};
    mkSChild = root: block: key: optional (!isNull root.${block}.${key}) {${block}.${key} = root.${block}.${key};};
    mkSGradient = root: block: key: optional (!isNull root.${block}.${key}) {${block}.${key} = renderGradient root.${block}.${key};};
in
{
    options.wayland.windowManager.niri.settings.window-rules = mkOption {
        type = types.listOf (
            types.submodule (
                { ... }:
                {
                    match = mkOptDefault (types.listOf matcherType) [ ];
                    exclude = mkOptDefault (types.listOf matcherType) [ ];
                    on-open = {
                        default-column-width = mkNullOr sizeType;
                        default-window-height = mkNullOr sizeType;
                        open-on-output = mkNullOr types.str;
                        open-on-workspace = mkNullOr types.str;
                        open-maximized = mkNullOr types.bool;
                        open-maximized-to-edges = mkNullOr types.bool;
                        open-fullscreen = mkNullOr types.bool;
                        open-floating = mkNullOr types.bool;
                        open-focused = mkNUllOr types.bool;
                    };
                    dynamic = {
                        draw-border-with-background = mkNullOr types.bool;
                        opacity = mkNullOr types.float;
                        block-out-from = mkNullOr (types.enum ["screencast" "screen-capture"]);
                        variable-refresh-rate = mkNullOr types.bool;
                        default-column-display = mkNullOr (types.enum ["normal" "tabbed"]);
                        default-floating-position = mkNullOr (types.submodule ({...}: {
                            options = {
                                x = mkOption {type = numberType;};
                                y = mkOption {type = numberType;};
                                relative-to = mkNullOr (types.enum [
                                    "top-left"
                                    "top-right"
                                    "bottom-left"
                                    "bottom-right"
                                    "top"
                                    "left"
                                    "bottom"
                                    "right"
                                ]);
                            };
                        }));
                        scroll-factor = mkNullOr types.float;
                        geometry-corner-radius = mkNullOr numberType;
                        clip-to-geometry = mkNullOr types.bool;
                        tiled-state = mkNullOr types.bool;
                        baba-is-float = mkNullOr types.bool;
                        min-width = mkNullOr numberType;
                        max-width = mkNullOr numberType;
                        min-height = mkNullOr numberType;
                        max-height = mkNullOr numberType;
                        focus-ring = {
                            enable = mkNullOr types.bool;
                            width = mkNullOr numberType;
                            active-color = mkNullOr types.str;
                            inactive-color = mkNullOr types.str;
                            urgent-color = mkNullOr types.str;
                            active-gradient = mkNullOr gradientType;
                            inactive-gradient = mkNullOr gradientType;
                            urgent-gradient = mkNullOr gradientType;
                        };
                        border = {
                            enable = mkNullOr types.bool;
                            width = mkNullOr numberType;
                            active-color = mkNullOr types.str;
                            inactive-color = mkNullOr types.str;
                            urgent-color = mkNullOr types.str;
                            active-gradient = mkNullOr gradientType;
                            inactive-gradient = mkNullOr gradientType;
                            urgent-gradient = mkNullOr gradientType;
                        };
                        shadow = {
                            enable = mkNullOr types.bool;
                            softness = mkNullOr numberType;
                            spread = mkNullOr numberType;
                            offset = mkNullOr (mkSub {
                                x = mkOptDefault numberType 0;
                                y = mkOptDefault numberType 0;
                            });
                            draw-behind-window = mkNullOr types.bool;
                            color = mkNullOr types.str;
                            inactive-color = mkNullOr types.str;
                        };
                        tab-indicator = {
                            enable = mkNullOr types.bool;
                            hide-when-single-tab = mkNullOr types.bool;
                            place-within-column = mkNullOr types.bool;
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
                    };
                }
            )
        );
        default = [ ];
    };
    config.wayland.windowManager.niri._raw_settings = {
        window-rule = map (rule: {
            _children = concatLists (with rule; [
                map (matcher: renderMatcher "match" matcher) match
                map (matcher: renderMatcher "exclude" matcher) exclude
                mkChild on-open "default-column-width"
                mkChild on-open "default-window-height"
                mkChild on-open "open-on-output"
                mkChild on-open "open-on-workspace"
                mkChild on-open "open-maximized"
                mkChild on-open "open-maximized-to-edges"
                mkChild on-open "open-fullscreen"
                mkChild on-open "open-floating"
                mkChild on-open "open-focused"

                mkChild dynamic "draw-border-with-background"
                mkChild dynamic "opacity"
                mkChild dynamic "block-out-from"
                mkChild dynamic "variable-refresh-rate"
                mkChild dynamic "default-column-display"
                mkChild dynamic "scroll-factor"
                mkChild dynamic "geometry-corner-radius"
                mkChild dynamic "clip-to-geometry"
                mkChild dynamic "tiled-state"
                mkChild dynamic "baba-is-float"
                mkChild dynamic "min-width"
                mkChild dynamic "max-width"
                mkChild dynamic "min-height"
                mkChild dynamic "max-height"
                optional (!isNull dynamic.default-floating-position {
                    default-floating-position._props = {
                        x = dynamic.default-floating-position.x;
                        y = dynamic.default-floating-position.y;
                        relative-to = mkIfNotNull dynamic.default-floating-position.relative-to;
                    };
                })

                optional (!isNull dynamic.focus-ring.enable) (if dynamic.focus-ring.enable then {on = [];} else {off = [];})
                mkSChild dynamic "focus-ring" "width"
                mkSChild dynamic "focus-ring" "active-color"
                mkSChild dynamic "focus-ring" "inactive-color"
                mkSChild dynamic "focus-ring" "urgent-color"
                mkSGradient dynamic "focus-ring" "active-gradient"
                mkSGradient dynamic "focus-ring" "inactive-gradient"
                mkSGradient dynamic "focus-ring" "urgent-gradient"

                optional (!isNull dynamic.border.enable) (if dynamic.border.enable then {on = [];} else {off = [];})
                mkSChild dynamic "border" "width"
                mkSChild dynamic "border" "active-color"
                mkSChild dynamic "border" "inactive-color"
                mkSChild dynamic "border" "urgent-color"
                mkSGradient dynamic "border" "active-gradient"
                mkSGradient dynamic "border" "inactive-gradient"
                mkSGradient dynamic "border" "urgent-gradient"

                optional (!isNull dynamic.shadow.enable) (if dynamic.shadow.enable then {on = [];} else {off = [];})
                optional (!isNull dynamic.shadow.offset) {offset._props = dynamic.shadow.offset;}
                mkSChild dynamic "shadow" "softness"
                mkSChild dynamic "shadow" "spread"
                mkSChild dynamic "shadow" "draw-behind-window"
                mkSChild dynamic "shadow" "color"
                mkSChild dynamic "shadow" "inactive-color"

                optional (!isNull dynamic.tab-indicator.enable) (if dynamic.tab-indicator.enable then {on = [];} else {off = [];})
                mkSChild dynamic "tab-indicator" "hide-when-single-tab"
                mkSChild dynamic "tab-indicator" "place-within-column"
                mkSChild dynamic "tab-indicator" "gap"
                mkSChild dynamic "tab-indicator" "width"
                mkSChild dynamic "tab-indicator" "length"
                mkSChild dynamic "tab-indicator" "position"
                mkSChild dynamic "tab-indicator" "gaps-between-tabs"
                mkSChild dynamic "tab-indicator" "corner-radius"
                mkSChild dynamic "tab-indicator" "active-color"
                mkSChild dynamic "tab-indicator" "inactive-color"
                mkSChild dynamic "tab-indicator" "urgent-color"
                mkSGradient dynamic "tab-indicator" "active-gradient"
                mkSGradient dynamic "tab-indicator" "inactive-gradient"
                mkSGradient dynamic "tab-indicator" "urgent-gradient"
            ]);
        }) cfg;
    };
}
