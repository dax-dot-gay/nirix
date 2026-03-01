{ config, lib, ... }:
with lib;
let
    cfg = config.wayland.windowManager.niri.settings.binds;

    mkAction =
        name: args:
        types.submodule (
            { ... }:
            {
                options = {
                    "${name}" = mkOption {
                        type = types.submodule (
                            { ... }:
                            {
                                options = args;
                            }
                        );
                    };
                };
            }
        );

    genericActions =
        actions:
        map (
            action:
            types.submodule (
                { ... }:
                {
                    options = {
                        "${action}" = mkOption {
                            type = types.either types.attrs (types.listOf types.anything);
                            description = ''
                                Either an attrset of properties or a list of positional arguments
                            '';
                        };
                    };
                }
            )
        ) actions;

    actionTypes =
        types.oneOf [
            mkAction
            "quit"
            { skip-confirmation = mkBool false; }
            mkAction
            "spawn"
            {
                allow-when-locked = mkBool false;
                args = mkOption { type = types.listOf types.str; };
            }
            mkAction
            "spawn-sh"
            {
                allow-when-locked = mkBool false;
                command = mkOption { type = types.str; };
            }
            mkAction
            "do-screen-transition"
            { delay-ms = mkNullOr types.int; }
            mkAction
            "screenshot"
            {
                write-to-disk = mkBool true;
                show-pointer = mkBool true;
            }
            mkAction
            "screenshot-screen"
            {
                write-to-disk = mkBool true;
                show-pointer = mkBool true;
            }
            mkAction
            "screenshot-window"
            {
                write-to-disk = mkBool true;
                show-pointer = mkBool true;
            }
        ]
        ++ genericActions [
            "center-column"
            "center-visible-columns"
            "center-window"
            "clear-dynamic-cast-target"
            "close-overview"
            "close-window"
            "consume-or-expel-window-left"
            "consume-or-expel-window-right"
            "consume-window-into-column"
            "debug-toggle-damage"
            "debug-toggle-opaque-regions"
            "expand-column-to-available-width"
            "expel-window-from-column"
            "focus-column"
            "focus-column-first"
            "focus-column-last"
            "focus-column-left"
            "focus-column-left-or-last"
            "focus-column-or-monitor-left"
            "focus-column-or-monitor-right"
            "focus-column-right"
            "focus-column-right-or-first"
            "focus-floating"
            "focus-monitor"
            "focus-monitor-down"
            "focus-monitor-left"
            "focus-monitor-next"
            "focus-monitor-previous"
            "focus-monitor-right"
            "focus-monitor-up"
            "focus-tiling"
            "focus-window"
            "focus-window-bottom"
            "focus-window-down"
            "focus-window-down-or-column-left"
            "focus-window-down-or-column-right"
            "focus-window-down-or-top"
            "focus-window-in-column"
            "focus-window-or-monitor-down"
            "focus-window-or-monitor-up"
            "focus-window-or-workspace-down"
            "focus-window-or-workspace-up"
            "focus-window-previous"
            "focus-window-top"
            "focus-window-up"
            "focus-window-up-or-bottom"
            "focus-window-up-or-column-left"
            "focus-window-up-or-column-right"
            "focus-workspace"
            "focus-workspace-down"
            "focus-workspace-previous"
            "focus-workspace-up"
            "fullscreen-window"
            "load-config-file"
            "maximize-column"
            "maximize-window-to-edges"
            "move-column-left"
            "move-column-left-or-to-monitor-left"
            "move-column-right"
            "move-column-right-or-to-monitor-right"
            "move-column-to-first"
            "move-column-to-index"
            "move-column-to-last"
            "move-column-to-monitor"
            "move-column-to-monitor-down"
            "move-column-to-monitor-left"
            "move-column-to-monitor-next"
            "move-column-to-monitor-previous"
            "move-column-to-monitor-right"
            "move-column-to-monitor-up"
            "move-column-to-workspace"
            "move-column-to-workspace-down"
            "move-column-to-workspace-up"
            "move-floating-window"
            "move-window-down"
            "move-window-down-or-to-workspace-down"
            "move-window-to-floating"
            "move-window-to-monitor"
            "move-window-to-monitor-down"
            "move-window-to-monitor-left"
            "move-window-to-monitor-next"
            "move-window-to-monitor-previous"
            "move-window-to-monitor-right"
            "move-window-to-monitor-up"
            "move-window-to-tiling"
            "move-window-to-workspace"
            "move-window-to-workspace-down"
            "move-window-to-workspace-up"
            "move-window-up"
            "move-window-up-or-to-workspace-up"
            "move-workspace-down"
            "move-workspace-to-index"
            "move-workspace-to-monitor"
            "move-workspace-to-monitor-down"
            "move-workspace-to-monitor-left"
            "move-workspace-to-monitor-next"
            "move-workspace-to-monitor-previous"
            "move-workspace-to-monitor-right"
            "move-workspace-to-monitor-up"
            "move-workspace-up"
            "open-overview"
            "power-off-monitors"
            "power-on-monitors"
            "reset-window-height"
            "set-column-display"
            "set-column-width"
            "set-dynamic-cast-monitor"
            "set-dynamic-cast-window"
            "set-window-height"
            "set-window-urgent"
            "set-window-width"
            "set-workspace-name"
            "show-hotkey-overlay"
            "swap-window-left"
            "swap-window-right"
            "switch-focus-between-floating-and-tiling"
            "switch-layout"
            "switch-preset-column-width"
            "switch-preset-column-width-back"
            "switch-preset-window-height"
            "switch-preset-window-height-back"
            "switch-preset-window-width"
            "switch-preset-window-width-back"
            "toggle-column-tabbed-display"
            "toggle-debug-tint"
            "toggle-keyboard-shortcuts-inhibit"
            "toggle-overview"
            "toggle-window-floating"
            "toggle-window-rule-opacity"
            "toggle-window-urgent"
            "toggle-windowed-fullscreen"
            "unset-window-urgent"
            "unset-workspace-name"
        ];

    actionRenderers = {
        quit = opts: {
            _props = {
                repeat = mkIf (!opts.repeat) opts.repeat;
                cooldown-ms = mkIfNotNull opts.cooldown-ms;
                hotkey-overlay-title = mkIf (
                    !((isNull opts.hotkey-overlay-title) || (opts.hotkey-overlay-title == true))
                ) opts.hotkey-overlay-title;
                allow-inhibiting = mkIf (!opts.allow-inhibiting) opts.allow-inhibiting;
            };
            quit._props.skip-confirmation = mkIf opts.action.quit.skip-confirmation opts.action.quit.skip-confirmation;
        };
        spawn = opts: {
            _props = {
                repeat = mkIf (!opts.repeat) opts.repeat;
                cooldown-ms = mkIfNotNull opts.cooldown-ms;
                hotkey-overlay-title = mkIf (
                    !((isNull opts.hotkey-overlay-title) || (opts.hotkey-overlay-title == true))
                ) opts.hotkey-overlay-title;
                allow-inhibiting = mkIf (!opts.allow-inhibiting) opts.allow-inhibiting;
                allow-when-locked = mkIf opts.action.spawn.allow-when-locked opts.action.spawn.allow-when-locked;
            };
            _args = opts.action.spawn.args;
        };
        spawn-sh = opts: {
            _props = {
                repeat = mkIf (!opts.repeat) opts.repeat;
                cooldown-ms = mkIfNotNull opts.cooldown-ms;
                hotkey-overlay-title = mkIf (
                    !((isNull opts.hotkey-overlay-title) || (opts.hotkey-overlay-title == true))
                ) opts.hotkey-overlay-title;
                allow-inhibiting = mkIf (!opts.allow-inhibiting) opts.allow-inhibiting;
                allow-when-locked = mkIf opts.action.spawn-sh.allow-when-locked opts.action.spawn-sh.allow-when-locked;
            };
            _args = [ opts.action.spawn-sh.command ];
        };
        do-screen-transition = opts: {
            _props = {
                repeat = mkIf (!opts.repeat) opts.repeat;
                cooldown-ms = mkIfNotNull opts.cooldown-ms;
                hotkey-overlay-title = mkIf (
                    !((isNull opts.hotkey-overlay-title) || (opts.hotkey-overlay-title == true))
                ) opts.hotkey-overlay-title;
                allow-inhibiting = mkIf (!opts.allow-inhibiting) opts.allow-inhibiting;
            };
            do-screen-transition._props.delay-ms = mkIf opts.action.do-screen-transition.delay-ms opts.action.do-screen-transition.delay-ms;
        };
        screenshot = opts: {
            _props = {
                repeat = mkIf (!opts.repeat) opts.repeat;
                cooldown-ms = mkIfNotNull opts.cooldown-ms;
                hotkey-overlay-title = mkIf (
                    !((isNull opts.hotkey-overlay-title) || (opts.hotkey-overlay-title == true))
                ) opts.hotkey-overlay-title;
                allow-inhibiting = mkIf (!opts.allow-inhibiting) opts.allow-inhibiting;
            };
            screenshot._props.write-to-disk = mkIf (
                !opts.action.screenshot.write-to-disk
            ) opts.action.screenshot.write-to-disk;
            screenshot._props.show-pointer = mkIf (
                !opts.action.screenshot.show-pointer
            ) opts.action.screenshot.show-pointer;
        };
        screenshot-screen = opts: {
            _props = {
                repeat = mkIf (!opts.repeat) opts.repeat;
                cooldown-ms = mkIfNotNull opts.cooldown-ms;
                hotkey-overlay-title = mkIf (
                    !((isNull opts.hotkey-overlay-title) || (opts.hotkey-overlay-title == true))
                ) opts.hotkey-overlay-title;
                allow-inhibiting = mkIf (!opts.allow-inhibiting) opts.allow-inhibiting;
            };
            screenshot-screen._props.write-to-disk = mkIf (
                !opts.action.screenshot-screen.write-to-disk
            ) opts.action.screenshot-screen.write-to-disk;
            screenshot-screen._props.show-pointer = mkIf (
                !opts.action.screenshot-screen.show-pointer
            ) opts.action.screenshot-screen.show-pointer;
        };
        screenshot-window = opts: {
            _props = {
                repeat = mkIf (!opts.repeat) opts.repeat;
                cooldown-ms = mkIfNotNull opts.cooldown-ms;
                hotkey-overlay-title = mkIf (
                    !((isNull opts.hotkey-overlay-title) || (opts.hotkey-overlay-title == true))
                ) opts.hotkey-overlay-title;
                allow-inhibiting = mkIf (!opts.allow-inhibiting) opts.allow-inhibiting;
            };
            screenshot-window._props.write-to-disk = mkIf (
                !opts.action.screenshot-window.write-to-disk
            ) opts.action.screenshot-window.write-to-disk;
            screenshot-window._props.show-pointer = mkIf (
                !opts.action.screenshot-window.show-pointer
            ) opts.action.screenshot-window.show-pointer;
        };
    };

    renderGenericAction = action: opts: {
        _props = {
            repeat = mkIf (!opts.repeat) opts.repeat;
            cooldown-ms = mkIfNotNull opts.cooldown-ms;
            hotkey-overlay-title = mkIf (
                !((isNull opts.hotkey-overlay-title) || (opts.hotkey-overlay-title == true))
            ) opts.hotkey-overlay-title;
            allow-inhibiting = mkIf (!opts.allow-inhibiting) opts.allow-inhibiting;
        };
        ${action}._props = mkIf (isAttrs opts.action.${action}) opts.action.${action};
        ${action}._args = mkIf (isList opts.action.${action}) opts.action.${action};
    };
in
{
    options.wayland.windowManager.niri.settings.binds = mkOption {
        type = types.attrsOf (
            types.submodule (
                { ... }:
                {
                    options = {
                        repeat = mkBool true;
                        cooldown-ms = mkNullOr types.int;
                        hotkey-overlay-title = mkNullOr (types.either types.bool types.str);
                        allow-inhibiting = mkBool true;
                        action = mkOption {
                            type = actionTypes;
                        };
                    };
                }
            )
        );
    };
    config.wayland.windowManager.niri._raw_settings = {
        binds = mapAttrs (
            bind: opts:
            let
                action = elemAt (attrNames opts.action) 0;
            in
            (
                if hasAttr action actionRenderers then
                    (actionRenderers.${action}) opts
                else
                    renderGenericAction action opts
            )
        ) cfg;
    };
}
