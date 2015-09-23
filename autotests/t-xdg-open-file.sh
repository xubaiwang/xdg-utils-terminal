#!/bin/sh
. ./test-lib.sh

mock pcmanfm
touch $LABDIR/file.txt

run lxde xdg-open $LABDIR/file.txt
assert_run pcmanfm $(pwd)/$LABDIR/file.txt

run lxde xdg-open file://$(pwd)/$LABDIR/file%2etxt
assert_run pcmanfm $(pwd)/$LABDIR/file.txt
