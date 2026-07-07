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
yabridge note:
- don't use flatpak to install the DAW to prevent files access issues when syncing plugins

Mounting another disk that needs password:
- list available disks with `lsblk -f`
- mount it with `udisksctl mount -b /dev/${nome do disco}`