In the /configs there are my config files that I use in my Fedora i3 Spin machine.
In /files are files to where some config files point.
In /fonts has the font that I use: Cascadia Mono Regular, used in xfce4-terminal at size 16.
Outside the terminal (i3 config), the font used is Cousine Nerd Font Mono at size 14.

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

yabridge note:
- don't use flatpak to install the DAW to prevent files access issues when syncing plugins

Zed editor setup:
- keymap file location: `~/.config/zed/keymap.json`
- fix for ctrl-p (file finder) not working when the project panel (sidebar) is focused, add:
    ```json
    [
      {
        "context": "ProjectPanel",
        "bindings": {
          "ctrl-p": "file_finder::Toggle"
        }
      }
    ]
    ```

fixing wifi because of setup being i3 on top of debian kde:
```
# Replace CONN and WIFI_PASSWORD
CONN="mineral_2.4"
WIFI_PASSWORD='your-wifi-password'
sudo nmcli connection modify "$CONN" \
  802-11-wireless-security.psk "$WIFI_PASSWORD" \
  802-11-wireless-security.psk-flags 0
# Reload and reconnect
sudo nmcli connection reload
nmcli connection down "$CONN"
nmcli connection up "$CONN"
```
