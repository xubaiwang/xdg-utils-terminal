#!/bin/sh
COMMAND_TESTED=xdg-email
. ./test-lib.sh

test_that_it uses kreadconfig5 to find default e-mail client in KDE5
cp mock-kreadconfig5 $BINDIR/kreadconfig5
mock kreadconfig
mock kmailservice
mock eudora
run kde5 xdg-email test@example.org
assert_run eudora mailto:test@example.org
