{ config, lib, ... }:
with lib;
let
    selflib = import ./lib.nix { inherit lib; };
in
with selflib;
let
    cfg = config.wayland.windowManager.niri.settings.layer-rules;

    matcherType = types.submodule (
        { ... }:
        {
            options = {
                namespace = mkNullOr types.str;
                at-startup = mkNullOr types.bool;
            };
        }
    );

    renderMatcher = variant: matcher: {
        ${variant}._props = {
            namespace = mkIf (!isNull matcher.namespace) {
                _raw = ''r#"${matcher.namespace}"#'';
            };
            at-startup = mkIfNotNull matcher.at-startup;
        };
    };

    mkChild = value: key: optional (!isNull value.${key}) { ${key} = value.${key}; };
in
{
    options.wayland.windowManager.niri.settings.layer-rules = mkOption {
        type = types.attrsOf (
            types.submodule (
                { ... }:
                {
                    options = {
                        match = mkOptDefault (types.listOf matcherType) [ ];
                        exclude = mkOptDefault (types.listOf matcherType) [ ];
                        opacity = mkNullOr types.float;
                        block-out-from = mkNullOr (
                            types.enum [
                                "screencast"
                                "screen-capture"
                            ]
                        );
                        geometry-corner-radius = mkNullOr numberType;
                        baba-is-float = mkNullOr types.bool;
                        place-within-backdrop = mkNullOr types.bool;
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
                    };
                }
            )
        );
        default = { };
    };
    config.wayland.windowManager.niri._raw_settings = {
        layer-rule = mkIfNotEmpty (
            map (rule: {
                _children = concatLists [
                    (map (matcher: renderMatcher "match" matcher) rule.match)
                    (map (matcher: renderMatcher "exclude" matcher) rule.exclude)
                    (mkChild rule "opacity")
                    (mkChild rule "block-out-from")
                    (mkChild rule "geometry-corner-radius")
                    (mkChild rule "place-within-backdrop")
                    (mkChild rule "baba-is-float")
                    (optional (!isNull rule.shadow.enable) (
                        if rule.shadow.enable then
                            {
                                shadow = with rule.shadow; {
                                    on = [ ];
                                    offset = mkIf (!isNull offset) { _props = offset; };
                                    softness = mkIfNotNull softness;
                                    spread = mkIfNotNull spread;
                                    draw-behind-window = mkIfNotNull draw-behind-window;
                                    color = mkIfNotNull color;
                                    inactive-color = mkIfNotNull inactive-color;
                                };
                            }
                        else
                            {
                                shadow = {
                                    off = [ ];
                                };
                            }
                    ))
                ];
            }) (attrValues cfg)
        );
    };
}
