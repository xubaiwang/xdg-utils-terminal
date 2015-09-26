set -e

TEST_NAME=$0
LABDIR=lab
LABHOME=lab/home
BINDIR=$LABDIR/bin
COMMANDS_RUN=$LABDIR/commands-run
FAILED_TESTS=failed-tests
XDG_DATA_HOME=$LABDIR/home-share
XDG_DATA_DIR=$LABDIR/share
XDG_DATA_DIR_LOCAL=$LABDIR/share-local
XDG_DATA_DIRS=$XDG_DATA_DIR_LOCAL:$XDG_DATA_DIR

fatal() {
    echo "FATAL: $*" >&2
    exit 1
}

setup_lab() {
    [ -f test-lib.sh ] || fatal "You must run tests from the autotests directory!"
    [ -e $LABDIR ] && rm -r $LABDIR

    BROWSER=

    mkdir -p \
        $BINDIR \
        $LABHOME \
        $XDG_DATA_HOME/applications $XDG_DATA_DIR/applications \
        $XDG_DATA_DIR_LOCAL/applications \
        $XDG_DATA_HOME/icons/hicolor $XDG_DATA_DIR/icons/hicolor \
        $XDG_DATA_DIR_LOCAL/icons/hicolor
    touch $COMMANDS_RUN
}

set_de_() {
    unmock gnome-default-applications-properties
    unmock kde-config
    KDE_SESSION_VERSION=

    case "$1" in
        cinnamon)
            XDG_CURRENT_DESKTOP=Cinnamon
            ;;
        enlightenment)
            XDG_CURRENT_DESKTOP=ENLIGHTENMENT
            ;;
        gnome2)
            XDG_CURRENT_DESKTOP=GNOME
            mock gnome-default-applications-properties
            ;;
        gnome3)
            XDG_CURRENT_DESKTOP=GNOME
            ;;
        kde3)
            XDG_CURRENT_DESKTOP=KDE
            cat > $BINDIR/kde-config <<EOF
#!/bin/sh
echo "KDE: 3.5.5"
EOF
            chmod +x $BINDIR/kde-config
            ;;
        kde4)
            XDG_CURRENT_DESKTOP=KDE
            KDE_SESSION_VERSION=4
            ;;
        kde5)
            XDG_CURRENT_DESKTOP=KDE
            KDE_SESSION_VERSION=5
            ;;
        lxde)
            XDG_CURRENT_DESKTOP=LXDE
            ;;
        mate)
            XDG_CURRENT_DESKTOP=MATE
            ;;
        xfce)
            XDG_CURRENT_DESKTOP=XFCE
            ;;
        generic)
            XDG_CURRENT_DESKTOP=X-Generic
            ;;
        *)
            fatal "unknown desktop environment: $1"
            ;;
    esac
}

mock_ret() {
    local ret="$1"
    shift
    local command="$1"
    local executable="$BINDIR/$command"

    cat >"$executable" <<EOF
#!/bin/sh
set -e
echo "$command \$*" >> $(pwd)/$COMMANDS_RUN
exit $ret
EOF
    chmod +x "$executable"
}

mock() {
    mock_ret 0 "$@"
}

mock_missing() {
    mock_ret 127 "$@"
}

unmock() {
    if [ -e "$BINDIR/$1" ]; then
        rm "$BINDIR/$1"
    fi
}

is_mocked() {
    if [ -e "$BINDIR/$1" ]; then
        return 0
    else
        return 1
    fi
}

assertion_failed() {
    echo "ASSERTION FAILED: $*" >&2
    echo "$TEST_NAME: $*" >>$FAILED_TESTS
}

assert_run() {
    if grep -Fxq "$*" $COMMANDS_RUN; then
        return 0
    else
        assertion_failed "assert_run $*"
    fi
}

assert_equal() {
    if [ "$1" = "$2" ]; then
        return 0
    else
        assertion_failed "expected: '$1' got: '$2'"
    fi
}

assert_file_exists() {
    if [ -e "$1" ]; then
        return 0
    else
        assertion_failed "expected file to exist: $1"
    fi
}

run() {
    local de="$1"
    shift

    local cmd="$1"
    shift

    : > $COMMANDS_RUN

    set_de_ $de

    local trace=
    if [ "$TRACE" = 1 ]; then
        trace="sh -x"
    fi

    echo "RUN [$de] $cmd $*" >&2
    env -i \
        PATH="$BINDIR:../scripts:$PATH" \
        SHELL="$SHELL" \
        USERNAME="$USERNAME" \
        HOME="$LABHOME" \
        LOGNAME="$LOGNAME" \
        TERM="$TERM" \
        XDG_CURRENT_DESKTOP="$XDG_CURRENT_DESKTOP" \
        XDG_UTILS_DEBUG_LEVEL="$XDG_UTILS_DEBUG_LEVEL" \
        KDE_SESSION_VERSION="$KDE_SESSION_VERSION" \
        XDG_DATA_HOME=$XDG_DATA_HOME \
        XDG_DATA_DIRS=$XDG_DATA_DIRS \
        DISPLAY=x \
        BROWSER="$BROWSER" \
        $trace ../scripts/$cmd "$@"
}

setup_lab
