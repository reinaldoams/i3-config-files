# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

alias configi3="nvim ~/.config/i3/config"
alias configi3status="nvim ~/.config/i3status/config"
alias configbashrc="nvim ~/.bashrc"
alias confignvim="nvim ~/.config/nvim/init.lua"
alias heroic="flatpak run com.heroicgameslauncher.hgl"
alias btop="sudo btop"

# plex
alias plex-start="sudo systemctl start plexmediaserver"
alias plex-stop="sudo systemctl stop plexmediaserver"
alias plex-restart="sudo systemctl restart plexmediaserver"
alias plex-status="sudo systemctl status plexmediaserver"

# git alias
alias gs-="git status"
alias gd-="git diff --ignore-all-space"
alias ga-="git add"
alias gco-="git commit"
alias gch-="git checkout"
alias gps-="git push"
alias gpl-="git pull"
alias gl-="git log"

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
    for rc in ~/.bashrc.d/*; do
        if [ -f "$rc" ]; then
            . "$rc"
        fi
    done
fi
unset rc
export PATH="$PATH:$HOME/.local/share/yabridge"
export XSECURELOCK_SAVER_MODULE_PATH="/usr/libexec/xsecurelock/saver_mpv"
export XSECURELOCK_MPV_ARGS="--loop-file /home/reinaldo/Videos/lock-screen-video.mp4"

# Qwen Code PATH block begin
export PATH='/home/reinaldo/.local/bin':$PATH
# Qwen Code PATH block end
