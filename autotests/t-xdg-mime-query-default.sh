#!/bin/sh
. ./test-lib.sh

test_that it reads \$XDG_DATA_DIR/applications/mimeapps.list
cat > $XDG_DATA_DIR/applications/mimeapps.list <<EOF
[Default Applications]
x-scheme-handler/http=mosaic.desktop
EOF
handler=$(run generic xdg-mime query default x-scheme-handler/http)
assert_equal mosaic.desktop "$handler"
