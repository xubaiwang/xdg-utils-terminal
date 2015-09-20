#!/bin/sh
. ./test-lib.sh

cat > $XDG_DATA_DIR/applications/mimeapps.list <<EOF
[Default Applications]
x-scheme-handler/http=mosaic.desktop
EOF
handler=$(run generic xdg-mime query default x-scheme-handler/http)
assert_equal mosaic.desktop "$handler"
