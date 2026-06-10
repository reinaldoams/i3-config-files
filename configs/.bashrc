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

# git alias
alias gs-="git status"
alias gd-="git diff --ignore-all-space"
alias ga-="git add"
alias gco-="git commit"
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
