#!/bin/bash

wget -q -O - http://github.com/strong_aliases > ~/.strong_aliases
grep -q "strong_aliases" ~/.bashrc || echo "[ -f ~/.strong_aliases ] && . ~/.strong_aliases" >> ~/.bashrc