#            _
#    _______| |__  _ __ ___
#   |_  / __| '_ \| '__/ __|
#  _ / /\__ \ | | | | | (__
# (_)___|___/_| |_|_|  \___|
#

# DON'T CHANGE THIS FILE

# You can define your custom configuration by adding
# files in ~/nixos-config/dotfiles/zsh/zshrc
# or by creating a folder ~/nixos-config/dotfiles/zsh/zshrc/custom
# with copies of files from ~/nixos-config/dotfiles/zsh/zshrc
# -----------------------------------------------------

# -----------------------------------------------------
# Load configarion
# -----------------------------------------------------

for f in $HOME/nixos-config/dotfiles/zsh/zshrc/*; do
    if [ ! -d $f ]; then
        c=`echo $f | sed -e "s=zshrc=zshrc/custom="`
        [[ -f $c ]] && source $c || source $f
    fi
done
