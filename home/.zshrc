#
# zsh-sensible
#
stty stop undef

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

[[ -o interactive ]] || return

if [[ -a /proc/version ]] && grep -q Microsoft /proc/version; then
  unsetopt BG_NICE
fi

#
# Configs
#

setopt auto_cd histignorealldups sharehistory
zstyle ':completion:*' menu select

export HISTSIZE=10000
export SAVEHIST=10000
export HISTFILE=~/.zsh_history

#
# zsh-substring-completion
#

setopt complete_in_word
setopt always_to_end
export WORDCHARS=''
zmodload -i zsh/complist

zstyle ':completion:*' matcher-list 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down

# zsh-autosuggestions
typeset -g ZSH_AUTOSUGGEST_USE_ASYNC=1
typeset -g ZSH_AUTOSUGGEST_STRATEGY=(history completion)

#
# zshrc
#

# aliases
if [ -f ~/.sh_aliases ]; then
    source ~/.sh_aliases
fi

if [ -f ~/.zsh_aliases ]; then
    source ~/.zsh_aliases
fi

DEFAULT_USER="$USER" # for shellder

# Path
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/git/bin:$PATH"

if [ -d ~/.cargo/bin ]; then
    export PATH="$HOME/.cargo/bin:$PATH"
fi

if [ -d ~/.npm-global/bin ]; then
    export PATH="$HOME/.npm-global/bin:$PATH"
fi

if [ -d ~/perl5/bin ]; then
    export PATH="$HOME/perl5/bin:$PATH"
    export PERL5LIB="$HOME/perl5/lib/perl5:$PERL5LIB"
    export PERL_LOCAL_LIB_ROOT="$HOME/perl5:$PERL_LOCAL_LIB_ROOT"
    export PERL_MB_OPT="--install_base \"$HOME/perl5\"";
    export PERL_MM_OPT="INSTALL_BASE=$HOME/perl5";
fi

if which ruby >/dev/null && which gem >/dev/null; then
    export GEM_HOME=$HOME/.gem
    export GEM_PATH=$HOME/.gem
fi

# keybinding
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[[3~' delete-char
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word

### Added by zplug's installer
if [[ ! -d $HOME/.zplug ]]; then
    curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh
fi

source "$HOME/.zplug/init.zsh"
### End of zplug's installer chunk

### zplug plugins
if [[ -f ~/.zplug/init.zsh ]]; then
    zplug 'zplug/zplug', hook-build:'zplug --self-manage'
    zplug romkatv/powerlevel10k, as:theme, depth:1
    zplug simnalamburt/cgitc
    # zplug simnalamburt/zsh-expand-all
    zplug ahmetb/kubectl-aliases, use:".kubectl_aliases"
    zplug voronkovich/gitignore.plugin.zsh
    zplug rupa/z, use:"z.sh"
    zplug zsh-users/zsh-completions
    zplug zsh-users/zsh-autosuggestions
    zplug zsh-users/zsh-history-substring-search
    zplug zsh-users/zsh-syntax-highlighting, defer:2

    # zplug check returns true if all packages are installed
    # Therefore, when it returns false, run zplug install
    if ! zplug check; then
        zplug install
    fi

    # source plugins and add commands to the PATH
    zplug load
fi
### End of zplug plugins

### >>> External Programs >>>
# >>> pyenv settings >>>
if [ -d ~/.pyenv/bin ]; then
  export PYENV_ROOT="$HOME/.pyenv"
  export PATH="$PYENV_ROOT/bin:$PATH"
fi

if command -v pyenv 1>/dev/null 2>&1; then
  # eval "$(pyenv init --path)"
  eval "$(pyenv init -)"
  eval "$(pyenv virtualenv-init -)"
fi
# <<< pyenv settings <<<

# Anaconda3
# see ~/.zshenv for $CONDA_EXE detection
function _conda_initialize() {
# >>> conda initialize >>>
if [ -n "${CONDA_EXE}" ]; then
  ${CONDA_EXE} config --set auto_activate_base false
  __conda_setup="$(${CONDA_EXE} 'shell.zsh' 'hook' 2> /dev/null)"
  if [ $? -eq 0 ]; then
      eval "$__conda_setup"
  fi
  unset __conda_setup
fi
# <<< conda initialize <<<
}
# Note: conda initialize is slow (0.3 sec), so execute lazily
conda() {
  unfunction conda
  _conda_initialize
  conda "$@"
}

# OPAM configuration
if [ -f ~/.opam/opam-init/init.zsh ]; then
    source ~/.opam/opam-init/init.zsh
fi

if [ -f ~/.fzf.zsh ]; then
    source ~/.fzf.zsh
fi

# TMUX ssh forwarding
if [ -z "$TMUX" ] && [ ! -S ~/.ssh/ssh_auth_sock ] && [ -S "$SSH_AUTH_SOCK" ]; then
    ln -sf $SSH_AUTH_SOCK ~/.ssh/ssh_auth_sock
fi
### <<< End of External Programs <<<

#
# Etc
#

# local settings
if [ -f ~/.zshrc.local ]; then
    source ~/.zshrc.local
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
