#!/bin/sh
COMMAND_TESTED=xdg-open
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

test_that_it opens a URL with gvfs-open under GNOME 2, 3, and Cinnamon
test_open_url gnome3 gvfs-open
test_open_url gnome2 gvfs-open
test_open_url cinnamon gvfs-open

test_that_it opens a URL with gnome-open if gvfs-open is missing under GNOME 2
mock_missing gvfs-open
test_open_url gnome2 gnome-open

test_that_it opens a URL with the generic method if gvfs-open is missing \
             under GNOME 3 and Cinnamon
mock_missing gvfs-open
mock gnome-open
mock_desktop_file mosaic %u
mock_default_app x-scheme-handler/http mosaic
test_open_url gnome3 mosaic
test_open_url cinnamon mosaic

test_that_it opens a URL with the generic method if gvfs-open and gnome-open \
             are missing under GNOME 2
mock_missing gvfs-open
mock_missing gnome-open
mock_desktop_file mosaic %u
mock_default_app x-scheme-handler/http mosaic
test_open_url gnome2 mosaic

test_that_it opens a URL with kfmclient under KDE 3
test_open_url kde3 kfmclient exec

test_that_it opens a URL with kde-open under KDE 4
test_open_url kde4 kde-open

test_that_it opens a URL with kde-open5 under KDE 5
test_open_url kde5 kde-open5

test_that_it opens a URL with gvfs-open under MATE
test_open_url mate gvfs-open

test_that_it opens a URL with mate-open if gvfs-open is missing under MATE
mock_missing gvfs-open
test_open_url mate mate-open

test_that_it opens a URL with exo-open under XFCE
test_open_url xfce exo-open

test_that_it opens a URL with enlightenment_open under Enlightenment
test_open_url enlightenment enlightenment_open

test_that_it opens a file path with pcmanfm under LXDE
mock pcmanfm
touch $LABDIR/file.txt
run lxde xdg-open $LABDIR/file.txt
assert_run pcmanfm $(pwd)/$LABDIR/file.txt

test_that_it percent-decodes a file:// URL and opens it with pcmanfm under LXDE
mock pcmanfm
touch $LABDIR/file.txt
run lxde xdg-open file://$(pwd)/$LABDIR/file%2etxt
assert_run pcmanfm $(pwd)/$LABDIR/file.txt

test_that_it "looks up a desktop file with x-scheme-handler/* using mimeapps.list in generic mode and under LXDE"
mock_desktop_file mosaic %u
mock_default_app x-scheme-handler/http mosaic

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

