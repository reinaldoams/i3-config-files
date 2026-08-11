if [ -d "./configs" ]; then
  echo "configs folder exists"
else
  mkdir configs
  echo "configs folder created"
fi

EXCLUDES='--exclude=.git --exclude=.gitignore --exclude=.gitmodules'

rsync -a $EXCLUDES ~/.config/gtk-3.0/ ./configs/gtk-3.0/
echo 'imported gtk configs'
rsync -a $EXCLUDES ~/.config/i3/ ./configs/i3/
echo 'imported i3 configs'
# LightDM greeter (system file; theme CSS lives under configs/i3/lightdm-black-theme/)
mkdir -p ./configs/lightdm
rsync -a /etc/lightdm/lightdm-gtk-greeter.conf ./configs/lightdm/lightdm-gtk-greeter.conf
echo 'imported lightdm-gtk-greeter.conf'
rsync -a $EXCLUDES ~/.config/i3status/ ./configs/i3status/
echo 'imported i3status configs'
rsync -a $EXCLUDES ~/.config/nvim/ ./configs/nvim/
echo 'imported nvim configs'
rsync -a $EXCLUDES ~/.config/picom/ ./configs/picom/
echo 'imported picom configs'
rsync -a $EXCLUDES ~/.config/MangoHud/ ./configs/MangoHud/
echo 'imported MangoHud configs'
mkdir -p ./configs/dunst
rsync -a ~/.config/dunst/dunstrc ./configs/dunst/dunstrc
echo 'imported dunst dunstrc'
mkdir -p ./configs/systemd/user
rsync -a ~/.config/systemd/user/i3-session.target ./configs/systemd/user/i3-session.target
echo 'imported systemd i3-session.target'
rsync -a ~/.bashrc ./configs/.bashrc
echo 'imported .bashrc'
rsync -a ~/.bash_profile ./configs/.bash_profile
echo 'imported .bash_profile'
rsync -a ~/.XCompose ./configs/.XCompose
echo 'imported .XCompose'
mkdir -p ./configs/environment.d
rsync -a ~/.config/environment.d/90-cedilla.conf ./configs/environment.d/90-cedilla.conf
echo 'imported environment.d cedilla'
mkdir -p ./configs/xfce4-terminal
rsync -a ~/.config/xfce4/terminal/terminalrc ./configs/xfce4-terminal/terminalrc
rsync -a $EXCLUDES ~/.local/share/xfce4/terminal/colorschemes/ ./configs/xfce4-terminal/colorschemes/
echo 'imported xfce4-terminal configs'
