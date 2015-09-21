#!/bin/sh
. ./test-lib.sh

test_open_url() {
    local de=$1
    shift
    local cmd=$1

    mock $cmd
    run $de xdg-open http://www.freedesktop.org/
    assert_run "$@" http://www.freedesktop.org/
    unmock $cmd
}

mock_missing gvfs-open
test_open_url gnome2 gnome-open
unmock gvfs-open

test_open_url gnome3 gvfs-open

test_open_url kde3 kfmclient exec

test_open_url kde4 kde-open

test_open_url kde5 kde-open5

test_open_url mate gvfs-open
mock_missing gvfs-open
test_open_url mate mate-open
unmock gvfs-open

test_open_url xfce exo-open

test_open_url enlightenment enlightenment_open

cat > $XDG_DATA_DIR/applications/mosaic.desktop <<EOF
[Desktop Entry]
Name=Mosaic
Exec=mosaic %u
EOF

cat > $XDG_DATA_DIR/applications/mimeapps.list <<EOF
[Default Applications]
x-scheme-handler/http=mosaic.desktop
EOF

test_open_url lxde mosaic
test_open_url generic mosaic

# $BROWSER should override mimeapps.list
BROWSER=cyberdog
mock mosaic

test_open_url generic cyberdog

BROWSER="cyberdog --url %s"
test_open_url generic cyberdog --url

unmock mosaic

mock cyberdog
run generic xdg-open 'http://www.freedesktop.org/; echo BUSTED'
assert_run cyberdog --url 'http://www.freedesktop.org/; echo BUSTED'
unmock cyberdog
