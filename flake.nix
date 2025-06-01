{
  description = "Flake utils demo";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system}; in
      {
        packages = rec {

          # This package is adapted from https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/by-name/xd/xdg-utils/package.nix

          xdg-utils-terminal = with pkgs; let

            # Required by the common desktop detection code
            commonDeps = [
              dbus
              coreutils
              gnugrep
              gnused
            ];
            # These are all faked because the current desktop is detected
            # based on their presence, so we want them to be missing by default.
            commonFakes = [
              "explorer.exe"
              "gnome-default-applications-properties"
              "kde-config"
              "xprop"
            ];

            # This is still required to work around the eval trickery some scripts do
            commonPrologue = "${writeText "xdg-utils-prologue" ''
              export PATH=$PATH:${lib.makeBinPath [ coreutils ]}
            ''}";

            solutions = [
              {
                scripts = [ "bin/xdg-desktop-icon" ];
                interpreter = "${bash}/bin/bash";
                inputs = commonDeps ++ [ xdg-user-dirs ];
                execer = [
                  "cannot:${xdg-user-dirs}/bin/xdg-user-dir"
                ];
                # These are desktop-specific, so we don't want xdg-utils to be able to
                # call them when in a different setup.
                fake.external = commonFakes ++ [
                  "gconftool-2" # GNOME2
                ];
                keep."$KDE_SESSION_VERSION" = true;
                prologue = commonPrologue;
              }

              {
                scripts = [ "bin/xdg-desktop-menu" ];
                interpreter = "${bash}/bin/bash";
                inputs = commonDeps ++ [ gawk ];
                fake.external = commonFakes;
                keep."$KDE_SESSION_VERSION" = true;
                prologue = commonPrologue;
              }

              {
                scripts = [ "bin/xdg-email" ];
                interpreter = "${bash}/bin/bash";
                inputs = commonDeps ++ [
                  gawk
                  glib.bin
                  "${placeholder "out"}/bin"
                ];
                execer = [
                  "cannot:${placeholder "out"}/bin/xdg-mime"
                  "cannot:${placeholder "out"}/bin/xdg-open"
                ];
                # These are desktop-specific, so we don't want xdg-utils to be able to
                # call them when in a different setup.
                fake.external = commonFakes ++ [
                  "exo-open" # XFCE
                  "gconftool-2" # GNOME
                  "gio" # GNOME (new)
                  "gnome-open" # GNOME (very old)
                  "gvfs-open" # GNOME (old)
                  "qtxdg-mat" # LXQT
                  "xdg-email-hook.sh" # user-defined hook that may be available ambiently
                ];
                fix."/bin/echo" = true;
                keep = {
                  "$command" = true;
                  "$kreadconfig" = true;
                  "$THUNDERBIRD" = true;
                  "$utf8" = true;
                };
              }

              {
                scripts = [ "bin/xdg-icon-resource" ];
                interpreter = "${bash}/bin/bash";
                inputs = commonDeps;
                fake.external = commonFakes;
                keep."$KDE_SESSION_VERSION" = true;
                prologue = commonPrologue;
              }

              {
                scripts = [ "bin/xdg-mime" ];
                interpreter = "${bash}/bin/bash";
                inputs = commonDeps ++ [
                  file
                  gawk
                ];
                # These are desktop-specific, so we don't want xdg-utils to be able to
                # call them when in a different setup.
                fake.external = commonFakes ++ [
                  "gio" # GNOME (new)
                  "gnomevfs-info" # GNOME (very old)
                  "gvfs-info" # GNOME (old)
                  "kde4-config" # Plasma 4
                  "kfile" # KDE 3
                  "kmimetypefinder" # Plasma (generic)
                  "kmimetypefinder5" # Plasma 5
                  "ktraderclient" # KDE 3
                  "ktradertest" # KDE 3
                  "mimetype" # alternative tool for file, pulls in perl, avoid
                  "qtpaths" # Plasma
                  "qtxdg-mat" # LXQT
                ];
                fix."/usr/bin/file" = true;
                keep = {
                  "$KDE_SESSION_VERSION" = true;
                  "$KTRADER" = true;
                };
                prologue = "${writeText "xdg-mime-prologue" ''
                  export XDG_DATA_DIRS="$XDG_DATA_DIRS''${XDG_DATA_DIRS:+:}${shared-mime-info}/share"
                  export PERL5LIB=${with perlPackages; makePerlPath [ FileMimeInfo ]}
                  export PATH=$PATH:${
                    lib.makeBinPath [
                      coreutils
                      perlPackages.FileMimeInfo
                    ]
                  }
                ''}";
              }

              {
                scripts = [ "bin/xdg-open" ];
                interpreter = "${bash}/bin/bash";
                inputs = commonDeps ++ [
                  nettools
                  glib.bin
                  xdg-terminal-exec
                  "${placeholder "out"}/bin"
                ];
                execer = [
                  "cannot:${xdg-terminal-exec}/bin/xdg-terminal-exec"
                  "cannot:${placeholder "out"}/bin/xdg-mime"
                ];
                # These are desktop-specific, so we don't want xdg-utils to be able to
                # call them when in a different setup.
                fake.external = commonFakes ++ [
                  "cygstart" # Cygwin
                  "dde-open" # Deepin
                  "enlightenment_open" # Enlightenment
                  "exo-open" # XFCE
                  "gio" # GNOME (new)
                  "gnome-open" # GNOME (very old)
                  "gvfs-open" # GNOME (old)
                  "kde-open" # Plasma
                  "kfmclient" # KDE3
                  "mate-open" # MATE
                  "mimeopen" # alternative tool for file, pulls in perl, avoid
                  "open" # macOS
                  "pcmanfm" # LXDE
                  "qtxdg-mat" # LXQT
                  "run-mailcap" # generic
                  "rundll32.exe" # WSL
                  "wslpath" # WSL
                ];
                fix."$printf" = [ "printf" ];
                keep = {
                  "env:$command" = true;
                  "$browser" = true;
                  "$KDE_SESSION_VERSION" = true;
                };
              }

              {
                scripts = [ "bin/xdg-screensaver" ];
                interpreter = "${bash}/bin/bash";
                inputs = commonDeps ++ [
                  nettools
                  perl
                  procps
                ];
                # These are desktop-specific, so we don't want xdg-utils to be able to
                # call them when in a different setup.
                fake.external = commonFakes ++ [
                  "dcop" # KDE3
                  "lockfile"
                  "mate-screensaver-command" # MATE
                  "xautolock" # Xautolock
                  "xscreensaver-command" # Xscreensaver
                  "xset" # generic-ish X
                ];
                keep = {
                  "$MV" = true;
                  "$XPROP" = true;
                  "$lockfile_command" = true;
                };
                execer = [
                  "cannot:${perl}/bin/perl"
                ];
                prologue = "${writeText "xdg-screensaver-prologue" ''
                  export PERL5LIB=${
                    with perlPackages;
                    makePerlPath [
                      NetDBus
                      XMLTwig
                      XMLParser
                      X11Protocol
                    ]
                  }
                  export PATH=$PATH:${coreutils}/bin
                ''}";
              }

              {
                scripts = [ "bin/xdg-settings" ];
                interpreter = "${bash}/bin/bash";
                inputs = commonDeps ++ [
                  jq
                  "${placeholder "out"}/bin"
                ];
                execer = [
                  "cannot:${placeholder "out"}/bin/xdg-mime"
                ];
                # These are desktop-specific, so we don't want xdg-utils to be able to
                # call them when in a different setup.
                fake.external = commonFakes ++ [
                  "gconftool-2" # GNOME
                  "kreadconfig" # Plasma (generic)
                  "kreadconfig5" # Plasma 5
                  "kreadconfig6" # Plasma 6
                  "ktradertest" # KDE3
                  "kwriteconfig" # Plasma (generic)
                  "kwriteconfig5" # Plasma 5
                  "kwriteconfig6" # Plasma 6
                  "qtxdg-mat" # LXQT
                ];
                keep = {
                  "$KDE_SESSION_VERSION" = true;
                  # get_browser_$handler
                  "$handler" = true;
                };
              }
            ];
          in          
          pkgs.stdenv.mkDerivation {
            pname = "xdg-utils";
            version = "1.2.1";
            src = ./.;

            nativeBuildInputs = with pkgs; [
              libxslt
              docbook_xml_dtd_412
              docbook_xml_dtd_43
              docbook_xsl
              xmlto

              makeWrapper
            ];

            buildInputs = with pkgs; [
              bash
            ];

            preFixup = lib.concatStringsSep "\n" (
              map (resholve.phraseSolution "xdg-utils-resholved") solutions
            );
          };
          default = xdg-utils-terminal;
        };
      }
    );
}
