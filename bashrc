case "$(uname)" in
	Linux) PLATFORM='linux';;
	Darwin) PLATFORM='osx';;
	*) PLATFORM='unknown';;
esac

export PATH=~/bin:$PATH
if [[ -d ${HOME}/Library/Developer/Xcode/usr/bin ]]; then
        PATH="${HOME}/Library/Developer/Xcode/usr/bin:${PATH}"
fi

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=100000
HISTFILESIZE=100000
shopt -s histappend # append to the history file, don't overwrite it
HISTCONTROL=ignoredups:ignorespace # append to history, don't overwrite it

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# FUNCTIONS
function mkcd
{
	mkdir "$1" && cd "$1"
}

if [ "$(which kinit)" != "" ]; then
function sshk
{
	klist -s
	if [ "$?" != "0" ]; then
		echo TGT expired! Creating new one.
		kinit -r 7d pavel.cvetler
#$(whoami)
	fi
	ssh pavel.cvetler@$1.ls.intra "$2"
	#"cat /etc/motd ; sudo -i"
}
function scpk
{
	klist -s
	if [ "$?" != "0" ]; then
		echo TGT expired! Creating new one.
		kinit -r 7d pavel.cvetler
#$(whoami)
	fi
	scp $1 pavel.cvetler@$(echo $2 | sed -e "s/://g").ls.intra:
}
fi

function php-cli-debug-start
{
	export XDEBUG_CONFIG="remote_enable=1 remote_mode=req remote_port=9000 remote_host=127.0.0.1 remote_connect_back=0"
#	php -dxdebug.remote_enable=1 -dxdebug.remote_mode=req -dxdebug.remote_port=9000 -dxdebug.remote_host=127.0.0.1 -dxdebug.remote_connect_back=0 $1
}

function php-cli-debug-stop
{
	export XDEBUG_CONFIG=""
}

# ALIASES
if [ -x /usr/bin/dircolors ]; then
	alias ls='ls --color=auto'
	alias grep='grep --color=auto'
	alias fgrep='fgrep --color=auto'
	alias egrep='egrep --color=auto'
fi
alias l='ls -lah'

if [[ "$PLATFORM" == 'osx' ]]; then
#	export LDFLAGS="-L/opt/brew/opt/zlib/lib"
#	export CPPFLAGS="-I/opt/brew/opt/zlib/include"
#	export PKG_CONFIG_PATH="/opt/brew/opt/zlib/lib/pkgconfig"

	MAIN_HOME=$(dirname $(dirname $BASH_SOURCE))
	export GEM_HOME=$MAIN_HOME/.gem

	BREW_PREFIX=/opt/homebrew
	# alias git=$BREW_PREFIX/bin/git

	alias j2objc=/Users/celly/j2objc/j2objc
	alias j2objcc=/Users/celly/j2objc/j2objcc

	PATH="/Users/celly/.git_prompt_and_bashrc/links_and_tools:$PATH"

	SHELL="$BREW_PREFIX/bin/bash"
	PATH="$BREW_PREFIX/opt/coreutils/libexec/gnubin:$PATH"
	MANPATH="$BREW_PREFIX/opt/coreutils/libexec/gnuman:$MANPATH"

	export DEVELOPER_DIR="$(xcode-select -print-path)"
	#export PATH="$DEVELOPER_DIR/usr/bin:$PATH"

	export PATH="$GEM_HOME/bin:$GEM_HOME/ruby/2.6.0/bin:$PATH"
	export PATH="/usr/pkg/bin:/usr/pkg/sbin:$BREW_PREFIX/bin:$BREW_PREFIX/sbin:$PATH"
	# unversioned `python`/`pip` from Homebrew python (it only ships python3 in bin)
	export PATH="$BREW_PREFIX/opt/python@3.14/libexec/bin:$PATH"
	export MANPATH="/usr/pkg/man:$BREW_PREFIX/share/man:$MANPATH"
	#export C_INCLUDE_PATH=$BREW_PREFIX/include:$C_INCLUDE_PATH
	export LIBPATH=$BREW_PREFIX/

	#export PATH="$BREW_PREFIX/opt/php55/bin:$PATH" #PATH="$(brew --prefix homebrew/php/php54)/bin:$PATH"

	# Colors for folders etc.
	export CLICOLOR=1; export LSCOLORS=ExGxFxDxCxegedabagfcec;

	# ALIASES
	alias sublime='open -a Sublime\ Text'

	# Bash completion
#	. /etc/bash_completion
	if [ -f $BREW_PREFIX/etc/bash_completion ]; then
		. $BREW_PREFIX/etc/bash_completion
	fi

	# NVM
	export NVM_DIR=${MAIN_HOME}/.nvm
	[ -s "$BREW_PREFIX/opt/nvm/nvm.sh" ] && . "$BREW_PREFIX/opt/nvm/nvm.sh"  # This loads nvm
	[ -s "$BREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm" ] && . "$BREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion
	nvm use node

	# JAVA_HOME
	export JAVA_8_HOME=$(/usr/libexec/java_home -v1.8)
	export JAVA_11_HOME=$(/usr/libexec/java_home -v11)

	alias java8='export JAVA_HOME=$JAVA_8_HOME'
	alias java11='export JAVA_HOME=$JAVA_11_HOME'

	export JAVA_HOME=$JAVA_11_HOME

##	export JAVA_HOME=$(/usr/libexec/java_home -v 1.7 2>/dev/null)
#	export JAVA_HOME=$(/usr/libexec/java_home 2>/dev/null)
##	export STUDIO_JDK=/Library/Java/JavaVirtualMachines/jdk1.8.0_66.jdk/Contents/Home/
##	export ANDROID_STUDIO_JDK="$STUDIO_JDK"

	export ANDROID_HOME=$HOME/Library/Android/sdk
	export PATH=$PATH:$ANDROID_HOME/emulator
	export PATH=$PATH:$ANDROID_HOME/platform-tools

	# Appengine Java SDK
	APPENGINE_SDK_VERSION=1.9.31
	export PATH=/Users/celly/.m2/repository/com/google/appengine/appengine-java-sdk/$APPENGINE_SDK_VERSION/appengine-java-sdk/appengine-java-sdk-$APPENGINE_SDK_VERSION/bin:$PATH

	# GO
	export GOPATH=${MAIN_HOME}/go

	# DOCKER
	[ -s "/Applications/Docker.app/Contents/Resources/etc/docker-compose.bash-completion" ] && . "/Applications/Docker.app/Contents/Resources/etc/docker-compose.bash-completion"
	[ -s "/Applications/Docker.app/Contents/Resources/etc/docker.bash-completion" ] && . "/Applications/Docker.app/Contents/Resources/etc/docker.bash-completion"
fi

unset PLATFORM

# GIT bash prompt
if [ -f $(dirname $BASH_SOURCE)/git_prompt ]; then
	. $(dirname $BASH_SOURCE)/git_prompt
	export PROMPT_COMMAND="create_prompt"
	#export PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND; }create_prompt"
fi

# Save and reload the history after each command finishes
# export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"
export PROMPT_COMMAND="history -a; $PROMPT_COMMAND"

if [ "$TERM_PROGRAM" == "vscode" ]; then
	export PROMPT_COMMAND='echo -ne "\033];${PWD##*/}\007"';
fi

# function _update_ps1() { export PS1="$(/Users/celly/tmp/powerline-shell/powerline-shell.py $? 2> /dev/null)"; }
# if [ "$TERM" != "linux" ]; then
# 	PROMPT_COMMAND="_update_ps1; $PROMPT_COMMAND"
# fi

# Tell the terminal about the working directory at each prompt.
#if [ "$TERM_PROGRAM" == "Apple_Terminal" ] && [ -z "$INSIDE_EMACS" ]; then
#	update_terminal_cwd() {
#		# Identify the directory using a "file:" scheme URL,
#		# including the host name to disambiguate local vs.
#		# remote connections. Percent-escape spaces.
#		local SEARCH=' '
#		local REPLACE='%20'
#		local PWD_URL="file://$HOSTNAME${PWD//$SEARCH/$REPLACE}"
#		printf '\e]7;%s\a' "$PWD_URL"
#	}
#	PROMPT_COMMAND="update_terminal_cwd; $PROMPT_COMMAND"
#fi
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi
