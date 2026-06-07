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

Additional steps:
- adding name of currently open window to i3status bar:
    https://github.com/rholder/i3status-title-on-bar/
