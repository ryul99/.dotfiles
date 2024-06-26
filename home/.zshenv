#
# Defines environment variables.
#
# See also: ~/.zsh/zsh.d/envs.zsh
#
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#   Jongwook Choi <wookayin@gmail.com>
#

#
# Browser
#

if [[ "$OSTYPE" == darwin* ]]; then
  export BROWSER='open'
fi

#
# Editors
#

export EDITOR='vim'
export VISUAL='vim'
export PAGER='less'

#
# Language
#

if [[ -z "$LANG" ]]; then
  export LANG='en_US.UTF-8'
fi

# Fix broken, wrong LC variables (e.g. kitty)
if [[ "$LC_CTYPE" == "UTF-8" ]]; then
  export LC_CTYPE='en_US.UTF-8'
fi

#
# Paths
#

typeset -gU cdpath fpath mailpath path

# [For Mac M1 USERS]
# Homebrew: /opt/homebrew/bin must precede /usr/local/bin.
# Please update /etc/paths: add `/opt/homebrew/bin` manually.

# Set the the list of directories that cd searches.
# cdpath=(
#   $cdpath
# )

# Set the list of directories that Zsh searches for programs.
# see ~/.zprofile as well
path=(
  $path
  /usr/local/{bin,sbin}
)

# Let ~/.local/bin take precedence
if ! (( ${path[(I)$HOME/.local/bin]} )); then
  path=( $HOME/.local/bin $path )
fi

# Additional $PATH configuration:

# dotfiles-populated bin.
if [ -d $HOME/.dotfiles/bin/ ]; then
  path=( $path $HOME/.dotfiles/bin )
fi

# Cleanup some anaconda environment variables to avoid messing up in tmux, etc.
# (these environment variables might be copied and inherited unwantedly)
unset CONDA_EXE
unset CONDA_PREFIX
unset CONDA_DEFAULT_ENV
unset CONDA_PYTHON_EXE
unset CONDA_SHLVL

# Miniconda3
if [ -d "$HOME/.miniconda3/bin/" ]; then
  path=( $path "$HOME/.miniconda3/bin" )
  export CONDA_EXE="$HOME/.miniconda3/bin/conda"
elif [ -d "$HOME/miniconda3/bin/" ]; then
  path=( $path "$HOME/miniconda3/bin/" )
  export CONDA_EXE="$HOME/miniconda3/bin/conda"
elif [ -d "/usr/local/miniconda3/" ]; then
  path=( $path "/usr/local/miniconda3/bin" )
  export CONDA_EXE="/usr/local/miniconda3/bin/conda"
fi

# Anaconda3 (deprecated, should prefer miniconda3)
if [ -d $HOME/.anaconda3/bin/ ]; then
  path=( $path $HOME/.anaconda3/bin )
  if [[ "$CONDA_EXE" != *"miniconda"* ]]; then
    export CONDA_EXE=$HOME/.anaconda3/bin/conda
  fi
fi

# rust (cargo)
if [ -d $HOME/.cargo/bin/ ]; then
  path=( $path $HOME/.cargo/bin )
fi
if [ -f "$HOME/.cargo/env" ]; then
  source "$HOME/.cargo/env"
fi


#
# Less
#

# Set the default Less options.
# Mouse-wheel scrolling has been disabled by -X (disable screen clearing).
# Remove -X and -F (exit if the content fits on one screen) to enable it.
export LESS='-F -g -i -M -R -S -w -X -z-4'

# Set the Less input preprocessor.
if (( $+commands[lesspipe.sh] )); then
  export LESSOPEN='| /usr/bin/env lesspipe.sh %s 2>&-'
fi

#
# Temporary Files
#

if [[ -d "$TMPDIR" ]]; then
  export TMPPREFIX="${TMPDIR%/}/zsh"
  if [[ ! -d "$TMPPREFIX" ]]; then
    mkdir -p "$TMPPREFIX"
  fi
fi


#
# Add custom config directory for Prezto.
#  (note that this line is executed before initialization of prezto.)
#
fpath=(${ZDOTDIR:-$HOME}/.zsh/prezto-themes ~/.local/share/zsh/site-functions $fpath)


#
# Python - Virtualenv, etc.
#

if [[ "$(uname)" == "Darwin" ]]; then
    # Mac OS X: use python shipped by Homebrew for virtualenv.
    export VIRTUALENVWRAPPER_PYTHON='/usr/local/bin/python'
else
    # use default system python for virtualenv.
    export VIRTUALENVWRAPPER_PYTHON='/usr/bin/python'
fi

# Set the directory where virtual environments are stored.
export WORKON_HOME="$HOME/.virtualenvs"
export VIRTUAL_ENV_DISABLE_PROMPT=1

# ensure that all new virtual environments are isolated from the system site-packages.
# (--no-site-packages has been removed since virtualenv >= 20, which has been the default option)
# export VIRTUALENVWRAPPER_VIRTUALENV_ARGS='--no-site-packages'

# python startup
# export PYTHONSTARTUP=$HOME/.pythonrc.py


# Disable dot files in archive
export COPYFILE_DISABLE=true

if [ -f "$HOME/.zshenv.local" ]; then
  source "$HOME/.zshenv.local"
fi
