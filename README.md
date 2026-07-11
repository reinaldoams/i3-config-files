In the /configs there are my config files that I use in my Fedora i3 Spin machine.
In /files are files to where some config files point.
In fonts folder has the font that I use1

Locations:
- configs/i3/config => ~/.config/i3/config
- configs/i3status/config => ~/.config/i3status/config
- configs/gtk/config => ~/.config/gtk-3.0/settings.ini
- configs/nvim/* => ~/.config/nvim/*
- configs/systemd/user/i3-session.target => ~/.config/systemd/user/i3-session.target
- configs/dunst/dunstrc => ~/.config/dunst/dunstrc
- configs/.bashrc => ~/.bashrc

Used programs (that didnt come from Fedora i3 Spin):
- gammastep (for color temperature setting)
- feh (for setting wallpaper)
- i3-dmenu-desktop (for dmenu options that works with Flatpak installed programs)
- flameshot (for taking screenshots clicking PrintScreen key)
- nvim (some shortcuts open nvim)
- brave-browser (or use another browser and update the key binding command in i3 config)
- heroic (there is a shortcut added in .bashrc)
- polybar:
- parcellite
- dunst
- rofi
- compton

Styling:
- Bibata Cursor
	~/.icons/default/index.theme
    ```
    [Icon Theme]
	Inherits=Bibata-Modern-Amber
    ```
	~/.Xresources:
    ```
    Xcursor.theme: Bibata-Modern-Amber
	Xcursor.size: 26
    ```
    (apply that last one with `xrdb -merge ~/.Xresources`)
    ~/.xprofile:
    ```
    echo 'export XCURSOR_THEME=Bibata-Modern-Amber' >> ~/.xprofile
	echo 'export XCURSOR_SIZE=26' >> ~/.xprofile
	```
    making it work in flatpak apps:
    ```
	sudo flatpak override --filesystem=$HOME/.icons
	sudo flatpak override --env=XCURSOR_THEME=Bibata-Modern-Amber
	sudo flatpak override --env=XCURSOR_SIZE=32
    ```
    also run:
       `gsettings set org.gnome.desktop.interface cursor-size 26`
       `gsettings set org.gnome.desktop.interface cursor-theme 'Bibata-Modern-Amber'`

- Global dark mode (GTK + apps that follow the desktop portal, including Cursor):
    `configs/gtk-3.0/settings.ini` already has `gtk-application-prefer-dark-theme=1`, but that alone is **not** enough for Electron/Flatpak apps. They read the FreeDesktop portal setting `org.freedesktop.appearance` `color-scheme`.

    On i3, set:
    ```bash
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
    gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
    ```

    **Why this matters with the portal fix above:** once `xdg-desktop-portal` is running (via `i3-session.target`), apps actually query that color-scheme. If it is still `'default'` (portal value `0`), Cursor and similar apps look light even when GTK prefers dark. With `'prefer-dark'`, the portal reports `1`.

    **Verify:**
    ```bash
    gsettings get org.gnome.desktop.interface color-scheme
    # expect: 'prefer-dark'
    gdbus call --session --dest org.freedesktop.portal.Desktop \
      --object-path /org/freedesktop/portal/desktop \
      --method org.freedesktop.portal.Settings.ReadOne \
      'org.freedesktop.appearance' 'color-scheme'
    # expect: (<uint32 1>,)
    ```
    Then reload Cursor (**Developer: Reload Window**) or restart it if the UI is still light.


Additional steps:
- adding name of currently open window to i3status bar:
    https://github.com/rholder/i3status-title-on-bar/
- disabling GRUB (in /etc/default/grub):
    GRUB_TIMEOUT=0
    GRUB_TIMEOUT_STYLE=hidden
    (and then running `sudo grub2-mkconfig -o /boot/grub2/grub.cfg`)
- running these commands to make booting faster:
    `sudo systemctl disable NetworkManager-wait-online.service`
    (disabling config that makes computer wait for internet connection before continuing boot)
    `sudo dracut --force --hostonly`
    (rebuild image of initramfs creating an lightweight system-specific image)
- if dual booting with Windows, remember to go to Windows settings to disable fast startup to make Linux boot faster
- xdg-desktop-portal / Flatpak link opening on i3:
    Install the GTK portal backend so Flatpak apps can talk to the host (open folders, pick files, etc.):
    `sudo dnf install xdg-desktop-portal xdg-desktop-portal-gtk`

    On GNOME/KDE, systemd reaches `graphical-session.target` automatically and starts `xdg-desktop-portal.service`. On **i3 + LightDM**, that target never becomes active, so the portal stays dead. Flatpak apps then fail to open https links (`Failed to call portal: ... org.freedesktop.portal.Desktop`).

    **Fix used here:**
    1. Install `configs/systemd/user/i3-session.target` to `~/.config/systemd/user/i3-session.target`. That unit binds to `graphical-session.target` and wants `xdg-desktop-portal.service`, so starting it brings the portal up without starting `graphical-session.target` by hand (systemd refuses a manual start of that target).
    2. In `configs/i3/config`, at login:
        ```i3
        exec --no-startup-id dbus-update-activation-environment --systemd DISPLAY XAUTHORITY XDG_CURRENT_DESKTOP
        exec --no-startup-id systemctl --user start i3-session.target
        ```
    3. After copying the unit (or on first setup): `systemctl --user daemon-reload` then either re-login or run `systemctl --user start i3-session.target`.

    **Verify:** `systemctl --user is-active xdg-desktop-portal.service` should print `active`. From a Flatpak sandbox, `flatpak run --command=xdg-open com.rtosta.zapzap https://example.com` should open the default browser.

    After the portal is up, also set global dark mode (`gsettings` `color-scheme prefer-dark`) — see **Styling → Global dark mode** above — or apps like Cursor may switch to light.
- setting default browser command:
	`xdg-settings set default-web-browser net.waterfox.waterfox.desktop`
- fixing cedilla (portuguese):
	`sudo sed -i 's/"cedilla" "Cedilla" "gtk30" "gnome-look" "az:ca:co:fr:gv:it:ro:tr:wa"/"cedilla" "Cedilla" "gtk30" "gnome-look" "az:ca:co:fr:gv:it:ro:tr:wa:en"/g' /usr/lib64/gtk-3.0/3.0.0/immodules.cache`
- disabling automatic screen turn-off (DPMS) on i3 + X11:
    On a minimal i3 setup there is no desktop power manager (`xfce4-power-manager`, GNOME Settings, etc.), but Xorg still enables **DPMS** by default. After about **10 minutes** without keyboard/mouse input, the monitor blanks or powers off (`600/600/600` second timeouts).

    Putting `exec --no-startup-id xset s off -dpms` in `configs/i3/config` is not enough unless `xorg-x11-server-utils` is installed (`xset` comes from that package). If `xset` is missing, i3 silently skips the line and the screen keeps turning off.

    **Fix used here:** build a small helper and run it from i3 at login.

    1. Install build deps (once):
        `sudo dnf install libX11-devel libXext-devel`
    2. Save source as `~/.local/bin/disable-dpms.c` (or copy from `configs/i3/disable-dpms.c` if present in this repo):
        ```c
        #include <stdio.h>
        #include <X11/Xlib.h>
        #include <X11/extensions/dpms.h>

        int main(void) {
            Display *dpy = XOpenDisplay(NULL);
            if (!dpy) {
                fprintf(stderr, "cannot open display\n");
                return 1;
            }
            int event_base = 0, error_base = 0;
            if (!DPMSQueryExtension(dpy, &event_base, &error_base)) {
                fprintf(stderr, "DPMS not available\n");
                XCloseDisplay(dpy);
                return 1;
            }

            CARD16 level = 0;
            BOOL state = False;
            DPMSInfo(dpy, &level, &state);
            CARD16 standby = 0, suspend = 0, off = 0;
            DPMSGetTimeouts(dpy, &standby, &suspend, &off);
            printf("before: enabled=%d level=%u timeouts=%u/%u/%u\n",
                   (int)state, (unsigned)level, (unsigned)standby, (unsigned)suspend, (unsigned)off);

            int timeout = 0, interval = 0, prefer = 0, allow = 0;
            XGetScreenSaver(dpy, &timeout, &interval, &prefer, &allow);
            printf("before screensaver timeout=%d\n", timeout);

            DPMSForceLevel(dpy, DPMSModeOn);
            DPMSDisable(dpy);
            DPMSSetTimeouts(dpy, 0, 0, 0);
            XSetScreenSaver(dpy, 0, 0, prefer, allow);
            XSync(dpy, False);

            DPMSInfo(dpy, &level, &state);
            DPMSGetTimeouts(dpy, &standby, &suspend, &off);
            XGetScreenSaver(dpy, &timeout, &interval, &prefer, &allow);
            printf("after: enabled=%d level=%u timeouts=%u/%u/%u screensaver=%d\n",
                   (int)state, (unsigned)level, (unsigned)standby, (unsigned)suspend, (unsigned)off, timeout);

            XCloseDisplay(dpy);
            return 0;
        }
        ```
    3. Compile and install:
        ```bash
        mkdir -p ~/.local/bin
        cc -O2 -o ~/.local/bin/disable-dpms ~/.local/bin/disable-dpms.c -lX11 -lXext
        ```
    4. Add to `configs/i3/config` (near the end, after other `exec` lines):
        ```i3
        # Disable X DPMS / screensaver idle blanking (xset package not required)
        exec --no-startup-id $HOME/.local/bin/disable-dpms
        ```
    5. Apply immediately (without relogin):
        `DISPLAY=:0 ~/.local/bin/disable-dpms`
        Expected output ends with `after: enabled=0 ... timeouts=0/0/0 screensaver=0`.

    **Verify:** `command -v xset` may still be missing; that is fine. The helper talks to X directly.

    **Alternative:** `sudo dnf install xorg-x11-server-utils` and use `exec --no-startup-id xset s off -dpms` instead of the helper.

    **Not affected by:** `configs/i3/toggle-display.sh` (`$mod+p`). That script only switches outputs with `xrandr` and restarts `gammastep`; it does not re-enable DPMS.

    **If the screen still goes dark:** check the monitor's own OSD power-saving / sleep menu (separate from X DPMS).

yabridge note:
- don't use flatpak to install the DAW to prevent files access issues when syncing plugins

Mounting another disk that needs password:
- list available disks with `lsblk -f`
- mount it with `udisksctl mount -b /dev/${nome do disco}`

installing Ratatouille:
- necessary dependencies (before make):
	`sudo dnf install gcc-c++ make cairo-devel lv2-devel libsndfile-devel libX11-devel`
- build:
	```
    cd ~/.lv2/Ratatouille.lv2
	git submodule update --init --recursive
	make clean
	make lv2
	make install
	```
