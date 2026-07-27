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
rsync -a $EXCLUDES ~/.config/i3status/ ./configs/i3status/
echo 'imported i3status configs'
rsync -a $EXCLUDES ~/.config/nvim/ ./configs/nvim/
echo 'imported nvim configs'
#rsync -a $EXCLUDES ~/.config/polybar/ ./configs/polybar/
#echo 'imported polybar configs'
#rsync -a $EXCLUDES ~/.config/picom/ ./configs/picom/
#echo 'imported picom configs'
#rsync -a $EXCLUDES ~/.config/MangoHud/ ./configs/MangoHud/
#echo 'imported MangoHud configs'
mkdir -p ./configs/dunst
rsync -a ~/.config/dunst/dunstrc ./configs/dunst/dunstrc
echo 'imported dunst dunstrc'
rsync -a ~/.bashrc ./configs/.bashrc
echo 'imported .bashrc'
