#!/bin/sh
. ./test-lib.sh

test_that it opens a file path with pcmanfm under LXDE
mock pcmanfm
touch $LABDIR/file.txt
run lxde xdg-open $LABDIR/file.txt
assert_run pcmanfm $(pwd)/$LABDIR/file.txt

test_that it percent-decodes a file:// URL and opens it with pcmanfm under LXDE
mock pcmanfm
touch $LABDIR/file.txt
run lxde xdg-open file://$(pwd)/$LABDIR/file%2etxt
assert_run pcmanfm $(pwd)/$LABDIR/file.txt
