#!/usr/bin/env python
# -*- coding: utf-8 -*-
# Ref: https://github.com/wookayin/dotfiles/blob/master/install.py

'''
   @ryul99's                ███████╗██╗██╗     ███████╗███████╗
   ██████╗  █████╗ ████████╗██╔════╝██║██║     ██╔════╝██╔════╝
   ██╔══██╗██╔══██╗╚══██╔══╝█████╗  ██║██║     █████╗  ███████╗
   ██║  ██║██║  ██║   ██║   ██╔══╝  ██║██║     ██╔══╝  ╚════██║
   ██████╔╝╚█████╔╝   ██║   ██║     ██║███████╗███████╗███████║
   ╚═════╝  ╚════╝    ╚═╝   ╚═╝     ╚═╝╚══════╝╚══════╝╚══════╝

'''
print(__doc__)  # print logo.


import argparse
parser = argparse.ArgumentParser()
parser.add_argument('-f', '--force', action="store_true", default=False,
                    help='If set, it will override existing symbolic links')
parser.add_argument('--skip-vimplug', action='store_true',
                    help='If set, do not update vim plugins.')
parser.add_argument('--skip-zgen', '--skip-zplug', action='store_true',
                    help='If set, skip zgen updates.')

args = parser.parse_args()

################# BEGIN OF FIXME #################

# Task Definition
# (path of target symlink) : (location of source file in the repository)
tasks = {
    # SSH
    '~/.ssh/config' : 'home/.ssh/config',

    # SHELLS
    '~/.bashrc' : 'home/.bashrc',
    '~/.sh_aliases' : 'home/.sh_aliases',

    # VIM
    '~/.vimrc' : 'home/.vimrc',
    '~/.vim' : 'home/.vim',
    '~/.vim/autoload/plug.vim' : 'home/.vim/bundle/vim-plug/plug.vim',
    '~/.config/nvim' : 'home/.config/nvim',

    # GIT
    '~/.gitconfig' : 'home/.gitconfig',
    '~/.gitexclude' : 'home/.gitexclude',

    # ZSH
    '~/.zshrc' : 'home/.zshrc',
    '~/.zshenv' : 'home/.zshenv',
    '~/.p10k.zsh' : 'home/.p10k.zsh',

    # Bins
    '~/.local/bin/dotfiles' : 'bin/dotfiles',
    '~/.local/bin/fasd' : 'bin/fasd',
    '~/.local/bin/is_mosh' : 'bin/is_mosh',
    # '~/.local/bin/fzf' : '~/.fzf/bin/fzf', # fzf is at $HOME/.fzf

    # tmux
    '~/.tmux' : 'home/.tmux',
    '~/.tmux.conf' : 'home/.tmux.conf',
}


try:
    from distutils.spawn import find_executable
except ImportError:
    # In some environments, distutils might not be available.
    import sys
    sys.stderr.write("WARNING: distutils not available\n")
    find_executable = lambda _: False   # type: ignore


post_actions = []

post_actions += [
    '''#!/bin/bash
    # Check whether ~/.vim and ~/.zsh are well-configured
    for f in ~/.vim ~/.vimrc ~/.zshrc; do
        if ! readlink $f >/dev/null; then
            echo -e "\033[0;31m\
WARNING: $f is not a symbolic link to ~/.dotfiles.
Please remove your local folder/file $f and try again.\033[0m"
            echo -n "(Press any key to continue) "; read user_confirm
            exit 1;
        else
            echo "$f --> $(readlink $f)"
        fi
    done ''']

post_actions += [
    '''#!/bin/bash
    # Download command line scripts
    mkdir -p "$HOME/.local/bin/"
    _download() {
        curl -L "$2" > "$1" && chmod +x "$1"
    }
    ret=0
    set -v
    _download "$HOME/.local/bin/video2gif" "https://raw.githubusercontent.com/wookayin/video2gif/master/video2gif" || ret=1
    exit $ret;
''']

post_actions += [
    '''#!/bin/bash
    # validate neovim package installation on python2/3 and automatically install if missing
    bash "etc/install-neovim-py.sh"
''']

vim = 'nvim' if find_executable('nvim') else 'vim'
post_actions += [
    # Run vim-plug installation
    {'install' : '{vim} +PlugInstall +qall'.format(vim=vim),
     'update'  : '{vim} +PlugUpdate  +qall'.format(vim=vim),
     'none'    : '# {vim} +PlugUpdate (Skipped)'.format(vim=vim)
     }['update' if not args.skip_vimplug else 'none']
]

post_actions += [
    r'''#!/bin/bash
    # Setting up for coc.nvim (~/.config/coc, node.js)

    # (i) create ~/.config/coc directory if not exists
    GREEN="\033[0;32m"; YELLOW="\033[0;33m"; RESET="\033[0m";
    coc_dir="$HOME/.config/coc/"
    if [ ! -d "$coc_dir" ]; then
	mkdir -p "$coc_dir" || exit 1;
	echo "Created: $coc_dir"
    else
	echo -e "${GREEN}coc directory:${RESET}   $coc_dir"
    fi

    # (ii) validate or auto-install node.js locally
    bash "etc/install-node.sh" || exit 1;
''']

post_actions += [
    r'''#!/bin/bash
    # Change default shell to zsh
    /bin/zsh --version >/dev/null || (\
        echo -e "\033[0;31mError: /bin/zsh not found. Please install zsh.\033[0m"; exit 1)
    if [[ ! "$SHELL" = *zsh ]]; then
        echo -e '\033[0;33mPlease type your password if you wish to change the default shell to ZSH\e[m'
        chsh -s /bin/zsh && echo -e 'Successfully changed the default shell, please re-login'
    else
        echo -e "\033[0;32m\$SHELL is already zsh.\033[0m $(zsh --version)"
    fi
''']


################# END OF FIXME #################


def _wrap_colors(ansicode):
    return (lambda msg: ansicode + str(msg) + '\033[0m')
GRAY   = _wrap_colors("\033[0;37m")
WHITE  = _wrap_colors("\033[1;37m")
RED    = _wrap_colors("\033[0;31m")
GREEN  = _wrap_colors("\033[0;32m")
YELLOW = _wrap_colors("\033[0;33m")
CYAN   = _wrap_colors("\033[0;36m")
BLUE   = _wrap_colors("\033[0;34m")


import os
import sys
import subprocess

from signal import signal, SIGPIPE, SIG_DFL
from sys import stderr

if sys.version_info[0] >= 3:  # python3
    unicode = lambda s, _: str(s)
    from builtins import input
else:  # python2
    input = sys.modules['__builtin__'].raw_input


def log(msg, cr=True):
    stderr.write(msg)
    if cr:
        stderr.write('\n')

def log_boxed(msg, color_fn=WHITE, use_bold=False, len_adjust=0):
    import unicodedata
    pad_msg = (" " + msg + "  ")
    l = sum(not unicodedata.combining(ch) for ch in unicode(pad_msg, 'utf-8')) + len_adjust
    if use_bold:
        log(color_fn("┏" + ("━" * l) + "┓\n" +
                     "┃" + pad_msg   + "┃\n" +
                     "┗" + ("━" * l) + "┛\n"), cr=False)
    else:
        log(color_fn("┌" + ("─" * l) + "┐\n" +
                     "│" + pad_msg   + "│\n" +
                     "└" + ("─" * l) + "┘\n"), cr=False)

def makedirs(target, mode=511, exist_ok=False):
    try:
        os.makedirs(target, mode=mode)
    except OSError as ex:  # py2 has no exist_ok=True
        import errno
        if ex.errno == errno.EEXIST and exist_ok: pass
        else: raise

# get current directory (absolute path)
current_dir = os.path.abspath(os.path.dirname(__file__))
os.chdir(current_dir)

# check if git submodules are loaded properly
stat = subprocess.check_output("git submodule status --recursive",
                               shell=True, universal_newlines=True)
submodule_issues = [(l.split()[1], l[0]) for l in stat.split('\n') if len(l) and l[0] != ' ']

if submodule_issues:
    stat_messages = {'+': 'needs update', '-': 'not initialized', 'U': 'conflict!'}
    for (submodule_name, submodule_stat) in submodule_issues:
        log(RED("git submodule {name} : {status}".format(
            name=submodule_name,
            status=stat_messages.get(submodule_stat, '(Unknown)'))))
    log(RED(" you may run: $ git submodule update --init --recursive"))

    log("")
    log(YELLOW("Do you want to update submodules? (y/n) "), cr=False)
    shall_we = (input().lower() == 'y')
    if shall_we:
        git_submodule_update_cmd = 'git submodule update --init --recursive'
        # git 2.8+ supports parallel submodule fetching
        try:
            git_version = str(subprocess.check_output("""git --version | awk '{print $3}'""", shell=True))
            if git_version >= '2.8': git_submodule_update_cmd += ' --jobs 8'
        except Exception as ex:
            pass
        log("Running: %s" % BLUE(git_submodule_update_cmd))
        subprocess.call(git_submodule_update_cmd, shell=True)
    else:
        log(RED("Aborted."))
        sys.exit(1)


log_boxed("Creating symbolic links", color_fn=CYAN)
for target, source in sorted(tasks.items()):
    # normalize paths
    source = os.path.join(current_dir, os.path.expanduser(source))
    target = os.path.expanduser(target)

    # bad entry if source does not exists...
    if not os.path.lexists(source):
        log(RED("source %s : does not exist" % source))
        continue

    # if --force option is given, delete and override the previous symlink
    if os.path.lexists(target):
        is_broken_link = os.path.islink(target) and not os.path.exists(os.readlink(target))

        if args.force or is_broken_link:
            if os.path.islink(target):
                os.unlink(target)
            else:
                log("{:50s} : {}".format(
                    BLUE(target),
                    YELLOW("already exists but not a symbolic link; --force option ignored")
                ))
        else:
            log("{:50s} : {}".format(
                BLUE(target),
                GRAY("already exists, skipped") if os.path.islink(target) \
                    else YELLOW("exists, but not a symbolic link. Check by yourself!!")
            ))

    # make a symbolic link if available
    if not os.path.lexists(target):
        mkdir_target = os.path.split(target)[0]
        makedirs(mkdir_target, exist_ok=True)
        log(GREEN('Created directory : %s' % mkdir_target))
        os.symlink(source, target)
        log("{:50s} : {}".format(
            BLUE(target),
            GREEN("symlink created from '%s'" % source)
        ))

errors = []
for action in post_actions:
    if not action:
        continue

    action_title = action.strip().split('\n')[0].strip()
    if action_title == '#!/bin/bash':
        action_title = action.strip().split('\n')[1].strip()

    log("\n", cr=False)
    log_boxed("Executing: " + action_title, color_fn=CYAN)
    ret = subprocess.call(['bash', '-c', action],
                          preexec_fn=lambda: signal(SIGPIPE, SIG_DFL))

    if ret:
        errors.append(action_title)

log("\n")
if errors:
    log_boxed("You have %3d warnings or errors -- check the logs!" % len(errors),
              color_fn=YELLOW, use_bold=True)
    for e in errors:
        log("   " + YELLOW(e))
    log("\n")
else:
    log_boxed("✔  You are all set! ",
              color_fn=GREEN, use_bold=True)

log("- Please restart shell (e.g. " + CYAN("`exec zsh`") + ") if necessary.")
log("\n\n", cr=False)

sys.exit(len(errors))
