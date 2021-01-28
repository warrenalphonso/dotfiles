#!/usr/bin/env bash

###############################################################################
# Usage 
# Remove existing .bashrc, .bash_profile, .bash_prompt, and .vimrc files. 
# Clone on a new computer: 
#   $ git clone --bare https://github.com/warrenalphonso/dotfiles.git $HOME/.dotfiles
# Define alias: 
#   $ alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
# Checkout repo to $HOME: 
#   $ dotfiles checkout

###############################################################################
# Overview 
# 
# A Unix shell is a command-line interpreter for Unix-like operating systems. 
# Bash is a popular Unix shell. 
# 
# Shells can be interactive or non-interactive, and login or non-login. An 
# interactive shell reads and writes to a user's terminal. Any time I open up 
# terminal, I'm opening an interactive shell. 
# Non-interactive shells are opened whenever I run a run a script, so they're 
# very common, but I won't ever see them. 
# An interactive, login shell is the first shell that runs when you log in. 
# The idea is to setup your main configuration once and then every additional 
# shell will be a non-login shell which doesn't have to do much setup. 
# From: https://unix.stackexchange.com/a/46856
#
# In MacOS, the Terminal app ALWAYS runs as a login shell! 
# See: https://scriptingosx.com/2017/04/about-bash_profile-and-bashrc-on-macos/
# In tmux, all new windows are login shells also! 
# See: https://superuser.com/a/970847
#
# I use the iTerm2 terminal, and I've also set it to ALWAYS run as a login 
# shell to avoid confusion. See: https://stackoverflow.com/a/25025999/13697995
# 
# The distinction between login shells and non-login shells is the dotfile 
# they load. Login shells load .bash_profile while non-login shells load 
# .bashrc. 
#
# To keep everything consistent, I source .bashrc from .bash_profile, so that 
# login and non-login shells will always run the login setup. This should 
# keep Ubuntu and MacOS bash file structure similar. 
# 
# 
# STRUCTURE: 
# - .bashrc: normal configurations, PATH modifications, etc. 
#     - Sources .bash_prompt, explained below. 
# - .bash_profile: Sources .bashrc. Doesn't add anything. 
# - .bash_prompt: Makes terminal look pretty. Sourced by .bashrc. 

###############################################################################
# Set up

# Make terminal look pretty
if \[ -f $HOME/.bash_prompt \]; then 
    source $HOME/.bash_prompt
else 
    echo Cannot find $HOME/.bash_prompt file!
fi

# Mac or Linux? See: https://stackoverflow.com/a/3466183/13697995
case "$(uname -s)" in 
    Linux*) 	machine=Linux;;
    Darwin*)    machine=Mac;;
    *)          machine="Unknown:$(uname -s)"
esac 

###############################################################################
# From: https://github.com/mathiasbynens/dotfiles

# Case-insensitive globbing (used in pathname expansion)
# See: https://unix.stackexchange.com/a/16519
shopt -s nocaseglob 

# Append to the Bash history file, rather than overwriting it
shopt -s histappend

# Autocorrect typos in path names when using `cd`
# See: https://linux.101hacks.com/cd-command/shopt-s-cdspell/
shopt -s cdspell

# Enable some Bash 4 features when possible:
# * `autocd`, e.g. `**/qux` will enter `./foo/bar/baz/qux`
# * Recursive globbing, e.g. `echo **/*.txt`
for option in autocd globstar; do
    shopt -s "$option" 2> /dev/null
done
unset option

# HomeBrew autocompletes for MacOS. 
# There's probably a way to get something similar to work on Ubuntu too. For 
# example, see: 
# https://github.com/alrra/dotfiles/blob/main/src/shell/ubuntu/bash_autocomplete
# Add tab completion for many Bash commands
if \[ $machine == "Mac" \] && which brew &> /dev/null \
	&& [ -r "$(brew --prefix)/etc/profile.d/bash_completion.sh" ]; then
    # Ensure existing Homebrew v1 completions continue to work
    export BASH_COMPLETION_COMPAT_DIR="$(brew --prefix)/etc/bash_completion.d"
    source "$(brew --prefix)/etc/profile.d/bash_completion.sh"
elif [ -f /etc/bash_completion ]; then
    source /etc/bash_completion
fi

###############################################################################
# Python Setup 
# 
# MacOS (currently) ships with Python 2.7 (`python` alias) and XCode ships with 
# Python 3.9 (`python3` alias). We don't want to rely on these because they'll 
# change with system updates!
# 
# We'll use pyenv to manage Python versions. 
# For setup, see: https://github.com/pyenv/pyenv/wiki
#
# With pyenv, we can easily install and switch between different Python versions. 
# We can set a global Python version with: pyenv global 3.9.1 , or we can set
# a local Python version for the current directory with: pyenv local 3.9.1
# 
# See pyenv commands here: https://github.com/pyenv/pyenv/blob/master/COMMANDS.md
# For Jupyter notebook, do: pip install ipykernel and brew install jupyter
# Make sure `jupyter kernelspec list` has Python pointing to pyenv's Python. 

# Unnecessary if installed via Brew
if \[ $machine == "Linux" \]; then 
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
fi

# Enable shim and autocomplete 
# This manipulates PATH so keep it close to end of .bashrc.
if command -v pyenv 1>/dev/null 2>&1; then
    eval "$(pyenv init -)"
else 
    echo pyenv is not installed!
fi

###############################################################################
# Rust Setup 

export PATH="$HOME/.cargo/bin:$PATH"

# Compile Rust file, save to build/ directory, and run
function rrun() {
    rustc --out-dir build $1
    ./build/${1%.rs}
}

###############################################################################
# React Native Setup 

# Android SDK 
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools

###############################################################################
# Track dotfiles with Git 

# dotfiles points to $HOME/.dotfiles Git repo 
alias dotfiles="/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"

###############################################################################
# iTerm2 (MacOS) 
# We've got to enable shell integration so that iTerm2 can track command 
# history, working directory, host name, etc. 
# IMPORTANT: This should be at the end of .bash_profile (.bashrc is fine because 
# we source it from .bash_profile) because other scripts might overwrite the 
# settings it needs, such as `PROMPT_COMMAND`. 
# See: https://iterm2.com/documentation-shell-integration.html
if \[ -f $HOME/.iterm2_shell_integration.bash \]; then 
    source $HOME/.iterm2_shell_integration.bash
elif \[ $machine == "Mac" \]; then 
    echo "Cannot find $HOME/.iterm2_shell_integration.bash! \
	See: https://iterm2.com/documentation-shell-integration.html"
fi

###############################################################################
# Clean up

unset machine

