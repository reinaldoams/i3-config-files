In the /configs there are my config files that I use in my Fedora i3 Spin machine.
In /files are files to where some config files point.
In fonts folder has the font that I use1

Locations:
- configs/i3/config => ~/.config/i3/config
- configs/i3status/config => ~/.config/i3status/config
- configs/gtk/config => ~/.config/gtk-3.0/settings.ini
- configs/nvim/* => ~/.config/nvim/*
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
- xdg-desktop-portal-gtk should be installed (sudo dnf install) to make flatpak apps to open things outside their sandbox (like a browser opening folder where a downloaded file is located)
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
