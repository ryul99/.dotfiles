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

export HISTSIZE=10000
export SAVEHIST=10000
export HISTFILE=~/.zsh_history

# keybinding
bindkey -v
export KEYTIMEOUT=1
bindkey -M vicmd "^a" beginning-of-line
bindkey -M vicmd "^e" end-of-line
bindkey '^[[H' beginning-of-line
bindkey '^[[1~' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[[4~' end-of-line
bindkey '^[[3~' delete-char
bindkey '^[[1;5C' forward-word
bindkey '^[[1;3C' forward-word
bindkey '^[f' forward-word # for mac
bindkey '^[[1;5D' backward-word
bindkey '^[[1;3D' backward-word
bindkey '^[b' backward-word # for mac
bindkey -r '^D'

# zsh-substring-completion
setopt complete_in_word
setopt always_to_end
export WORDCHARS=''
zmodload -i zsh/complist

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# zsh-history-substring-search
function __zshrc_zsh_history_substring_search_bindkey {
    # lazily config bindkey
    # https://github.com/zsh-users/zsh-syntax-highlighting/issues/411#issuecomment-317077561
    bindkey '^[[A' history-substring-search-up
    bindkey '^[[B' history-substring-search-down
    bindkey '^[OA' history-substring-search-up
    bindkey '^[OB' history-substring-search-down
    bindkey -M vicmd 'k' history-substring-search-up
    bindkey -M vicmd 'j' history-substring-search-down
}

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

# Path
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/git/bin:$PATH"

if (( $+commands[nvim] )); then
    export EDITOR=nvim
else
    export EDITOR=vim
fi

# TIME FMT
export TIMEFMT=$'\n================\nCPU\t%P\nuser\t%*U\nsystem\t%*S\ntotal\t%*E'

### >>> External Programs >>>
# pyenv settings
if [ -d ~/.pyenv ]; then
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
fi

if [ -d ~/.pyenv/plugins/pyenv-virtualenv/ ]; then
    export PYENV_VIRTUALENV_DISABLE_PROMPT=1
fi

# Anaconda3
# see ~/.zshenv for $CONDA_EXE detection
function _conda_initialize() {
if [ -n "${CONDA_EXE}" ]; then
  ${CONDA_EXE} config --set auto_activate_base false
  __conda_setup="$(${CONDA_EXE} 'shell.zsh' 'hook' 2> /dev/null)"
  if [ $? -eq 0 ]; then
      eval "$__conda_setup"
  fi
  unset __conda_setup
fi
}
# Note: conda initialize is slow (0.3 sec), so execute lazily
conda() {
  unfunction conda
  _conda_initialize
  conda "$@"
}

# rbenv settings
if [ -d ~/.rbenv/bin ]; then
  export PATH="$HOME/.rbenv/bin:$PATH"
  eval "$(rbenv init -)"
fi

# nodenv settings
if [ -d ~/.nodenv/bin ]; then
  export PATH="$HOME/.nodenv/bin:$PATH"
  eval "$(nodenv init -)"
fi

# scala setting (coursier install dir)
if [ -d ~/.local/share/coursier/bin ]; then
    export PATH="$PATH:/home/ryul99/.local/share/coursier/bin"
fi

# OPAM configuration
if [ -f ~/.opam/opam-init/init.zsh ]; then
    source ~/.opam/opam-init/init.zsh
fi

# fzf setting
# if [ -f ~/.fzf.zsh ]; then
#     source ~/.fzf.zsh
# fi

# TMUX ssh forwarding
if [ -z "$TMUX" ] && [ ! -S ~/.ssh/ssh_auth_sock ] && [ -S "$SSH_AUTH_SOCK" ]; then
    ln -sf $SSH_AUTH_SOCK ~/.ssh/ssh_auth_sock
fi

# vim coc.clangd setting
CLANGD=$(cd $HOME/.config/coc/extensions/coc-clangd-data/install/*/clang*/bin && echo $PWD) 2> /dev/null
if [ -d $CLANGD ]; then
    export PATH="$PATH:$CLANGD"
fi
unset CLANGD

# cargo
if [ -d ~/.cargo/bin ]; then
    export PATH="$HOME/.cargo/bin:$PATH"
fi

# npm global
if [ -d ~/.npm-global/bin ]; then
    export PATH="$HOME/.npm-global/bin:$PATH"
fi

# perl
if [ -d ~/perl5/bin ]; then
    export PATH="$HOME/perl5/bin:$PATH"
    export PERL5LIB="$HOME/perl5/lib/perl5:$PERL5LIB"
    export PERL_LOCAL_LIB_ROOT="$HOME/perl5:$PERL_LOCAL_LIB_ROOT"
    export PERL_MB_OPT="--install_base \"$HOME/perl5\"";
    export PERL_MM_OPT="INSTALL_BASE=$HOME/perl5";
fi

# ruby
if which ruby >/dev/null && which gem >/dev/null; then
    export GEM_HOME=$HOME/.gem
    export GEM_PATH=$HOME/.gem
fi

### <<< End of External Programs <<<

#
# Zinit
#
export PS1='%n@%m:%~%(!.#.$) '
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

if [[ ! -d "$ZINIT_HOME" ]]; then
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

### Zinit plugins
if [[ -f "${ZINIT_HOME}/zinit.zsh" ]]; then
    source "${ZINIT_HOME}/zinit.zsh"

    zinit depth=1 light-mode for romkatv/powerlevel10k

    function __zshrc_kubectl_aliases_patch {
        sed 's/alias k\(\w*\)a\(\w\?\)=/alias k\1ap\2=/g' .kubectl_aliases > .kubectl_aliases_mod
    }

    function __zshrc_pyenv_atload {
        eval "$(pyenv init --path zsh)"
        command pyenv rehash >/dev/null &!
    }

    zinit wait lucid for \
        has"pyenv" id-as"pyenv" atclone"pyenv init - --no-rehash zsh > pyenv.zsh" atpull"%atclone" run-atpull pick"pyenv.zsh" nocompile"!" atload"!__zshrc_pyenv_atload" ryul99/zinit-null \
        if"[ -d ~/.pyenv/plugins/pyenv-virtualenv/ ]" id-as"pyenv-virtualenv" atclone"pyenv virtualenv-init - zsh > pyenv-virtualenv.zsh" atpull"%atclone" run-atpull pick"pyenv-virtualenv.zsh" nocompile"!" ryul99/zinit-null \
        rupa/z \
        has"fzf" id-as"fzf" multisrc"(completion|key-bindings).zsh" compile"(completion|key-bindings).zsh" svn https://github.com/junegunn/fzf/trunk/shell \
        if"[ -f ~/.asdf/asdf.sh ]" id-as"asdf" pick"$HOME/.asdf/asdf.sh" nocompile ryul99/zinit-null

    # aliases
    zinit wait lucid for \
        light-mode simnalamburt/cgitc \
        light-mode ahmetb/kubectl-aliases

    # completions
    zinit wait lucid for \
        light-mode zsh-users/zsh-completions \
        has"helm" id-as"helm-completion" as"completion" atclone"helm completion zsh > _helm" atpull"%atclone" run-atpull ryul99/zinit-null \
        has"poetry" id-as"poetry-completion" as"completion" atclone"poetry completions zsh > _poetry" atpull"%atclone" run-atpull ryul99/zinit-null

    # last group
    zinit wait lucid for \
        atload"__zshrc_zsh_history_substring_search_bindkey" zsh-users/zsh-history-substring-search \
        atload"zicompinit; zicdreplay" blockf zsh-users/zsh-autosuggestions \
        zdharma-continuum/fast-syntax-highlighting
fi
### End of Zinit plugins

#
# Etc
#

# >>> command completion >>>
# autoload -U +X bashcompinit && bashcompinit
# <<< command completion <<<

# local settings
if [ -f ~/.zshrc.local ]; then
    source ~/.zshrc.local
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
