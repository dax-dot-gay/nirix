{ config, lib, ... }:
with lib;
let
    selflib = import ./lib.nix { inherit lib; };
in
with selflib;
let
    cfg = config.wayland.windowManager.niri.settings.binds;

    mkAction =
        args:
        mkNullOr (
            types.submodule (
                { ... }:
                {
                    options = args;
                }
            )
        );
    mkGenericAction = mkNullOr (types.either types.attrs (types.listOf types.anything));

    actionType = types.submodule (
        { ... }:
        {
            options = {
                quit = mkAction { skip-confirmation = mkBool false; };
                spawn = mkAction {
                    allow-when-locked = mkBool false;
                    args = mkOption { type = types.listOf types.str; };
                };
                spawn-sh = mkAction {
                    allow-when-locked = mkBool false;
                    command = mkOption { type = types.str; };
                };
                do-screen-transition = mkAction { delay-ms = mkNullOr types.int; };
                screenshot = mkAction {
                    write-to-disk = mkBool true;
                    show-pointer = mkBool true;
                };
                screenshot-screen = mkAction {
                    write-to-disk = mkBool true;
                    show-pointer = mkBool true;
                };
                screenshot-window = mkAction {
                    write-to-disk = mkBool true;
                    show-pointer = mkBool true;
                };
                center-column = mkGenericAction;
                center-visible-columns = mkGenericAction;
                center-window = mkGenericAction;
                clear-dynamic-cast-target = mkGenericAction;
                close-overview = mkGenericAction;
                close-window = mkGenericAction;
                consume-or-expel-window-left = mkGenericAction;
                consume-or-expel-window-right = mkGenericAction;
                consume-window-into-column = mkGenericAction;
                debug-toggle-damage = mkGenericAction;
                debug-toggle-opaque-regions = mkGenericAction;
                expand-column-to-available-width = mkGenericAction;
                expel-window-from-column = mkGenericAction;
                focus-column = mkGenericAction;
                focus-column-first = mkGenericAction;
                focus-column-last = mkGenericAction;
                focus-column-left = mkGenericAction;
                focus-column-left-or-last = mkGenericAction;
                focus-column-or-monitor-left = mkGenericAction;
                focus-column-or-monitor-right = mkGenericAction;
                focus-column-right = mkGenericAction;
                focus-column-right-or-first = mkGenericAction;
                focus-floating = mkGenericAction;
                focus-monitor = mkGenericAction;
                focus-monitor-down = mkGenericAction;
                focus-monitor-left = mkGenericAction;
                focus-monitor-next = mkGenericAction;
                focus-monitor-previous = mkGenericAction;
                focus-monitor-right = mkGenericAction;
                focus-monitor-up = mkGenericAction;
                focus-tiling = mkGenericAction;
                focus-window = mkGenericAction;
                focus-window-bottom = mkGenericAction;
                focus-window-down = mkGenericAction;
                focus-window-down-or-column-left = mkGenericAction;
                focus-window-down-or-column-right = mkGenericAction;
                focus-window-down-or-top = mkGenericAction;
                focus-window-in-column = mkGenericAction;
                focus-window-or-monitor-down = mkGenericAction;
                focus-window-or-monitor-up = mkGenericAction;
                focus-window-or-workspace-down = mkGenericAction;
                focus-window-or-workspace-up = mkGenericAction;
                focus-window-previous = mkGenericAction;
                focus-window-top = mkGenericAction;
                focus-window-up = mkGenericAction;
                focus-window-up-or-bottom = mkGenericAction;
                focus-window-up-or-column-left = mkGenericAction;
                focus-window-up-or-column-right = mkGenericAction;
                focus-workspace = mkGenericAction;
                focus-workspace-down = mkGenericAction;
                focus-workspace-previous = mkGenericAction;
                focus-workspace-up = mkGenericAction;
                fullscreen-window = mkGenericAction;
                load-config-file = mkGenericAction;
                maximize-column = mkGenericAction;
                maximize-window-to-edges = mkGenericAction;
                move-column-left = mkGenericAction;
                move-column-left-or-to-monitor-left = mkGenericAction;
                move-column-right = mkGenericAction;
                move-column-right-or-to-monitor-right = mkGenericAction;
                move-column-to-first = mkGenericAction;
                move-column-to-index = mkGenericAction;
                move-column-to-last = mkGenericAction;
                move-column-to-monitor = mkGenericAction;
                move-column-to-monitor-down = mkGenericAction;
                move-column-to-monitor-left = mkGenericAction;
                move-column-to-monitor-next = mkGenericAction;
                move-column-to-monitor-previous = mkGenericAction;
                move-column-to-monitor-right = mkGenericAction;
                move-column-to-monitor-up = mkGenericAction;
                move-column-to-workspace = mkGenericAction;
                move-column-to-workspace-down = mkGenericAction;
                move-column-to-workspace-up = mkGenericAction;
                move-floating-window = mkGenericAction;
                move-window-down = mkGenericAction;
                move-window-down-or-to-workspace-down = mkGenericAction;
                move-window-to-floating = mkGenericAction;
                move-window-to-monitor = mkGenericAction;
                move-window-to-monitor-down = mkGenericAction;
                move-window-to-monitor-left = mkGenericAction;
                move-window-to-monitor-next = mkGenericAction;
                move-window-to-monitor-previous = mkGenericAction;
                move-window-to-monitor-right = mkGenericAction;
                move-window-to-monitor-up = mkGenericAction;
                move-window-to-tiling = mkGenericAction;
                move-window-to-workspace = mkGenericAction;
                move-window-to-workspace-down = mkGenericAction;
                move-window-to-workspace-up = mkGenericAction;
                move-window-up = mkGenericAction;
                move-window-up-or-to-workspace-up = mkGenericAction;
                move-workspace-down = mkGenericAction;
                move-workspace-to-index = mkGenericAction;
                move-workspace-to-monitor = mkGenericAction;
                move-workspace-to-monitor-down = mkGenericAction;
                move-workspace-to-monitor-left = mkGenericAction;
                move-workspace-to-monitor-next = mkGenericAction;
                move-workspace-to-monitor-previous = mkGenericAction;
                move-workspace-to-monitor-right = mkGenericAction;
                move-workspace-to-monitor-up = mkGenericAction;
                move-workspace-up = mkGenericAction;
                open-overview = mkGenericAction;
                power-off-monitors = mkGenericAction;
                power-on-monitors = mkGenericAction;
                reset-window-height = mkGenericAction;
                set-column-display = mkGenericAction;
                set-column-width = mkGenericAction;
                set-dynamic-cast-monitor = mkGenericAction;
                set-dynamic-cast-window = mkGenericAction;
                set-window-height = mkGenericAction;
                set-window-urgent = mkGenericAction;
                set-window-width = mkGenericAction;
                set-workspace-name = mkGenericAction;
                show-hotkey-overlay = mkGenericAction;
                swap-window-left = mkGenericAction;
                swap-window-right = mkGenericAction;
                switch-focus-between-floating-and-tiling = mkGenericAction;
                switch-layout = mkGenericAction;
                switch-preset-column-width = mkGenericAction;
                switch-preset-column-width-back = mkGenericAction;
                switch-preset-window-height = mkGenericAction;
                switch-preset-window-height-back = mkGenericAction;
                switch-preset-window-width = mkGenericAction;
                switch-preset-window-width-back = mkGenericAction;
                toggle-column-tabbed-display = mkGenericAction;
                toggle-debug-tint = mkGenericAction;
                toggle-keyboard-shortcuts-inhibit = mkGenericAction;
                toggle-overview = mkGenericAction;
                toggle-window-floating = mkGenericAction;
                toggle-window-rule-opacity = mkGenericAction;
                toggle-window-urgent = mkGenericAction;
                toggle-windowed-fullscreen = mkGenericAction;
                unset-window-urgent = mkGenericAction;
                unset-workspace-name = mkGenericAction;
            };
        }
    );

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
            spawn._args = opts.action.spawn.args;
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
            spawn-sh._args = [ opts.action.spawn-sh.command ];
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
        ${action} = if isAttrs opts.action.${action} then {
            _props = opts.action.${action};
        } else if isList opts.action.${action} then {
            _args = opts.action.${action};
        } else {};
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
                            type = actionType;
                            default = { };
                        };
                    };
                }
            )
        );
        default = {
        };
    };
    config.wayland.windowManager.niri._raw_settings = {
        binds = mkIfNotEmpty (mapAttrs (
            bind: opts:
            let
                enabledActions = attrNames (filterAttrs (name: val: !isNull val) opts.action);
                action =
                    if ((length enabledActions) == 1) then
                        (elemAt enabledActions 0)
                    else
                        throw "Exactly one action must be specified.";
            in
            (
                if hasAttr action actionRenderers then
                    (actionRenderers.${action}) opts
                else
                    renderGenericAction action opts
            )
        ) cfg);
    };
}
