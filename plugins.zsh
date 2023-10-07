export PLUG_DIR=$HOME/.local/share/zim/modules/
if [[ ! -d $PLUG_DIR ]]; then
	  curl -fsSL https://raw.githubusercontent.com/zimfw/install/master/install.zsh | zsh
    rm ~/.zimrc
    ln -s ~/.config/zsh/zimrc ~/.zimrc
fi
