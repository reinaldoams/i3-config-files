#!/bin/bash

flameshot_dbus_ready() {
    dbus-send --session --print-reply --dest=org.freedesktop.DBus \
        /org/freedesktop/DBus org.freedesktop.DBus.NameHasOwner \
        string:org.flameshot.Flameshot 2>/dev/null | grep -q 'boolean true'
}

if flameshot_dbus_ready; then
    exit 0
fi

pkill -x flameshot 2>/dev/null
flameshot &

for _ in {1..25}; do
    flameshot_dbus_ready && exit 0
    sleep 0.2
done

exit 1
