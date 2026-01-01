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

# Set up Homebrew
if \[ $machine == "Mac" \]; then 
    eval "$(/opt/homebrew/bin/brew shellenv)"
    export BASH_SILENCE_DEPRECATION_WARNING=1
fi

###############################################################################
# Filesystem niceties
# From: https://github.com/mathiasbynens/dotfiles

# Case-insensitive globbing (used in pathname expansion)
# See: https://unix.stackexchange.com/a/16519
shopt -s nocaseglob 

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

###############################################################################
# Shell history 

# All shells should append to ~/.bash_history.
shopt -s histappend
# PROMPT_COMMAND prepends every command. This appends to ~/.bash_history after
# each command instead of only doing so when the shell exits.
export PROMPT_COMMAND="history -a; $PROMPT_COMMAND"

# Save 5,000 lines of history in memory
HISTSIZE=10000
# Save 2,000,000 lines of history to disk (will have to grep ~/.bash_history for full listing)
HISTFILESIZE=2000000
# Ignore redundant or space commands
HISTCONTROL=ignoreboth
# Set time format
HISTTIMEFORMAT='%F %T '

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
# For Jupyter notebook, do: pip install ipykernel, brew install jupyter, and 
# pip install jupyter. 
# Make sure `jupyter kernelspec list` has Python pointing to pyenv's Python. 
# See: https://albertauyeung.github.io/2020/08/17/pyenv-jupyter.html

# Unnecessary if installed via Brew
if \[ $machine == "Linux" \]; then 
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
fi

# Enable shim and autocomplete 
# This manipulates PATH so keep it close to end of .bashrc.
if command -v pyenv 1>/dev/null 2>&1; then
    # Enable shims without shell integration because it's slow
    eval "$(pyenv init --path)"
else 
    echo pyenv is not installed!
fi

export PATH="$HOME/.local/bin:/usr/local/bin:$PATH"

###############################################################################
# Track dotfiles with Git 

# dotfiles points to $HOME/.dotfiles Git repo 
alias dotfiles="git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"

###############################################################################
# Git

alias g="git"

# re-attempt previous commit
# From: https://unix.stackexchange.com/a/590225
recommit () {
    local gitdir=$(git rev-parse --git-dir)
    local inprogress_commit_message=$(cat "$gitdir/COMMIT_EDITMSG")
    git commit -m "$inprogress_commit_message" "$@"
}

###############################################################################
# Colorful ls (MacOS) 
if \[ $machine == "Mac" \]; then 
    export CLICOLOR=1
fi

###############################################################################
# Zoxide 
eval "$(zoxide init bash)"

# fzf
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# Rust
. "$HOME/.cargo/env"

###############################################################################
# Bindings for Readline library functions: https://tiswww.case.edu/php/chet/readline/rltop.html
# The terminal multiplexer you're using should send these escape codes to Bash,
# which then uses the Readline library to modify the cursor.
# If you're using Kitty, see kitty.conf or `kitten show-key -m kitty` to see what
# escape codes the keys are sending.
bind '"\e[1;3D": backward-word'
bind '"\e[1;3C": forward-word'

###############################################################################
# Clean up

unset machine
