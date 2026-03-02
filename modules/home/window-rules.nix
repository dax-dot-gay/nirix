{ config, lib, ... }:
with lib;
let
    cfg = config.wayland.windowManager.niri.settings.window-rules;
    niri = config.wayland.windowManager.niri;
    raw = config.wayland.windowManager.niri._raw_settings;

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
in
{
    options.wayland.windowManager.niri.settings.window-rules = mkOption {
        type = types.listOf (
            types.submodule (
                { ... }:
                {
                    match = mkOptDefault (types.listOf matcherType) [ ];
                    exclude = mkOptDefault (types.listOf matcherType) [ ];
                }
            )
        );
        default = [ ];
    };
    config.wayland.windowManager.niri._raw_settings = {

    };
}
