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

# lxde uses generic for non-file URLs

test_open_url enlightenment enlightenment_open
