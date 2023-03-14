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

###############################################################################
# Shell history 

# All shells should append to ~/.bash_history before running the command.
# Default behavior is to save history after terminal logs out.
shopt -s histappend
# Save 5,000 lines of history in memory
HISTSIZE=10000
# Save 2,000,000 lines of history to disk (will have to grep ~/.bash_history for full listing)
HISTFILESIZE=2000000
# Ignore redundant or space commands
HISTCONTROL=ignoreboth
# Ignore more
HISTIGNORE='ls:ll:ls -alh:pwd:clear:history'
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

# Add Poetry to PATH
export PATH="$HOME/.local/bin:$PATH"

###############################################################################
# Track dotfiles with Git 

# dotfiles points to $HOME/.dotfiles Git repo 
alias dotfiles="git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME"

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
# tmux

# Start tmux on every shell login. See: https://unix.stackexchange.com/a/113768
# &> redirects output to "blackhole" /dev/null. This command is 0 on success 
# and 1 on error (tmux-mem-cpu-load doesn't exist). 
# command -v checks if command exists: https://stackoverflow.com/a/677212/13697995
if ! command -v tmux &> /dev/null; then 
    echo "Cannot find tmux! Please install it."
# elif [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && 
# 	[ -z "$TMUX" ]; then
#     tmux new-session -A -s main # See: https://unix.stackexchange.com/a/176885
fi

# Check for tmux-mem-cpu-load addon
if ! command -v tmux-mem-cpu-load &> /dev/null; then
    echo "Cannot find tmux-mem-cpu-load command! Install it with Homebrew or \ 
	from here: https://github.com/thewtex/tmux-mem-cpu-load"
fi

###############################################################################

# Zoxide 
eval "$(zoxide init bash)"

# fzf
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# Rust
. "$HOME/.cargo/env"

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
