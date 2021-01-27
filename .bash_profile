#!/usr/bin/env bash
# See explanation at top of .bashrc. 
# Essentially, we want all terminals to run .bashrc. On login terminals (all 
# MacOS terminals and all tmux windows), .bash_profile is run, so we'll source 
# .bashrc from here. 
# Code from: https://scriptingosx.com/2017/04/about-bash_profile-and-bashrc-on-macos/
if \[ -f ~/.bashrc \]; then 
    source ~/.bashrc 
else
    echo Cannot find ~/.bashrc file! 
fi
