#            _
#    _______| |__  _ __ ___
#   |_  / __| '_ \| '__/ __|
#  _ / /\__ \ | | | | | (__
# (_)___|___/_| |_|_|  \___|
#

# DON'T CHANGE THIS FILE

# You can define your custom configuration by adding
# files in ~/repos/personal/nix-config/dotfiles/zsh/zshrc
# or by creating a folder ~/repos/personal/nix-config/dotfiles/zsh/zshrc/custom
# with copies of files from ~/repos/personal/nix-config/dotfiles/zsh/zshrc
# -----------------------------------------------------

# -----------------------------------------------------
# Load configarion
# -----------------------------------------------------

for f in $HOME/repos/personal/nix-config/dotfiles/zsh/zshrc/*; do
    if [ ! -d $f ]; then
        c=`echo $f | sed -e "s=zshrc=zshrc/custom="`
        [[ -f $c ]] && source $c || source $f
    fi
done
