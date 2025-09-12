#            _
#    _______| |__  _ __ ___
#   |_  / __| '_ \| '__/ __|
#  _ / /\__ \ | | | | | (__
# (_)___|___/_| |_|_|  \___|
#

# DON'T CHANGE THIS FILE

# You can define your custom configuration by adding
# files in ~/.config/zsh/zshrc
# or by creating a folder ~/.config/zsh/zshrc/custom
# with copies of files from ~/.config/zsh/zshrc
# -----------------------------------------------------

# -----------------------------------------------------
# Load configuration
# -----------------------------------------------------

for f in $HOME/.config/zsh/zshrc/*; do
    if [ ! -d $f ]; then
        c=`echo $f | sed -e "s=zshrc=zshrc/custom="`
        [[ -f $c ]] && source $c || source $f
    fi
done 

export PATH=/home/patrik/.opencode/bin:$PATH