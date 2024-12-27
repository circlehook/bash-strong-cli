# About 
The file **strong_aliases** contains functions and aliases, that are placed in the .bashrc to quickly perform daily tasks in the console.

## Install

#### One command launch
```
curl https://raw.githubusercontent.com/circlehook/bash-strong-cli/refs/heads/main/cli.sh | bash && source ~/.bashrc && cli
``` 
#### Manual install 
```
wget -q -O - https://raw.githubusercontent.com/circlehook/bash-strong-cli/refs/heads/main/strong_aliases > ~/.strong_aliases
grep -q "strong_aliases" ~/.bashrc || echo "[ -f ~/.strong_aliases ] && . ~/.strong_aliases" >> ~/.bashrc
source ~/.bashrc
```
#### Usage
```
cli
```

## Pretty launch on your domain

#### Create a file cli.sh in the root of the site
```
#!/bin/bash

wget -q -O - https://raw.githubusercontent.com/circlehook/bash-strong-cli/refs/heads/main/strong_aliases > ~/.strong_aliases
grep -q "strong_aliases" ~/.bashrc || echo "[ -f ~/.strong_aliases ] && . ~/.strong_aliases" >> ~/.bashrc
```

#### One command launch
```
curl https://example.com/cli.sh | bash && source ~/.bashrc && cli
```