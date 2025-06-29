#!/usr/bin/env python3
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
import json
import os
import sys
import subprocess

from sys import stderr

try:
    from distutils.spawn import find_executable
except ImportError:
    # In some environments, distutils might not be available.
    import sys
    sys.stderr.write("WARNING: distutils not available\n")
    find_executable = lambda _: False   # type: ignore

def _wrap_colors(ansicode):
    return (lambda msg: ansicode + str(msg) + '\033[0m')

GRAY   = _wrap_colors("\033[0;37m")
WHITE  = _wrap_colors("\033[1;37m")
RED    = _wrap_colors("\033[0;31m")
GREEN  = _wrap_colors("\033[0;32m")
YELLOW = _wrap_colors("\033[0;33m")
CYAN   = _wrap_colors("\033[0;36m")
BLUE   = _wrap_colors("\033[0;34m")

if sys.version_info[0] >= 3:  # python3
    unicode = lambda s, _: str(s)
    from builtins import input
else:  # python2
    input = sys.modules['__builtin__'].raw_input

################# BEGIN OF FIXME #################

def get_post_actions(args):
    post_actions = []

    post_actions += [
        '''#!/bin/bash
        # Check whether and ~/.zsh are well-configured
        for f in ~/.zshrc; do
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
        # validate neovim package installation on python2/3 and automatically install if missing
        bash "scripts/install-neovim-py.sh"
    ''']

    if find_executable('nvim'):
        post_actions += [{
             'update'  : '''nvim --headless "+Lazy! sync" +qa''',
             'none'    : "# (neovim update skipped)",
        }['update' if args.set_nvim else 'none']]

    return post_actions


################# END OF FIXME #################


def parsing_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('-f', '--force', action="store_true", default=False,
                        help='If set, it will override existing symbolic links')
    parser.add_argument('--set-nvim', action='store_true',
                        help='If set, update neovim plugins.')
    parser.add_argument('--symlink', action='store_true',
                        help='If set, only create symlinks.')

    args = parser.parse_args()

    return args


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


def check_submodule():
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
            except Exception:
                pass
            log("Running: %s" % BLUE(git_submodule_update_cmd))
            subprocess.call(git_submodule_update_cmd, shell=True)
        else:
            log(RED("Aborted."))
            sys.exit(1)


def create_symlink(args):
    log_boxed("Creating symbolic links", color_fn=CYAN)
    task = dict()
    with open('file_mappings.json', 'r') as file:
        tasks = json.load(file)
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


def run_post_actions(args):
    from signal import signal, SIGPIPE, SIG_DFL

    post_actions = get_post_actions(args)
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

    return len(errors)


def main():
    global current_dir
    current_dir = os.path.abspath(os.path.dirname(__file__))
    os.chdir(current_dir)

    check_submodule()

    args = parsing_args()
    create_symlink(args)
    if args.symlink:
        sys.exit()
    exit_code = run_post_actions(args)

    log("- Please restart shell (e.g. " + CYAN("`exec zsh`") + ") if necessary.")
    log("\n\n", cr=False)

    sys.exit(exit_code)

if __name__ == "__main__":
    main()
