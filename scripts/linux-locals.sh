#!/bin/bash
# vim: set expandtab ts=2 sts=2 sw=2:

# A collection of bash scripts for installing some libraries/packages in
# user namespaces (e.g. ~/.local/), without having root privileges.

set -e   # fail when any command fails
set -o pipefail

PREFIX="$HOME/.local"
mkdir -p $PREFIX/share/zsh/site-functions
mkdir -p $PREFIX/bin

DOTFILES_TMPDIR="/tmp/$USER/linux-locals"

COLOR_NONE="\033[0m"
COLOR_RED="\033[0;31m"
COLOR_GREEN="\033[0;32m"
COLOR_YELLOW="\033[0;33m"
COLOR_CYAN="\033[0;36m"
COLOR_WHITE="\033[1;37m"

#---------------------------------------------------------------------------------------------------

install_font() {
  set -ex
  local TMP_DIR="$DOTFILES_TMPDIR/font"
  mkdir -p "$TMP_DIR" && cd "$TMP_DIR"

  curl -OL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/CascadiaMono.tar.xz
  tar -xvf CascadiaMono.tar.xz
  mv CaskaydiaMonoNerdFont* ~/.config/wezterm/fonts/
}

#---------------------------------------------------------------------------------------------------

_glibc_version() {
  # https://stackoverflow.com/questions/71070969/how-to-extract-and-compare-the-libc-versions-at-runtime
  local libcfile="$(grep -azm1 '/libc.so.6$' /etc/ld.so.cache | tr -d '\0')"
  grep -aoP 'GNU C Library [^\n]* release version \K[0-9]*.[0-9]*' "$libcfile"
}

_version_check() {
  # _version_check {curver} {targetver}: exit code is 0 if curver >= targetver
  local curver="$1"; local targetver="$2";
  [ "$targetver" = "$(echo -e "$curver\n$targetver" | sort -V | head -n1)" ]
}

_which() {
  which "$@" >/dev/null || { echo "$@ not found"; return 1; }
  echo -e "\n${COLOR_CYAN}$(which "$@")${COLOR_NONE}"
}

# _template_github_latest <name> <namespace/repo> <file *pattern* to match>
# Downloads the latest release from GitHub, extracts it
_template_github_latest() {
  local name="$1"
  local repo="$2"
  local filename="$3"
  if [[ -z "$name" ]] || [[ -z "$repo" ]] || [[ -z "$filename" ]]; then
    echo "Wrong usage"; return 1;
  fi

  echo -e "${COLOR_YELLOW}Installing $name from $repo ... ${COLOR_NONE}"
  local releases_url="https://api.github.com/repos/${repo}/releases"
  echo -e "${COLOR_YELLOW}Reading: ${COLOR_NONE}$releases_url"
  local download_url=$(\
    curl -fsSL "$releases_url" 2>/dev/null \
    | python3 -c "\
import json, sys, fnmatch;
I = sys.stdin.read()
try:
  J = json.loads(I)
except:
  sys.stderr.write(I)
  raise
for asset in J[0]['assets']:
  if fnmatch.fnmatch(asset['name'], '$filename'):
    print(asset['browser_download_url'])
    sys.exit(0)
sys.stderr.write('ERROR: Cannot find a download matching \'$filename\'.\n'); sys.exit(1)
")
  echo -e "${COLOR_YELLOW}download_url = ${COLOR_NONE}$download_url"
  test -n "$download_url"
  sleep 0.5

  local tmpdir="$DOTFILES_TMPDIR/$name"
  local filename="$(basename $download_url)"
  test -n "$filename"
  mkdir -p $tmpdir
  curl -fSL --progress-bar "$download_url" -o "$tmpdir/$filename"

  cd "$tmpdir"
  if [[ "$filename" == *.tar.gz || "$filename" == *.tbz || "$filename" == *.tgz ]]; then
    echo -e "${COLOR_YELLOW}Extracting to: $tmpdir${COLOR_NONE}"
    tar -xvf "$filename" $TAR_OPTIONS
    local extracted_folder="${filename%.*}"
    if [[ "$extracted_folder" == *.tar ]]; then extracted_folder="${extracted_folder%.*}"; fi
    if [ -d "$extracted_folder" ]; then
      cd "$extracted_folder"
    fi
  fi
  echo -e "\n${COLOR_YELLOW}PWD = $(pwd)${COLOR_NONE}"

  # Copy the main binary to $PREFIX/bin by caller
  echo -e "${COLOR_YELLOW}Copying into $PREFIX ...${COLOR_NONE}"
}

_get_os_type() {
  OS_type="$(uname -m)"
  case "$OS_type" in
    x86_64|amd64)
      if [[ -z $1 ]]; then
        # default value
        OS_type='x86_64'
      else
        OS_type='amd64'
      fi
      ;;
    i?86|x86)
      OS_type='386'
      ;;
    aarch64|arm64)
      if [[ -z $1 ]]; then
        # default value
        OS_type='aarch64'
      else
        OS_type='arm64'
      fi
      ;;
    armv7*)
      OS_type='arm-v7'
      ;;
    armv6*)
      OS_type='arm-v6'
      ;;
    arm*)
      OS_type='arm'
      ;;
    *)
      echo 'OS type not supported'
      exit 2
      ;;
  esac

  echo "$OS_type"
}

#---------------------------------------------------------------------------------------------------

install_cmake() {
  local TMP_DIR="$DOTFILES_TMPDIR/cmake";
  mkdir -p "$TMP_DIR" && cd "$TMP_DIR"

  local CMAKE_VERSION="3.27.9"
  test -d "cmake-${CMAKE_VERSION}" && {\
    echo -e "${COLOR_RED}Error: $(pwd)/cmake-${CMAKE_VERSION} already exists.${COLOR_NONE}"; return 1; }

  wget -N  "https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}.tar.gz"
  tar -xvzf "cmake-${CMAKE_VERSION}.tar.gz"
  cd "cmake-${CMAKE_VERSION}"

  ./configure --prefix="$PREFIX" --parallel=16
  make -j16 && make install

  "$PREFIX/bin/cmake" --version
}

install_git() {
  # installs a modern version of git locally.

  local GIT_LATEST_VERSION=$(\
    curl -fL https://api.github.com/repos/git/git/tags 2>/dev/null | \
    python3 -c 'import json, sys; print(json.load(sys.stdin)[0]["name"])'\
  )  # e.g. "v2.38.1"
  test  -n "$GIT_LATEST_VERSION"

  local TMP_GIT_DIR="$DOTFILES_TMPDIR/git"; mkdir -p $TMP_GIT_DIR
  wget -N -O $TMP_GIT_DIR/git.tar.gz "https://github.com/git/git/archive/${GIT_LATEST_VERSION}.tar.gz"
  tar -xvzf $TMP_GIT_DIR/git.tar.gz -C $TMP_GIT_DIR --strip-components 1

  cd $TMP_GIT_DIR
  make configure
  ./configure --prefix="$PREFIX" --with-curl --with-expat

  # requires libcurl-dev (mandatory to make https:// work)
  if grep -q 'cannot find -lcurl' config.log; then
    echo -e "${COLOR_RED}Error: libcurl not found. Please install libcurl-dev and try again.${COLOR_NONE}"
    echo -e "${COLOR_YELLOW}e.g., sudo apt install libcurl4-openssl-dev${COLOR_NONE}"
    return 1;
  fi

  make clean
  make -j8 && make install
  ~/.local/bin/git --version

  if [[ ! -f "$(~/.local/bin/git --exec-path)/git-remote-https" ]]; then
    echo -e "${COLOR_YELLOW}Warning: $(~/.local/bin/git --exec-path)/git-remote-https not found. "
    echo -e "https:// git url will not work. Please install libcurl-dev and try again.${COLOR_NONE}"
    return 2;
  fi
}

install_git_cliff() {
  # https://github.com/orhun/git-cliff/releases
  TAR_OPTIONS="--strip-components 1"
  _template_github_latest "git-cliff" "orhun/git-cliff" "git-cliff-*-$(_get_os_type)-*-linux-gnu.tar.gz"
  cp -v git-cliff "$PREFIX/bin/"
  cp -v man/git-cliff.1 "$PREFIX/share/man/man1/"
}

install_gh() {
  # github CLI: https://github.com/cli/cli/releases
  _template_github_latest "gh" "cli/cli" "gh_*_linux_$(_get_os_type 1).tar.gz"

  cp -v ./bin/gh $HOME/.local/bin/gh
  _which gh
  $HOME/.local/bin/gh --version
}

install_ncurses() {
  # installs ncurses (shared libraries and headers) into local namespaces.

  local TMP_NCURSES_DIR="$DOTFILES_TMPDIR/ncurses/"; mkdir -p $TMP_NCURSES_DIR
  local NCURSES_DOWNLOAD_URL="https://invisible-mirror.net/archives/ncurses/ncurses-5.9.tar.gz";

  wget -nc -O $TMP_NCURSES_DIR/ncurses-5.9.tar.gz $NCURSES_DOWNLOAD_URL
  tar -xvzf $TMP_NCURSES_DIR/ncurses-5.9.tar.gz -C $TMP_NCURSES_DIR --strip-components 1
  cd $TMP_NCURSES_DIR

  # compile as shared library, at ~/.local/lib/libncurses.so (as well as static lib)
  export CPPFLAGS="-P"
  ./configure --prefix="$PREFIX" --with-shared

  make clean && make -j4 && make install
}

install_zsh() {
  local ZSH_VER="5.8"
  local TMP_ZSH_DIR="$DOTFILES_TMPDIR/zsh/"; mkdir -p "$TMP_ZSH_DIR"
  local ZSH_SRC_URL="https://sourceforge.net/projects/zsh/files/zsh/${ZSH_VER}/zsh-${ZSH_VER}.tar.xz/download"

  wget -nc -O $TMP_ZSH_DIR/zsh.tar.xz "$ZSH_SRC_URL"
  tar xvJf "$TMP_ZSH_DIR/zsh.tar.xz" -C "$TMP_ZSH_DIR" --strip-components 1
  cd $TMP_ZSH_DIR

  if [[ -d "$PREFIX/include/ncurses" ]]; then
    export CFLAGS="-I$PREFIX/include -I$PREFIX/include/ncurses"
    export LDFLAGS="-L$PREFIX/lib/"
  fi

  ./configure --prefix="$PREFIX"
  make clean && make -j8 && make install

  ~/.local/bin/zsh --version
}

install_node() {
  # Install node.js LTS at ~/.local

  local NODE_VERSION
  if [ -z "$NODE_VERSION" ]; then
    if _version_check $(_glibc_version) 2.28; then
      # Use LTS version if GLIBC >= 2.28 (Ubuntu 20.04+)
      NODE_VERSION="lts"
    else
      # Older distro (Ubuntu 18.04) have GLIBC < 2.28
      NODE_VERSION="v16"
    fi
  fi

  set -x
  curl -L "https://install-node.vercel.app/$NODE_VERSION" \
    | bash -s -- --prefix=$HOME/.local --verbose --yes
  set +x

  _which node
  node --version

  # install some useful nodejs based utility (~/.local/lib/node_modules)
  $HOME/.local/bin/npm install -g yarn
  _which yarn && yarn --version
  $HOME/.local/bin/npm install -g http-server diff-so-fancy || true;
}

install_tmux() {
  # tmux: use tmux-appimage to avoid all the libevents/ncurses hassles
  # see https://github.com/nelsonenzo/tmux-appimage
  _template_github_latest "tmux" "nelsonenzo/tmux-appimage" "tmux.appimage"

  cp -v "./tmux.appimage" "$HOME/.local/bin/tmux"
  chmod +x $HOME/.local/bin/tmux

  ~/.local/bin/tmux -V
}

install_bazel() {

  # install the 'latest' stable release (no pre-releases.)
  local BAZEL_LATEST_VERSION=$(\
    curl -fL https://api.github.com/repos/bazelbuild/bazel/releases/latest 2>/dev/null | \
    python3 -c 'import json, sys; print(json.load(sys.stdin)["name"])'\
  )
  test -n $BAZEL_LATEST_VERSION
  local BAZEL_VER="${BAZEL_LATEST_VERSION}"
  echo -e "${COLOR_YELLOW}Installing Bazel ${BAZEL_VER} ...${COLOR_NONE}"

  local BAZEL_URL="https://github.com/bazelbuild/bazel/releases/download/${BAZEL_VER}/bazel-${BAZEL_VER}-installer-linux-$(_get_os_type).sh"

  local TMP_BAZEL_DIR="$DOTFILES_TMPDIR/bazel/"
  mkdir -p $TMP_BAZEL_DIR
  wget -O $TMP_BAZEL_DIR/bazel-installer.sh $BAZEL_URL

  # zsh completion
  wget -O $PREFIX/share/zsh/site-functions/_bazel https://raw.githubusercontent.com/bazelbuild/bazel/master/scripts/zsh_completion/_bazel

  # install bazel
  bash $TMP_BAZEL_DIR/bazel-installer.sh \
      --bin=$PREFIX/bin \
      --base=$HOME/.bazel

  # print bazel version
  _which bazel
  bazel 2>/dev/null | grep release | xargs
  echo ""
}

install_mambaforge() {
  # Mambaforge.
  # https://conda-forge.org/miniforge/
  _template_github_latest "mambaforge" "conda-forge/miniforge" "Mambaforge-Linux-$(_get_os_type).sh"

  local MAMBAFORGE_PREFIX="$HOME/.mambaforge"
  bash "Mambaforge-Linux-$(_get_os_type).sh" -b -p "${MAMBAFORGE_PREFIX}"
  _which $MAMBAFORGE_PREFIX/bin/python3
  $MAMBAFORGE_PREFIX/bin/python3 --version
}

install_miniforge() {
  # Miniforge3.
  # https://github.com/conda-forge/miniforge
  _template_github_latest "mambaforge" "conda-forge/miniforge" "Miniforge3-Linux-$(_get_os_type).sh"

  local MINIFORGE_PREFIX="$HOME/.miniforge3"
  bash "Miniforge3-Linux-$(_get_os_type).sh" -b -p ${MINIFORGE_PREFIX}
  _which $MINIFORGE_PREFIX/bin/python3
  $MINIFORGE_PREFIX/bin/python3 --version
}

install_miniconda() {
  # installs Miniconda3. (Deprecated: Use miniforge3)
  # https://conda.io/miniconda.html
  local MINICONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-$(_get_os_type).sh"

  local TMP_DIR="$DOTFILES_TMPDIR/miniconda/"; mkdir -p $TMP_DIR && cd ${TMP_DIR}
  wget -nc $MINICONDA_URL

  local MINICONDA_PREFIX="$HOME/.miniconda3/"
  bash "Miniconda3-latest-Linux-$(_get_os_type).sh" -b -p ${MINICONDA_PREFIX}

  # 3.9.5 as of Nov 2021
  $MINICONDA_PREFIX/bin/python3 --version

  echo -e "${COLOR_YELLOW}Warning: miniconda is deprecated, consider using miniforge3.${COLOR_NONE}"
}

install_vim() {
  # install latest vim

  # check python3-config
  local PYTHON3_CONFIGDIR=$(python3-config --configdir)
  echo -e "${COLOR_YELLOW} python3-config --configdir =${COLOR_NONE} $PYTHON3_CONFIGDIR"
  if [[ "$PYTHON3_CONFIGDIR" =~ (conda|virtualenv|venv) ]]; then
    echo -e "${COLOR_RED}Error: python3-config reports a conda/virtual environment. Deactivate and try again."
    return 1;
  fi

  # grab the lastest vim tarball and build it
  local TMP_VIM_DIR="$DOTFILES_TMPDIR/vim/"; mkdir -p $TMP_VIM_DIR
  local VIM_LATEST_VERSION=$(\
    curl -fL https://api.github.com/repos/vim/vim/tags 2>/dev/null | \
    python3 -c 'import json, sys; print(json.load(sys.stdin)[0]["name"])'\
  )
  test -n $VIM_LATEST_VERSION
  local VIM_LATEST_VERSION=${VIM_LATEST_VERSION/v/}    # (e.g) 8.0.1234
  echo -e "${COLOR_GREEN}Installing vim $VIM_LATEST_VERSION ...${COLOR_NONE}"
  sleep 1

  local VIM_DOWNLOAD_URL="https://github.com/vim/vim/archive/v${VIM_LATEST_VERSION}.tar.gz"

  wget -nc ${VIM_DOWNLOAD_URL} -P ${TMP_VIM_DIR} || true;
  cd ${TMP_VIM_DIR} && tar -xvzf v${VIM_LATEST_VERSION}.tar.gz
  cd "vim-${VIM_LATEST_VERSION}/src"

  ./configure --prefix="$PREFIX" \
    --with-features=huge \
    --enable-python3interp \
    --with-python3-config-dir="$PYTHON3_CONFIGDIR"

  make clean && make -j8 && make install
  ~/.local/bin/vim --version | head -n2

  # make sure that all necessary features are shipped
  if ! (vim --version | grep -q '+python3'); then
    echo "vim: python is not enabled"
    exit 1;
  fi
}

install_neovim() {
  # install neovim stable or nightly
  # [NEOVIM_VERSION=...] dotfiles install neovim

  # Otherwise, use the latest stable version.
  local NEOVIM_LATEST_VERSION=$(\
    curl -fL https://api.github.com/repos/neovim/neovim/releases/latest 2>/dev/null | \
    python3 -c 'import json, sys; print(json.load(sys.stdin)["tag_name"])'\
  )   # usually "stable"
  : "${NEOVIM_VERSION:=$NEOVIM_LATEST_VERSION}"

  if [[ $NEOVIM_VERSION != "stable" ]] && [[ $NEOVIM_VERSION != v* ]]; then
    NEOVIM_VERSION="v$NEOVIM_VERSION"  # e.g. "0.7.0" -> "v0.7.0"
  fi
  test -n "$NEOVIM_VERSION"

  local VERBOSE=""
  for arg in "$@"; do
    if [ "$arg" == "--nightly" ]; then
      NEOVIM_VERSION="nightly";
    elif [ "$arg" == "-v" ] || [ "$arg" == "--verbose" ]; then
      VERBOSE="--verbose"
    fi
  done

  if [ "${NEOVIM_VERSION}" == "nightly" ]; then
    echo -e "${COLOR_YELLOW}Installing neovim nightly. ${COLOR_NONE}"
  else
    echo -e "${COLOR_YELLOW}Installing neovim stable ${NEOVIM_VERSION}. ${COLOR_NONE}"
    echo -e "${COLOR_YELLOW}To install a nightly version, add flag: --nightly ${COLOR_NONE}"
  fi
  sleep 1;  # allow users to read above comments

  local TMP_NVIM_DIR="$DOTFILES_TMPDIR/neovim"; mkdir -p $TMP_NVIM_DIR
  if _version_check "$NEOVIM_VERSION" "v0.10.4"; then
    NVIM_APPIMAGE="nvim-linux-x86_64.appimage"
    if [[ "$(_get_os_type)" == "aarch64" ]]; then
      NVIM_APPIMAGE="nvim-linux-arm64.appimage"
    fi
  else
    NVIM_APPIMAGE="nvim.appimage"
  fi
  local NVIM_DOWNLOAD_URL="https://github.com/neovim/neovim/releases/download/${NEOVIM_VERSION}/$NVIM_APPIMAGE"

  set -x
  cd $TMP_NVIM_DIR
  wget --backups=1 $NVIM_DOWNLOAD_URL      # always overwrite, having only one backup

  chmod +x "$NVIM_APPIMAGE"
  rm -rf "$TMP_NVIM_DIR/squashfs-root"
  "./$NVIM_APPIMAGE" --appimage-extract >/dev/null   # into ./squashfs-root

  # Install into ~/.local/neovim/ and put a symlink into ~/.local/bin
  local NEOVIM_DEST="$HOME/.local/neovim"
  echo -e "${COLOR_GREEN}[*] Copying neovim files to $NEOVIM_DEST ... ${COLOR_NONE}"
  mkdir -p $NEOVIM_DEST/bin/
  cp -f squashfs-root/usr/bin/nvim "$NEOVIM_DEST/bin/nvim" \
    || (echo -e "${COLOR_RED}Copy failed, please kill all nvim instances. (killall nvim)${COLOR_NONE}"; exit 1)
  rm -rf "$NEOVIM_DEST"
  cp -r squashfs-root/usr "$NEOVIM_DEST"
  rm -f "$PREFIX/bin/nvim"
  ln -sf "$NEOVIM_DEST/bin/nvim" "$PREFIX/bin/nvim"

  $PREFIX/bin/nvim --version | head -n3
}

install_just() {
  # https://github.com/casey/just/releases
  _template_github_latest "just" "casey/just" "just-*-$(_get_os_type)-*-linux-musl.tar.gz"

  cp -v just "$PREFIX/bin/just"
  cp -v just.1 "$PREFIX/share/man/man1/"
  _which just
  just --version
}

install_delta() {
  # https://github.com/dandavison/delta/releases
  _template_github_latest "delta" "dandavison/delta" "delta-*-$(_get_os_type)-*-linux-musl.tar.gz"

  cp -v "./delta" "$PREFIX/bin/delta"
  chmod +x "$PREFIX/bin/delta"
  _which delta
  delta --version
}

install_eza() {
  # https://github.com/eza-community/eza/releases
  _template_github_latest "eza" "eza-community/eza" "eza_$(_get_os_type)-*linux-gnu*"

  cp -v "./eza" "$PREFIX/bin/eza"
  curl -fL "https://raw.githubusercontent.com/eza-community/eza/main/completions/zsh/_eza" > \
    "$PREFIX/share/zsh/site-functions/_eza"
  _which eza
  eza --version
}

install_fd() {
  # https://github.com/sharkdp/fd/releases
  _template_github_latest "fd" "sharkdp/fd" "fd-*-$(_get_os_type)-unknown-linux-musl.tar.gz"
  cp -v "./fd" $PREFIX/bin
  cp -v "./autocomplete/_fd" $PREFIX/share/zsh/site-functions

  _which fd
  $PREFIX/bin/fd --version
}

install_ripgrep() {
  # https://github.com/BurntSushi/ripgrep/releases
  _template_github_latest "ripgrep" "BurntSushi/ripgrep" "ripgrep-*-$(_get_os_type)-unknown-linux-musl.tar.gz"
  cp -v "./rg" $PREFIX/bin/
  cp -v "./complete/_rg" $PREFIX/share/zsh/site-functions

  _which rg
  $PREFIX/bin/rg --version
}

install_xsv() {
  # https://github.com/BurntSushi/xsv/releases
  _template_github_latest "xsv" "BurntSushi/xsv" "xsv-*-$(_get_os_type)-unknown-linux-musl.tar.gz"
  cp -v "./xsv" $PREFIX/bin/

  _which xsv
  $PREFIX/bin/xsv --version
}

install_bat() {
  # https://github.com/sharkdp/bat/releases
  _template_github_latest "bat" "sharkdp/bat" "bat-*-$(_get_os_type)-unknown-linux-musl.tar.gz"
  cp -v "./bat" $PREFIX/bin/
  cp -v "./autocomplete/bat.zsh" $PREFIX/share/zsh/site-functions/_bat

  _which bat
  $PREFIX/bin/bat --version
}

install_go() {
  # install go lang into ~/.go
  # https://golang.org/dl/
  set -x
  if [ -d "$HOME/.go" ]; then
    echo -e "${COLOR_RED}Error: $HOME/.go already exists.${COLOR_NONE}"
    exit 1;
  fi
  mkdir -p "$HOME/.go"

  local GO_VERSION="1.21.4"
  local GO_DOWNLOAD_URL="https://dl.google.com/go/go${GO_VERSION}.linux-$(_get_os_type 1).tar.gz"
  TMP_GO_DIR="$DOTFILES_TMPDIR/go/"

  wget -nc ${GO_DOWNLOAD_URL} -P ${TMP_GO_DIR} || exit 1;
  cd ${TMP_GO_DIR} && tar -xvzf "go${GO_VERSION}.linux-$(_get_os_type 1).tar.gz" || exit 1;
  mv go/* "$HOME/.go/"

  echo ""
  echo -e "${COLOR_GREEN}Installed at $HOME/.go${COLOR_NONE}"
  "$HOME/.go/bin/go" version
}

install_jq() {
  # https://github.com/jqlang/jq/releases
  _template_github_latest "jq" "jqlang/jq" "jq-linux-$(_get_os_type 1)"

  cp -v "./jq-linux-$(_get_os_type 1)" "$PREFIX/bin/jq"
  chmod +x "$PREFIX/bin/jq"
  _which jq
  $PREFIX/bin/jq --version
}

install_duf() {
  # https://github.com/muesli/duf/releases
  _template_github_latest "duf" "muesli/duf" "duf_*_linux_$(_get_os_type).tar.gz"
  cp -v "./duf" $PREFIX/bin

  _which duf
  $PREFIX/bin/duf --version
}

install_lazydocker() {
  _template_github_latest "lazydocker" "jesseduffield/lazydocker" "lazydocker_*_Linux_$(_get_os_type).tar.gz"
  cp -v "./lazydocker" $PREFIX/bin

  _which lazydocker
  $PREFIX/bin/lazydocker --version
}

install_lazygit() {
  _template_github_latest "lazygit" "jesseduffield/lazygit" "lazygit_*_Linux_$(_get_os_type).tar.gz"
  cp -v "./lazygit" $PREFIX/bin

  _which lazygit
  $PREFIX/bin/lazygit --version
}

install_rsync() {
  local URL="https://www.samba.org/ftp/rsync/src/rsync-3.2.4.tar.gz"
  local TMP_DIR="$DOTFILES_TMPDIR/rsync"; mkdir -p $TMP_DIR

  wget -N -O $TMP_DIR/rsync.tar.gz "$URL"
  tar -xvzf $TMP_DIR/rsync.tar.gz -C $TMP_DIR --strip-components 1
  cd $TMP_DIR

  ./configure --prefix="$PREFIX"
  make install
  $PREFIX/bin/rsync --version
}

install_mosh() {
  set -x
  rm -rf mosh || true

  local URL="https://github.com/mobile-shell/mosh/archive/refs/tags/mosh-1.4.0.zip"
  local TMP_DIR="$DOTFILES_TMPDIR/mosh"; mkdir -p $TMP_DIR
  rm -rf mosh || true
  cd "$TMP_DIR"

  wget -N -O "mosh.tar.gz" "$URL"
  unzip -o "mosh.tar.gz"   # It's actually a zip file, not a tar.gz ....
  cd "mosh-mosh-1.4.0/"

  ./autogen.sh
  ./configure --prefix="$PREFIX"
  make -j4
  make install
  $PREFIX/bin/mosh-server --version
}

install_mujoco() {
  # https://github.com/deepmind/mujoco/
  # Note: If pre-built wheel is available, just do `pip install mujoco` and it's done
  set -x
  local mujoco_version="2.3.0"

  local MUJOCO_ROOT=$HOME/.mujoco/mujoco-$mujoco_version
  if [[ -d "$MUJOCO_ROOT" ]]; then
    echo -e "${COLOR_YELLOW}Error: $MUJOCO_ROOT already exists.${COLOR_NONE}"
    return 1;
  fi

  local tmpdir="$DOTFILES_TMPDIR/mujoco"
  mkdir -p $tmpdir && cd $tmpdir
  mkdir -p $HOME/.mujoco

  local download_url="https://github.com/deepmind/mujoco/releases/download/${mujoco_version}/mujoco-${mujoco_version}-linux-$(_get_os_type).tar.gz"
  local filename="$(basename $download_url)"
  wget -N -O $tmpdir/$filename "$download_url"
  tar -xvzf "$filename" -C $tmpdir

  mv $tmpdir/mujoco-$mujoco_version $HOME/.mujoco/
  test -d $MUJOCO_ROOT

  $MUJOCO_ROOT/bin/testspeed $MUJOCO_ROOT/model/scene.xml 1000
  set +x

  echo -e "${COLOR_GREEN}MUJOCO_ROOT = $MUJOCO_ROOT${COLOR_NONE}"
  echo -e "${COLOR_WHITE}Done. Please don't forget to set LD_LIBRARY_PATH \
    (should include $MUJOCO_ROOT/bin).${COLOR_NONE}\n"
}

install_pyenv() {
  git clone https://github.com/pyenv/pyenv.git ~/.pyenv
  git clone https://github.com/pyenv/pyenv-virtualenv.git ~/.pyenv/plugins/pyenv-virtualenv
  git clone https://github.com/pyenv/pyenv-update.git ~/.pyenv/plugins/pyenv-update
}

install_fzf() {
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
  ~/.fzf/install
}

install_cargo() {
  curl https://sh.rustup.rs -sSf | sh
}

install_asdf() {
  git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.10.2
}

install_poetry() {
  curl -sSL https://install.python3-poetry.org | python3 -
}

install_btop() {
  _template_github_latest "btop" "aristocratos/btop" "btop-$(_get_os_type)-linux-*.tbz"
  cd btop
  make install PREFIX="$HOME/.local"
}

install_rbenv() {
  set -e
  git clone https://github.com/rbenv/rbenv.git ~/.rbenv
  git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
}

install_rclone() {
  # Origin from https://rclone.org/install.sh

  # error codes
  # 0 - exited without problems
  # 1 - parameters not supported were used or some unexpected error occurred
  # 2 - OS not supported by this script
  # 3 - installed version of rclone is up to date
  # 4 - supported unzip tools are not available


  #when adding a tool to the list make sure to also add its corresponding command further in the script
  unzip_tools_list=('unzip' '7z' 'busybox')

  usage() { echo "Usage: sudo -v ; curl https://rclone.org/install.sh | sudo bash [-s beta]" 1>&2; exit 1; }

  #check for beta flag
  if [ -n "$1" ] && [ "$1" != "beta" ]; then
    usage
  fi

  if [ -n "$1" ]; then
    install_beta="beta "
  fi


  #create tmp directory and move to it with macOS compatibility fallback
  tmp_dir=$(mktemp -d 2>/dev/null || mktemp -d -t 'rclone-install.XXXXXXXXXX')
  cd "$tmp_dir"


  #make sure unzip tool is available and choose one to work with
  set +e
  for tool in ${unzip_tools_list[*]}; do
    trash=$(hash "$tool" 2>>errors)
    if [ "$?" -eq 0 ]; then
      unzip_tool="$tool"
      break
    fi
  done
  set -e

  # exit if no unzip tools available
  if [ -z "$unzip_tool" ]; then
    printf "\nNone of the supported tools for extracting zip archives (${unzip_tools_list[*]}) were found. "
    printf "Please install one of them and try again.\n\n"
    exit 4
  fi

  # Make sure we don't create a root owned .config/rclone directory #2127
  export XDG_CONFIG_HOME=config

  #check installed version of rclone to determine if update is necessary
  version=$(rclone --version 2>>errors | head -n 1)
  if [ -z "$install_beta" ]; then
    current_version=$(curl -fsS https://downloads.rclone.org/version.txt)
  else
    current_version=$(curl -fsS https://beta.rclone.org/version.txt)
  fi

  if [ "$version" = "$current_version" ]; then
    printf "\nThe latest ${install_beta}version of rclone ${version} is already installed.\n\n"
    exit 3
  fi


  #detect the platform
  OS="$(uname)"
  case $OS in
    Linux)
      OS='linux'
      ;;
    *)
      echo 'OS not supported'
      exit 2
      ;;
  esac

  OS_type="$(_get_os_type)"

  #download and unzip
  if [ -z "$install_beta" ]; then
    download_link="https://downloads.rclone.org/rclone-current-${OS}-${OS_type}.zip"
    rclone_zip="rclone-current-${OS}-${OS_type}.zip"
  else
    download_link="https://beta.rclone.org/rclone-beta-latest-${OS}-${OS_type}.zip"
    rclone_zip="rclone-beta-latest-${OS}-${OS_type}.zip"
  fi

  curl -OfsS "$download_link"
  unzip_dir="tmp_unzip_dir_for_rclone"
  # there should be an entry in this switch for each element of unzip_tools_list
  case "$unzip_tool" in
    'unzip')
      unzip -a "$rclone_zip" -d "$unzip_dir"
      ;;
    '7z')
      7z x "$rclone_zip" "-o$unzip_dir"
      ;;
    'busybox')
      mkdir -p "$unzip_dir"
      busybox unzip "$rclone_zip" -d "$unzip_dir"
      ;;
  esac

  cd $unzip_dir/*

  #mounting rclone to environment

  case "$OS" in
    'linux')
      #binary
      cp rclone ~/.local/bin/rclone.new
      chmod 755 ~/.local/bin/rclone.new
      mv ~/.local/bin/rclone.new ~/.local/bin/rclone
      #manual
      if ! [ -x "$(command -v mandb)" ]; then
        echo 'mandb not found. The rclone man docs will not be installed.'
      else
        mkdir -p ~/.local/share/man/man1
        cp rclone.1 ~/.local/share/man/man1/
        mandb
      fi
      ;;
    *)
      echo 'OS not supported'
      exit 2
  esac


  #update version variable post install
  version=$(rclone --version 2>>errors | head -n 1)

  printf "\n${version} has successfully installed."
  printf '\nNow run "rclone config" for setup. Check https://rclone.org/docs/ for more details.\n\n'
}

install_glow () {
  _template_github_latest "glow" "charmbracelet/glow" "glow_Linux_$(_get_os_type).tar.gz"

  cp -v ./glow $PREFIX/bin/
}

install_brew() {
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

install_nix-portable() {
  # ref: https://github.com/DavHau/nix-portable/issues/66#issuecomment-2067802826

  set -ex

  cd $PREFIX/bin

  # Download nix-portable
  curl -L "https://github.com/DavHau/nix-portable/releases/latest/download/nix-portable-$(uname -m)" > ./nix-portable

  # Generate symlinks for seamless integration
  chmod +x nix-portable
  ln -s nix-portable nix
  ln -s nix-portable nix-channel
  ln -s nix-portable nix-copy-closure
  ln -s nix-portable nix-env
  ln -s nix-portable nix-instantiate
  ln -s nix-portable nix-prefetch-url
  ln -s nix-portable nix-store
  ln -s nix-portable nix-build
  ln -s nix-portable nix-collect-garbage
  ln -s nix-portable nix-daemon
  ln -s nix-portable nix-hash
  ln -s nix-portable nix-shell

  cd ~

  # Init home-manager
  NP_RUNTIME=bwrap nix-portable nix shell nixpkgs#{bashInteractive,nix} <<EOF
nix run github:nix-community/home-manager -- init
EOF

  # Add home-manager to its own path
  echo 'Add the following in your home.nix file: `home.sessionVariables.PATH = "$HOME/.nix-profile/bin:$PATH";`'
  sed -i '/home.sessionVariables = {/a\    PATH = "$HOME/.nix-profile/bin:$PATH";' ~/.config/home-manager/home.nix

  # home manager switch
  NP_RUNTIME=bwrap nix-portable nix shell nixpkgs#{bashInteractive,nix} <<EOF
nix run github:nix-community/home-manager -- switch
EOF

  # Make new sessions use the shell automatically
  mv ~/.bashrc ~/.bashrc.old
  cat >~/.bashrc <<EOF
export PATH=\$PATH:\$HOME/.local/bin

if [ -z "\$__NIX_PORTABLE_ACTIVATED" ]; then
        export __NIX_PORTABLE_ACTIVATED=1
        NP_RUNTIME=bwrap nix-portable nix run nixpkgs#bashInteractive --offline
        exit
else
        . \$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh
fi

# If not running interactively, don't do anything
[[ \$- != *i* ]] && return

# Set something for the cmd line
PS1='[\u@\h \W]\\\$ '
EOF

  echo 'Please remember to relogin so that the environment gets activated'
}

install_uv() {
  curl -LsSf https://astral.sh/uv/install.sh | sh
}

install_rye() {
  curl -sSf https://rye.astral.sh/get | bash
}

install_ollama() {
  curl -fsSL https://ollama.com/install.sh | sh
}

install_codex() {
  _template_github_latest "codex" "openai/codex" "codex-$(_get_os_type)-unknown-linux-musl.tar.gz"

  cp -v "./codex-$(_get_os_type)-unknown-linux-musl" $PREFIX/bin/codex
}

install_opencode() {
  curl -fsSL https://opencode.ai/install | bash
}

install_mise() {
  curl https://mise.run | sh
  mise use -g usage
}

# entrypoint script
if [[ -n "$1" && "$1" != "--help" ]] && declare -f "$1"; then
  echo -e "\nProceed?"
  TMOUT=10 # timeout second
  select yn in "Yes" "No"; do
      case $yn in
          Yes ) $@; break;;
          No ) exit;;
      esac
  done
else
  echo "Usage: $0 [command], where command is one of the following:"
  declare -F | cut -d" " -f3 | grep -v '^_'
  exit 1;
fi
