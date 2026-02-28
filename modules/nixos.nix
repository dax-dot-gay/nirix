{
    pkgs,
    niri-unstable,
    niri-unstable-blur,
    lib,
    config,
    ...
}:
with lib;
let
    cfg = config.programs.niri;
    variants = {
        stable = pkgs.niri;
        unstable = niri-unstable.packages.${pkgs.stdenv.hostPlatform.system}.niri;
        unstable-blur = niri-unstable-blur.packages.${pkgs.stdenv.hostPlatform.system}.niri;
    };
in
{
    options.programs.niri = {
        enable = mkEnableOption "Niri, a scrollable-tiling Wayland compositor";
        variant = mkOption {
            type = types.enum [
                "stable"
                "unstable"
                "unstable-blur"
            ];
            default = "stable";
            description = ''
                Which supported variant to choose, if not overridden by `programs.niri.package`.
                - stable: use niri stable from nixpkgs
                - unstable: build niri from the repository's main branch
                - unstable-blur: build niri with the unstable blur branch
            '';
        };
        package = mkOption {
            type = types.package;
            default = variants.${cfg.variant};
            description = "Custom niri package to use. If specified, this overrides `programs.niri.variant`";
        };
        useNautilus = mkEnableOption "Nautilus as file-chooser for xdg-desktop-portal-gnome" // {
            default = true;
        };

        withUWSM = mkEnableOption "UWSM support" // {
            description = ''
                Launch Niri with the Universal Wayland Session Manager. This has better systemd support and automatically starts `graphical-session.target` and `wayland-session@niri.target`.
            '';
        };
        withXDG = mkEnableOption "XDG portal support" // {
            description = ''
                Enable XDG portal support for Niri.
            '';
            default = true;
        };

    };
    disabledModules = [ "programs/wayland/niri.nix" ];
    config = mkIf cfg.enable (mkMerge [
        {
            environment.systemPackages = [
                cfg.package
            ];

            services.dbus.packages = mkIf cfg.useNautilus [
                pkgs.nautilus
            ];

            services = {
                displayManager.sessionPackages = [ cfg.package ];

                gnome.gnome-keyring.enable = lib.mkDefault true;

                graphical-desktop.enable = true;
                xserver.desktopManager.runXdgAutostartIfNone = lib.mkDefault true;
            };

            security.polkit.enable = true;

            programs.dconf.enable = lib.mkDefault true;

            systemd.packages = [ cfg.package ];
        }
        (mkIf cfg.withUWSM {
            programs.uwsm = {
                enable = true;
                waylandCompositors = {
                    hyprland = {
                        prettyName = "Niri";
                        comment = "A scrollable-tiling Wayland compositor";
                        binPath = "/run/current-system/sw/bin/niri-session";
                    };
                };
            };
        })
        (mkIf cfg.withXDG {
            xdg.portal = {
                enable = true;
                xdgOpenUsePortal = lib.mkDefault true;
                extraPortals = with pkgs; [
                    xdg-desktop-portal-gnome
                    xdg-desktop-portal-gtk
                ];
                configPackages = [ cfg.package ];
            };
        })
    ]);

}
