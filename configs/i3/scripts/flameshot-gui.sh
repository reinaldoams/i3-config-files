#!/bin/bash

flameshot_dbus_ready() {
    dbus-send --session --print-reply --dest=org.freedesktop.DBus \
        /org/freedesktop/DBus org.freedesktop.DBus.NameHasOwner \
        string:org.flameshot.Flameshot 2>/dev/null | grep -q 'boolean true'
}

ensure_flameshot_daemon() {
    if flameshot_dbus_ready; then
        return 0
    fi

    pkill -x flameshot 2>/dev/null
    flameshot &

    for _ in {1..25}; do
        flameshot_dbus_ready && return 0
        sleep 0.2
    done

    return 1
}

ensure_flameshot_daemon || exit 1
exec flameshot gui
