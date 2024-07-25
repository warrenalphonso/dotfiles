#!/usr/bin/env bash

###############################################################################
# See top of .bashrc for usage instructions and overview. 
# Essentially, we want all terminals to run .bashrc. On login terminals (all 
# MacOS terminals and all tmux windows), .bash_profile is run, so we'll source 
# .bashrc from here. 
# Code from: https://scriptingosx.com/2017/04/about-bash_profile-and-bashrc-on-macos/

if \[ -f $HOME/.bashrc \]; then 
    source $HOME/.bashrc 
else
    echo Cannot find $HOME/.bashrc file! 
fi
. "$HOME/.cargo/env"
