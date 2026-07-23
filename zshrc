# ~/.zshrc — zsh trial config. Mirrors ~/.git_prompt_and_bashrc/bashrc.
# Try it: type `zsh` in a tab. Leave with `exit`. Nothing else changes,
# your login shell stays bash until you decide to `chsh`.

case "$(uname)" in
    Linux) PLATFORM='linux';;
    Darwin) PLATFORM='osx';;
    *) PLATFORM='unknown';;
esac

export PATH=~/bin:$PATH
[[ -d ${HOME}/Library/Developer/Xcode/usr/bin ]] && PATH="${HOME}/Library/Developer/Xcode/usr/bin:${PATH}"

# History
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt APPEND_HISTORY INC_APPEND_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_SPACE

# less for non-text input
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# FUNCTIONS
mkcd() { mkdir "$1" && cd "$1"; }

if command -v kinit >/dev/null 2>&1; then
    sshk() {
        klist -s || { echo "TGT expired! Creating new one."; kinit -r 7d pavel.cvetler; }
        ssh pavel.cvetler@$1.ls.intra "$2"
    }
    scpk() {
        klist -s || { echo "TGT expired! Creating new one."; kinit -r 7d pavel.cvetler; }
        scp $1 pavel.cvetler@$(echo $2 | sed -e "s/://g").ls.intra:
    }
fi

php-cli-debug-start() { export XDEBUG_CONFIG="remote_enable=1 remote_mode=req remote_port=9000 remote_host=127.0.0.1 remote_connect_back=0"; }
php-cli-debug-stop()  { export XDEBUG_CONFIG=""; }

# ALIASES (GNU coloring when GNU coreutils/dircolors is present)
if command -v dircolors >/dev/null 2>&1; then
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi
alias l='ls -lah'

if [[ "$PLATFORM" == 'osx' ]]; then
    MAIN_HOME="$HOME"
    export GEM_HOME=$MAIN_HOME/.gem
    BREW_PREFIX=/opt/homebrew

    alias j2objc=/Users/celly/j2objc/j2objc
    alias j2objcc=/Users/celly/j2objc/j2objcc

    PATH="/Users/celly/.git_prompt_and_bashrc/links_and_tools:$PATH"

    PATH="$BREW_PREFIX/opt/coreutils/libexec/gnubin:$PATH"
    MANPATH="$BREW_PREFIX/opt/coreutils/libexec/gnuman:$MANPATH"

    export DEVELOPER_DIR="$(xcode-select -print-path)"

    export PATH="$GEM_HOME/bin:$GEM_HOME/ruby/2.6.0/bin:$PATH"
    export PATH="/usr/pkg/bin:/usr/pkg/sbin:$BREW_PREFIX/bin:$BREW_PREFIX/sbin:$PATH"
    export PATH="$BREW_PREFIX/opt/python@3.14/libexec/bin:$PATH"
    export MANPATH="/usr/pkg/man:$BREW_PREFIX/share/man:$MANPATH"
    export LIBPATH=$BREW_PREFIX/

    export CLICOLOR=1; export LSCOLORS=ExGxFxDxCxegedabagfcec

    alias sublime='open -a Sublime\ Text'

    # NVM (lazy-loaded: real nvm loads on first nvm/node/npm/npx use)
    export NVM_DIR=${MAIN_HOME}/.nvm
    _load_nvm() {
        unset -f nvm node npm npx 2>/dev/null
        [ -s "$BREW_PREFIX/opt/nvm/nvm.sh" ] && . "$BREW_PREFIX/opt/nvm/nvm.sh"
        nvm use node >/dev/null 2>&1
    }
    nvm()  { _load_nvm; nvm "$@"; }
    node() { _load_nvm; node "$@"; }
    npm()  { _load_nvm; npm "$@"; }
    npx()  { _load_nvm; npx "$@"; }

    # JAVA_HOME
    export JAVA_8_HOME=$(/usr/libexec/java_home -v1.8 2>/dev/null)
    export JAVA_11_HOME=$(/usr/libexec/java_home -v11 2>/dev/null)
    alias java8='export JAVA_HOME=$JAVA_8_HOME'
    alias java11='export JAVA_HOME=$JAVA_11_HOME'
    export JAVA_HOME=$JAVA_11_HOME

    export ANDROID_HOME=$HOME/Library/Android/sdk
    export PATH=$PATH:$ANDROID_HOME/emulator
    export PATH=$PATH:$ANDROID_HOME/platform-tools

    APPENGINE_SDK_VERSION=1.9.31
    export PATH=/Users/celly/.m2/repository/com/google/appengine/appengine-java-sdk/$APPENGINE_SDK_VERSION/appengine-java-sdk/appengine-java-sdk-$APPENGINE_SDK_VERSION/bin:$PATH

    export GOPATH=${MAIN_HOME}/go

    # JetBrains Toolbox (normally from ~/.zprofile; added so the `zsh` trial has it too)
    export PATH="$PATH:/Users/celly/Library/Application Support/JetBrains/Toolbox/scripts"
fi

unset PLATFORM

# Completion (zsh native)
if [[ -d "$BREW_PREFIX/share/zsh/site-functions" ]]; then
    FPATH="$BREW_PREFIX/share/zsh/site-functions:$FPATH"
fi
autoload -Uz compinit && compinit -u

# pyenv
if command -v pyenv >/dev/null 2>&1; then
    eval "$(pyenv init - zsh)"
fi

# GIT prompt (faithful zsh port of the bash git_prompt)
[ -f ~/.git_prompt_and_bashrc/git_prompt.zsh ] && . ~/.git_prompt_and_bashrc/git_prompt.zsh

# Terminal title = current dir
autoload -Uz add-zsh-hook
_set_title() { print -Pn "\e]0;%1~\a"; }
add-zsh-hook precmd _set_title

# cmux / Ghostty shell integration (zsh variants) for new-tab cwd inheritance
if [[ -n "$CMUX_SHELL_INTEGRATION_DIR" && -z "$_CMUX_ZSH_INTEGRATION_LOADED" ]]; then
    [[ -r "$CMUX_SHELL_INTEGRATION_DIR/ghostty-integration.zsh" ]] && source "$CMUX_SHELL_INTEGRATION_DIR/ghostty-integration.zsh"
    [[ -r "$CMUX_SHELL_INTEGRATION_DIR/cmux-zsh-integration.zsh" ]] && source "$CMUX_SHELL_INTEGRATION_DIR/cmux-zsh-integration.zsh"
    export _CMUX_ZSH_INTEGRATION_LOADED=1
fi
