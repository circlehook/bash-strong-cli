# ~/.strong_aliases 1.5.5
# Author:  Dmitry Vinichenko <circlehook.pro at gmail.com>
# Website: https://github.com/circlehook/bash-strong-cli
# Docs: https://github.com/circlehook/bash-strong-cli/blob/main/README.md
# Licence: LGPLv2
# One command launch:
#   curl https://raw.githubusercontent.com/circlehook/bash-strong-cli/refs/heads/main/install.sh | bash && source ~/.bashrc && cli
# Usage: 
#   cli 
#   cli update
#
# V1.0      26 Dec 2024     Initial release
# V1.1      26 Dec 2024     cli function
# V1.2      27 Dec 2024     create ctl, sql, log functions
# V1.3      28 Dec 2024     ngx, net
# V1.5      22 Nov 2025     cf, fp, fs

CLI_URL="https://raw.githubusercontent.com/circlehook/bash-strong-cli/refs/heads/main/strong_aliases";
CF_API_URL="https://api.cloudflare.com/client/v4";

# https://github.com/BMDan/tuning-primer.sh
MYSQL_TUNING_URL="https://raw.githubusercontent.com/BMDan/tuning-primer.sh/main/tuning-primer.sh"
# https://github.com/pixelb/ps_mem/
RAM_COUNTER_URL="https://raw.githubusercontent.com/pixelb/ps_mem/refs/heads/master/ps_mem.py";

# My utils
UTILS_BACKUP="https://raw.githubusercontent.com/circlehook/bash-strong-cli/refs/heads/main/files/backup.sh";
MAN_URL="https://raw.githubusercontent.com/circlehook/bash-strong-cli/refs/heads/main/notes";

alias ips="awk '{print \$1}' | sort | uniq -c | sort -nr";
alias rgb='ccze -A';
alias tailf='tail -f';
alias footer='tail -n 1000';
_title(){ echo -e "\n$(tput setaf 6)$1$(tput sgr0)\n"; };
live(){
    if [ -z "$1" ]; then
        echo "Usage: live COMMAND"
        return 1
    fi
    watch -d "bash -ci \"$1\""
};
hide(){
    if [ $# -eq 1 ]; then
        grep -vE "$1"
    else
        echo -e "\n~/.strong_aliases function. grep -vE \n\nUsage:\n STDOUT | hide 'STRING1|STRING2'\n";
    fi
};

_cli_logo(){
echo -e '\e[95m'
echo '  ____    _                                       ____   _       ___   '
echo ' / ___|  | |_   _ __    ___    _ __     __ _     / ___| | |     |_ _|   '
echo " \___ \  | __| | '__|  / _ \  | '_ \   / _\` |   | |     | |      | |    "
echo '  ___) | | |_  | |    | (_) | | | | | | (_| |   | |___  | |___   | |    '
echo ' |____/   \__| |_|     \___/  |_| |_|  \__, |    \____| |_____| |___|   '
echo '                                       |___/                            ' 
 echo -e '\e[0m\e[37m \e[0m'
};
_cli_help(){ 
 clear
CLI_CONTENT=$(wget -q -O - "$CLI_URL" 2>/dev/null)
if echo "$CLI_CONTENT" | head -n1 | grep -q 'strong_aliases'; then
    CLI_VER_NEW=$(echo "$CLI_CONTENT" | head -n1 | awk '{print $3}')
    CLI_VER=$(head -n1 ~/.strong_aliases 2>/dev/null | awk '{print $3}')
    CLI_WARN=""
    [ "$CLI_VER" != "$CLI_VER_NEW" ] && CLI_WARN="\n$(tput setaf 3)  Needs to be updated to version $CLI_VER_NEW\n  Run: $1 update$(tput sgr0)\n"
fi
 echo -e "$(_cli_logo)
Home page         : https://github.com/circlehook/bash-strong-cli
Description       : ~/.strong_aliases function for aliases management.
Version           : $CLI_VER $CLI_WARN
    
Usage:
  $1 update      : update ~/.strong_aliases && source ~/.bashrc
  $1 edit        : edit   ~/.strong_aliases
  $1 reload      : source ~/.bashrc 
  $1 fresh       : clear  ~/.bash_history from keywords
  $1 drop        : clear  ~/.bash_history && remove ~/.strong_aliases
  $1 board       : open TMUX session \"board\". Press Ctrl+B then D to detach session

Functions list:
  cf              :  Cloudflare API Toolkit
  ctl             :  System         Toolkit
  dcr             :  Docker         Toolkit  
  fs              :  File System    Toolkit
  fp              :  Fastpanel      Toolkit
  log             :  Logs           Toolkit 
  ngx             :  Nginx          Toolkit
  net             :  Network        Toolkit
  sql             :  Mysql          Toolkit

Aliases:
  footer FILE         :  (tail -n) Show last 1000 lines
  live   \"COMMAND\"    :  (watch)   Display live 
  STDOUT | ips        :  (sort)    Show TOP unique IPs 
  STDOUT | rgb        :  (ccze -A) Colorize STDOUT using ccze(1)
  STDOUT | hide EXPR  :  (grep -v) Invert match grep(1)

";
};
_cli_fresh(){   history -c; sed -i '/cli\|sql\|ngx\|net\|fs\|ctl\|dcr\|log\|note\|scan\|ips\|hide\|rgb\|fp\|cf/d' ~/.bash_history; };
_cli_board(){
  echo '
    bind-key v split-window -h
    bind-key h split-window -v
    select-layout even-vertical
    select-layout even-horizontal
    split-window -v
    split-window -h
  ' > /root/.tmux-panels.conf 
  tmux ls | grep -q "board" && { tmux attach -t board || true; } || { tmux new -d -s board && tmux source /root/.tmux-panels.conf && tmux attach -t board; }
 };
cli(){
  if [ -n "$1" ]; then
    case "$1" in
      "help")   _cli_help $FUNCNAME;; 
      "edit")   command -v nano &> /dev/null && nano "~/.strong_aliases" || vi "~/.strong_aliases";;
      "update") wget -O - $CLI_URL > ~/.strong_aliases; source ~/.bashrc; cli;;
      "reload") source ~/.bashrc;;
      "fresh")  _cli_fresh; unset PASSWORD;;
      "board")  _cli_board;;
      "drop") _cli_fresh; rm -rf ~/.strong_aliases; unset cli sql ngx net fs dcr ctl log note fp cf;;
      *) _cli_help $FUNCNAME;; 
    esac 
  else
    _cli_help $FUNCNAME;
  fi
};

_ctl_crons(){
  _title "/etc/crontab"
  cat /etc/crontab | grep -vE '^SHELL|^PATH|^MAILTO|^#|^$'
  USERS=$(cat /etc/passwd | grep sh | grep -v nologin | awk -F ':' '{print $1}')
  for USER in $USERS; do
    if crontab -l -u "$USER" >/dev/null 2>&1; then
    _title "${USER}:"
    crontab -l -u "$USER"
  fi
done
};
_ctl_help(){
  echo -e " 
~/.strong_aliases function. System tools management

Usage: 
  $1 list-fail                    :   (systemctl)   list fail services
  $1 list                         :   (systemctl)   list services + installed unit files
  $1 %               [string]     :   (systemctl)  (list services + installed unit files) | grep [string]
  $1 tree                         :   (systemctl)  tree services  
  
  $1 [=|+|-|@]       [service]    :   (systemctl)  status/start/stop/restart [service]  
  $1 [boot|on|off]   [service]    :   (systemctl)  check/enable/disable/ start on boot  
  $1 unit            [service]    :   (systemctl edit --full [service]) (needs daemon-reload)
  $1 reload                       :   (systemctl daemon-reload)

  $1 crons                        :   (crontab)    show all crontab tasks
  $1 [crontab|fstab|hosts|resolv] :   (nano)       edit /etc/{crontab|fstab|hosts|resolv.conf}
  $1 [os|passwd|group]            :   (cat)        cat /etc/{os-release|passwd|group}
  $1 name            <hostname>   :   (hostnamectl set-hostname <hostname>) OR (hostnamectl | grep hostname) 
  $1 time            <time>       :   (timedatectl set-time     <time>    ) OR (timedatectl | grep Local)
  $1 zone            <timezone>   :   (timedatectl set-timezone <timezone>) OR (timedatectl | grep zone)
  $1 zones           <string>     :   (timedatectl list-timezones) OR (timedatectl list-timezones | grep -i <string>) 
 
Examples:
  $1 % fire     OR  $1 list | grep fire   
  $1 = nginx    OR  $1 status nginx  (original systemctl option STATUS)
  $1 unit nginx AND $1 reload

  $1 name       OR  $1 name example.com
  $1 zones      OR  $1 zones euro
  $1 zone       OR  $1 zone Europe/Kyiv
  $1 time       OR  $1 time '2024-11-01 12:34:00'

";
};

ctl(){
  if [ -n "$1" ]; then
    case "$1" in
      "help")        _ctl_help $FUNCNAME;; 
      "tree")        systemctl list-dependencies;; 
      "reload")      systemctl daemon-reload;; 
      "list-fail")   systemctl -at service | grep -E 'fail|not-found';; 
      "list")        systemctl -at service --no-pager; systemctl list-unit-files --no-pager;;
      "crons")       _ctl_crons;;
      "crontab")     nano /etc/crontab;;
      "fstab")       nano /etc/fstab;;
      "hosts")       nano /etc/hosts;;
      "resolv")      nano /etc/resolv.conf;;
      "os")          cat /etc/os-release;;
      "passwd")      cat /etc/passwd;;
      "group")       cat /etc/group;;
      "%")           [ -n "$2" ] && systemctl -at service | grep $2; systemctl list-unit-files | grep $2;; 
      "unit")        [ -n "$2" ] && systemctl edit --full $2;; 
      "boot")        [ -n "$2" ] && systemctl is-enabled $2;; 
      "on")          [ -n "$2" ] && systemctl enable $2;; 
      "off")         [ -n "$2" ] && systemctl disable $2;; 
      "=")           [ -n "$2" ] && systemctl status $2;; 
      "+")           [ -n "$2" ] && systemctl start $2;   echo -e "\nService started.  \n"; systemctl status $2;; 
      "-")           [ -n "$2" ] && systemctl stop $2;    echo -e "\nService stoped.   \n"; systemctl status $2;; 
      "@")           [ -n "$2" ] && systemctl restart $2; echo -e "\nService restarted.\n"; systemctl status $2;; 
      "name")        [ -n "$2" ] && hostnamectl set-hostname $2 || hostnamectl | grep hostname;; 
      "zone")        [ -n "$2" ] && timedatectl set-timezone $2 || timedatectl | grep zone;; 
      "time")        [ -n "$2" ] && timedatectl set-time $2 || timedatectl | grep Local;; 
      "zones")       [ -n "$2" ] && timedatectl list-timezones | grep -i $2 || timedatectl list-timezones;; 
      *) _title "Usage: $FUNCNAME help" && systemctl "$@";; 
    esac 
  else
    _ctl_help $FUNCNAME;
  fi
};
_log_help(){
  echo -e " 
~/.strong_aliases function. Logs Toolkit

Usage: 
  $1 size                            : (journalctl) journalctl disk usage  
  $1 clear  [mb]                     : (journalctl) clearing journal up to [mb]  
  $1 view   [hours]                  : (journalctl) last [hours] journal   
  $1 error  [hours]                  : (journalctl) last [hours] journal errors   
  $1 period [min-hours] [max-hours]  : (journalctl) journal entries between hours
  $1 boots                           : (journalctl) show list boots
  $1 sessions                        : (last) show listing of last logged in users in 30 days

Examples:
  $1 period 10 11
  $1 --since \"2024-01-14 00:11:00\" --until \"2024-01-14 00:13:00\"

";
};
log(){
  if [ -n "$1" ]; then
    case "$1" in
      "help")   _log_help $FUNCNAME;; 
      "size")   journalctl --disk-usage;; 
      "clear")  [ -n "$2" ] && journalctl --vacuum-size=$2M || journalctl --vacuum-size=0M;; 
      "view")   [ -n "$2" ] && journalctl --since "$2 hours ago";; 
      "error")  [ -n "$2" ] && journalctl -p err -b --since "$2 hour ago";; 
      "period") journalctl --since "$3 hour ago" --until "$2 hour ago";; 
      "boots")  journalctl --list-boots;; 
      "sessions") last | grep $(date -d "last month" +"%b");; 
      *) _title "Usage: $FUNCNAME help" && journalctl "$@";; 
    esac 
  else
    _log_help $FUNCNAME;
  fi
};

_fs_help() { echo -e "\n~/.strong_aliases function. File system Toolkit

 Usage: 
  $1 info                 : (smartctl)   Disk information
  $1 free                 : (df -m)      Free disk space online
  $1        [file]        : (grep)       Read file without comments
  $1 <exp>  [path]</*.*>  : (ls|grep -R) Show full path OR  Recursive scan directory by grep(1) 
  $1 size   [path]        : (du -d 1 -h) Top 10 largest directories
  $1 save   [path]        : (cp -r)      Copy    [path] to /usr/bac/\$(basename [path])-Y-m-d-HM/
  $1 tar    [path]        : (tar -cvf)   Archive [path] to      /../\$(basename [path]).tar
  $1 gz     [path]        : (tar -czvf)  Archive [path] to      /../\$(basename [path]).tar.gz
  $1 zip    [path]        : (zip -r)     Archive [path] to      /../\$(basename [path]).zip
  $1 unpack [file]        : (tar|gunzip|unzip)  Unpacking any archive (tar|gz|tar.gz|zip)
  
  $1 send     [path] [user@host]<:port><:dst_path> <excludes> : (rsync) Send [path] to the host
  $1 send-bx1 [path] [user@host]<:port><:dst_path> <excludes> :  - / -  with bx excludes (backup,cache)
  $1 send-bx2 [path] [user@host]<:port><:dst_path> <excludes> :  - / -  with bx excludes (backup,cache,configs)

 Example: 
  $1 .
  $1 /etc/php/8.4/fpm/php-fpm.conf
  $1 \"memory\" \"/etc/php/*.conf\"  

  $1 send .        root@1.2.3.4                       (send this directory to /tmp/upload) 
  $1 send file.tar root@1.2.3.4:2222:/home/bitrix/www
  $1 send /var/www root@1.2.3.4:2222:/vaw/www/USER/data/www/DOMAIN.COM/ \"app/etc/env.php\"
  $1 send-bx2 /home/bitrix/www root@1.2.3.4:2222:/home/bitrix/www
"; };
_fs_save(){ 
   DIR_NAME=$(basename "$1"); PATH_FULL="/usr/bac/$DIR_NAME-$(date +%Y-%m-%d-%H%M)"; 
   [ ! -d "$PATH_FULL" ] && mkdir -p "$PATH_FULL" || rm -rf "$PATH_FULL"; cp -r "$1/" "$PATH_FULL"; du -d 0 -h "$PATH_FULL"; ls -la /usr/bac | grep "$DIR_NAME"; 
};
_fs_unpack() {
    case "$1" in
        *.tar.gz | *.tgz) tar -xzvf "$1";;
        *.tar)   tar -xvf "$1";;
        *.gz)    gunzip "$1";;
        *.zip)   unzip "$1";;
        *)       echo "Unknown archive format: $1";;
    esac
};
_fs_info(){ 
  if command -v smartctl >/dev/null 2>&1; then
    echo;
    echo -e "\e[36m*) smartctl -a /dev/disk\e[0m";
    for DISK in /dev/sd?; do [ -e "$DISK" ] && smartctl -a $DISK | awk '/test result/ {test_result=$NF} /Power_On_Hours/ {printf "Power_On_Days %.2f %s\n", $NF/24, test_result}'; done;
    for DISK in /dev/nvme???; do [ -e "$DISK" ] && echo -e "\n$DISK"; smartctl -a $DISK | grep -E "Temperature:|Percentage Used:|Critical Warning"; done; 
  else
    echo -e "\e[36m*) smartctl not install."
  fi
  echo;
  echo -e "\e[36m*) cat /proc/mdstat\e[0m";
  grep -qE '^md[0-9]+' /proc/mdstat && cat /proc/mdstat;
  echo;
  echo -e "\e[36m*) lsblk -f\e[0m";
  lsblk -f;
};
_fs_send(){
  if [ "$#" -eq 1 ]; then
   _fs_notes;
  else
   PORT="22";
   SRC_PATH=$2;
   ROUTE=$3;
   EXCLUDES_ARG=$4;
   EXCLUDE_STR="";
   
   OLD_IFS=$IFS;
   #[[ ! -z "$EXCLUDES_ARG" ]] && EXCLUDES_STR=("${EXCLUDES_ARG[@]}");
   IFS=' ' read -ra EXCLUDES <<< "$4"
   for EXCLUDE in "${EXCLUDES[@]}"; do
     EXCLUDE_STR+="--exclude='$EXCLUDE' "
     echo -e "$(tput setaf 4)--exclude='$EXCLUDE'$(tput sgr0)";
   done
 
   IFS=":"; 
   [[ $ROUTE == *:*:* ]] && read -r ADDRESS PORT DST_PATH <<< "$ROUTE" || read -r ADDRESS DST_PATH <<< "$ROUTE";
   IFS=$OLD_IFS;
     
   [ -z "$DST_PATH" ] && DST_PATH="/tmp/upload/"
   echo -e "\n$(tput setaf 6)Address: $ADDRESS:$DST_PATH\nPort:   $PORT$(tput sgr0)\n";
   eval "rsync -avzhP -e \"ssh -p $PORT\" $EXCLUDE_STR $SRC_PATH $ADDRESS:$DST_PATH";
  fi
};
_fs_scan() {
    if [ $# -eq 2 ]; then
        grep --color=always -iRnE "$1" "$2"
    elif [ $# -eq 3 ]; then
        grep --color=always --include="$1" -iRnE "$2" "$3"
    fi
};

fs(){
if [ -n "$1" ]; then
  case "$1" in
    "info")       _fs_info ;;
    "scan")       [ -n "$3" ] && _fs_scan "$2" "$3" ;;
    "size")       [ -n "$2" ] && du -h --max-depth=1 $2|sort -h|tail -n 11;;
    "save")       [ -n "$2" ] && _fs_save "$2" ;;
    "tar")        [ -n "$2" ] && tar -cvf $(dirname "$2")/$(basename "$2").tar "$2";;
    "gz")         [ -n "$2" ] && tar -czvf $(dirname "$2")/$(basename "$2").tar.gz "$2";;
    "zip")        [ -n "$2" ] && zip -r $(dirname "$2")/$(basename "$2").zip "$2";;
    "unpack")     [ -n "$2" ] && _fs_unpack "$2" ;;
    "send")       _fs_send "$@" ;;
    "send-bx1")   _fs_send "$@" "bitrix/backup/ bitrix/cache/ bitrix/managed_cache/";;
    "send-bx2")   _fs_send "$@" "bitrix/backup/ bitrix/cache/ bitrix/managed_cache/ bitrix/php_interface/dbconn.php bitrix/.settings.php";;
    "free")       watch -d df -m -x tmpfs -x overlay -x devtmpfs;;
    *)
      if [ $# -eq 1 ] && [ -f "$1" ]; then
        grep -vnE --color=always '^(;|$|#)' "$1"
      elif [ $# -eq 1 ] && [ -d "$1" ]; then
        [ -z "$(ls -A "$1" 2>/dev/null)" ] && echo -e "\nEmpty dir.\n" || ls -la -d "$(realpath "$1")"/*;
      elif [ $# -eq 2 ] && [ -d "$2" ]; then
        grep --color=always -iRnE "$1" "$2"
      elif [[ $# -eq 2 && $2 =~ ^/.*/\*\.[^.]+$ ]]; then
        PATH_FS="$2"
        echo "${PATH_FS##*/}"
        echo
        echo "${PATH_FS%/*}/"
        grep --color=always --include="${PATH_FS##*/}" -iRnE "$1" "${PATH_FS%/*}/"
      else
        _fs_help "$FUNCNAME"
      fi
    ;;
  esac
else
  _fs_help "$FUNCNAME"
fi
};
_fp_help(){
 echo -e "\n~/.strong_aliases function. Fastpanel Toolkit (mogwai)\n
Usage: 
  $1 transfer [DOMAINS]   :  (mogwai) Domains info for transfer
  $1 sites                :  (mogwai) Pretty list all sites
  $1 domains              :  (mogwai) Array all domains


";};
_fp_transfer(){
  echo -e "\nmogwai users list:"
  for DOMAIN in $1; do
      mogwai users list | grep $(mogwai sites list | grep $DOMAIN | awk '{print $4}') | awk '{print $1,$2,$3}'
  done
  echo -e "\nmogwai users remove:";
  for DOMAIN in $1; do
      FP_USER_ID=$(mogwai users list | grep $(mogwai sites list | grep $DOMAIN | awk '{print $4}') | awk '{print $1}')
      echo "mogwai users remove --id=$FP_USER_ID"
  done
  echo -e "\nfastpanel transfer run:";
  for DOMAIN in $1; do
      FP_USER_NAME=$(mogwai users list | grep $(mogwai sites list | grep $DOMAIN | awk '{print $4}') | awk '{print $2}')
      echo "/usr/local/fastpanel2/fastpanel transfer run --remote_host=$(hostname -I | awk '{print $1}') --remote_username=root --remote_password=PASSWORD -m $(hostname -I | awk '{print $1}'),1.2.3.4 --users=\"$FP_USER_NAME\""
  done
  echo -e "\n";
};
fp(){
  if ! command -v mogwai &> /dev/null; then
    echo -e "The mogwai utility was not found. Using the function is not possible.\n\n"
    return 1
  fi

  if [ -n "$1" ]; then
    case "$1" in
      "transfer") [ -n "$2" ] && _fp_transfer "$2";;
      "sites") mogwai sites list | awk '{print $1, $2, $4, $8}';;
      "domains") echo -e "\nDomains:\n" && mogwai sites list | awk 'NR>1 {printf "%s ", $2} END {print ""}' && echo -e "\n";;
      *) mogwai "$@";;
    esac
  else
    _fp_help "$FUNCNAME"
  fi
}

_net_help(){
 echo -e "\n~/.strong_aliases function. Network Toolkit (netstat, ip, nmap, nc, iptables, openssl)\n
Usage: 
  $1 stat <string>          :  (netstat -nlpt) OR (netstat -nlptx | grep string)
  $1 server <port>          :  (python3 -m http.server <port>)  port default: 6789
  $1 ip                     :  (ip a)     show local + external IP addresses             
  $1 ddos                   :  (netstat)  show active connections of unique IP addresses 
  $1 ports                  :  (iptables) show open ports
  $1 ls                     :  (ss)       show listening ports                                
  $1 fire                   :  (iptables) show firewalls info                                
  $1 nft                    :  (nft)      show short nftables rules                                
  $1 banned                 :  (iptables) show list banned IP addresses                  
  $1 unban   [IP]           :  (fail2ban) unban IP address in all jails and database     
  $1 ciphers [host]         :  (nmap)     show supported ciphersnmap             
  $1 expssl  [host]         :  (openssl)  show certificate expiration date             
  $1 rand    <length>       :  (openssl)  generating a password of a specified length (default: 9)           
  $1 status  [host] [port]  :  (nc)       report port connection status
  
  $1 get utils              : (wget) download scripts and configs to /root/utils
  
  $1 exec [scenario]        : (curl) exec without save by URL
  $1 exec ram-counter       :  - / -  /source/tools/ram-counter.py   
  $1 exec sql-tuning        :  - / -  https://github.com/BMDan/tuning-primer.sh/blob/main/tuning-primer.sh


";};

_net_exec_python(){
  SCRIPT_URL=$1
  PYTHON_NEED=$2
  PYTHON_TWO="false"
  PYTHON_THREE="false"
  if command -v python &> /dev/null; then
    PYTHON_TWO="true"
  elif command -v python3 &> /dev/null; then
    PYTHON_THREE="true" 
  else
      echo -e "\nPython not found.\n";
      exit 1
  fi
  if [ "$PYTHON_NEED" == "python"    ] && [ "$PYTHON_TWO"   == "true"  ]; then
    PYTHON_VER="python"
  elif [ "$PYTHON_NEED" == "python3" ] && [ "$PYTHON_THREE" == "true"  ]; then
    PYTHON_VER="python3"
  elif [ "$PYTHON_NEED" == "python"  ] && [ "$PYTHON_TWO"   == "false" ] && [ "$PYTHON_THREE" == "true" ]; then
    PYTHON_VER="python3"
  elif [ "$PYTHON_NEED" == "python3" ] && [ "$PYTHON_THREE" == "false" ] && [ "$PYTHON_TWO" == "true" ]; then
    PYTHON_VER="python"
  else
    echo -e "\nPython not found 2. $PYTHON_VER\n";
  fi
  curl -sSL $SCRIPT_URL | $PYTHON_VER -
};
_net_exec(){ 
  NET_GET_TITLE="Make a choice. Use: net help"
  if [ -n "$1" ]; then
    case "$1" in
       "ram-counter")         _net_exec_python $RAM_COUNTER_URL "python";;
       "sql-tuning")          curl -sSL $MYSQL_TUNING_URL | bash -s;;
      *) _title "$NET_GET_TITLE";;
    esac 
  else
    _title "$NET_GET_TITLE";
  fi
};

_net_get_utils(){
  PATH_UTILS="/root/utils/"; mkdir -p $PATH_UTILS;
  wget -q -O - $UTILS_BACKUP    > $PATH_UTILS/backup.sh;
  echo -e "\n$(tput setaf 6)Files downloaded..$(tput sgr0)\n";
  chmod +x /root/utils/*; ls -R /root/utils; 
};
_net_get(){ 
  NET_GET_TITLE="Make a choice. Use: net help"
  if [ -n "$1" ]; then
    case "$1" in
       "utils") _net_get_utils;;
       *) _title "$NET_GET_TITLE";; 
    esac 
  else
    _title "$NET_GET_TITLE";
  fi
};
_net_fire(){
  update-alternatives --display iptables | grep current; echo;
  systemctl -at service | grep -E 'firewalld|ufw|iptables|fail2ban';echo;
  [ -d /etc/firewalld ] && grep -iRnE 'FirewallBackend' /etc/firewalld/
  [ -d /etc/fail2ban ] && grep -iRnE 'banaction = nftables|banaction = iptables' /etc/fail2ban/
  _title "$1"
};
_net_server(){ echo "http://$(curl -s ifconfig.me):$1"; python3 -m http.server $1; };
_net_ports(){ iptables -L -n | grep ACCEPT | grep tcp | awk -F " " '{print $7}' | awk -F ":" '{print $2}' | sort -nu | tr '\n' ' ' | tr '\t' ' ' && echo -e "\n"; command -v ufw &> /dev/null && ufw status; };

net(){
  FIREWALL_TITLE="\nTo extended view firewall rules use:\n    update-alternatives --config iptables\n    nft list ruleset | grep -E 'tcp dport|udp dport|accept|drop'\n    iptables -L -n\n    ufw status";
  if [ -n "$1" ]; then
    case "$1" in
      "ddos")        ss -tna | awk '{print $5}' | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | sort | uniq -c | sort -nr;;
      "ports")       echo && _net_ports && echo;;
      "fire")        _net_fire "$FIREWALL_TITLE";;  
      "nft")         nft list ruleset | grep -E 'tcp dport' && _title "$FIREWALL_TITLE";;
      "ls")          ss -tln | awk '{print $4}' | grep -o '[0-9]*$' | sort -nu | tr '\n' ' ' && echo;;
      "banned")      command -v jq &> /dev/null && fail2ban-client banned | sed "s/'/\"/g" | jq -r '.[0].sshd[]' || fail2ban-client banned;;
      "unban")       fail2ban-client unban "$2";;
      "stat")        [ -n "$2" ] &&  netstat -nlptx | grep "$2" || netstat -nlpt;; 
      "server")      [ -n "$2" ] && _net_server "$2" || _net_server "6789";;
      "ip")          echo -e "\n$(tput setaf 6)EXTERNAL IP $(tput sgr0) $(curl -s ifconfig.me)\n\n$(tput setaf 6)LOCAL IP \n $(ip -c -br a)\n";;
      "ciphers")     nmap --script ssl-enum-ciphers -p 443 "$2";;
      "expssl")      echo | openssl s_client -servername $1 -connect $2:443 2>/dev/null | openssl x509 -noout -enddate;;
      "status")      [ $# -ge 3 ] && nc -zv $2 $3;;
      "get")         [ -n "$2" ] && _net_get "$2";;
      "exec")        _net_exec "${@:2}";;
      "rand")        [ -n "$2" ] && openssl rand -base64 "$2" || openssl rand -base64 9;;
      *)             _net_help "$FUNCNAME";; 
    esac 
  else
    _net_help "$FUNCNAME";
  fi
};

_cf_help(){
 echo -e "\n~/.strong_aliases function. Cloudflare API Toolkit (curl,jq)\n
(CF_TOKEN environment variable is required)

Usage: 
  $1 token            <TOKEN>     :         Set OR show environment variable CF_TOKEN
  $1 short            [domains]   :  (curl) Show DNS records of domains (A,CNAME) 
  $1 full             [domains]   :  (curl) Show DNS records of domains (full json)
  $1 create [IP]      [domains]   :  (curl) Create records for domains (A,CNAME www)
  $1 a      [IP]      [domains]   :  (curl) Edit A record for domains
  $1 attack [on|off]  [domains]   :  (curl) Turning on Under Attack Mode for domains
 
Example:
  CF_TOKEN=\"ssssss-ddddd_fff\"
  $1 token \"ssssss-ddddd_fff\"
  $1 short \"site1.com site2.com site3.com\"
  $1 create \"1.2.3.4\" \"site.com\"
  $1 A \"1.2.3.4\" \"site.com\"


";};
_cf_short(){
SITES=$1;
for DOMAIN in $SITES; do
    echo -e "\n";
    ZONE_ID=$(curl -s -X GET "$CF_API_URL/zones?name=$DOMAIN" -H "Authorization: Bearer $CF_TOKEN" -H "Content-Type: application/json" | jq -r '.result[0].id')
    curl -s -X GET "$CF_API_URL/zones/$ZONE_ID/dns_records" -H "Authorization: Bearer $CF_TOKEN" -H "Content-Type: application/json" |  jq -r '.result[] | "\(.name) \(.type) \(.content)"'
done
};
_cf_full(){
SITES=$1;
for DOMAIN in $SITES; do
    echo -e "\n";
    ZONE_ID=$(curl -s -X GET "$API_URL/zones?name=$DOMAIN" -H "Authorization: Bearer $CF_TOKEN" -H "Content-Type: application/json" | jq -r '.result[0].id')
    curl -s -X GET "$API_URL/zones/$ZONE_ID/dns_records" -H "Authorization: Bearer $CF_TOKEN" -H "Content-Type: application/json" |  jq -r '.result[]'
done
};
_cf_create() {
  CF_NEW_IP=$1
  SITES=$2

  for DOMAIN in $SITES; do
    ZONE_ID=$(curl -s -X GET "$CF_API_URL/zones?name=$DOMAIN" \
      -H "Authorization: Bearer $CF_TOKEN" \
      -H "Content-Type: application/json" | jq -r '.result[0].id')

    echo "DOMAIN: $DOMAIN  ZONE_ID = $ZONE_ID"

    # Создание A-записи
    curl -s -X POST "$CF_API_URL/zones/$ZONE_ID/dns_records" \
      -H "Authorization: Bearer $CF_TOKEN" \
      -H "Content-Type: application/json" \
      --data "$(cat <<EOF
{
  "type": "A",
  "name": "@",
  "content": "$CF_NEW_IP",
  "ttl": 1,
  "proxied": true
}
EOF
)"

    # Создание CNAME-записи
    curl -s -X POST "$CF_API_URL/zones/$ZONE_ID/dns_records" \
      -H "Authorization: Bearer $CF_TOKEN" \
      -H "Content-Type: application/json" \
      --data "$(cat <<EOF
{
  "type": "CNAME",
  "name": "www",
  "content": "@",
  "ttl": 1,
  "proxied": true
}
EOF
)"

    # Вывод всех DNS-записей
    curl -s -X GET "$CF_API_URL/zones/$ZONE_ID/dns_records" \
      -H "Authorization: Bearer $CF_TOKEN" \
      -H "Content-Type: application/json" |
      jq -r '.result[] | "\(.name) \(.type) \(.content)"'

  done
}
_cf_a() {
  CF_NEW_IP=$1
  SITES=$2
for DOMAIN in $SITES; do
  ZONE_ID=$(curl -s -X GET "$API_URL/zones?name=$DOMAIN" -H "Authorization: Bearer $CF_TOKEN" -H "Content-Type: application/json" | jq -r '.result[0].id')
  echo "DOMAIN: $DOMAIN  ZONE_ID = $ZONE_ID"
  RECORD_ID=$(curl -s -X GET "$API_URL/zones/$ZONE_ID/dns_records?type=A&name=$DOMAIN" -H "Authorization: Bearer $CF_TOKEN" -H "Content-Type: application/json" | jq -r '.result[0].id')
  echo "RECORD_ID = $RECORD_ID"
  curl -s -X PUT "$API_URL/zones/$ZONE_ID/dns_records/$RECORD_ID" -H "Authorization: Bearer $CF_TOKEN" -H "Content-Type: application/json" \
  --data "{
    \"type\": \"A\",
    \"name\": \"$DOMAIN\",
    \"content\": \"$CF_NEW_IP\",
    \"proxied\": true
  }" | jq
done
}
_cf_token() {
  if [ $# -eq 0 ]; then
    if [ -n "$CF_TOKEN" ]; then
      echo -e "Cloudflare Token: $CF_TOKEN\n"
      curl -s -X GET "https://api.cloudflare.com/client/v4/zones" \
        -H "Authorization: Bearer $CF_TOKEN" \
        -H "Content-Type: application/json" \
        | jq -r '.result[0].account | {id, name}'
    else
      echo -e "Usage: cf token \"ssssss-ddddd_fff\"\n"
    fi
  elif [ $# -eq 1 ]; then
    export CF_TOKEN="$1"
    echo -e "Cloudflare Token: $CF_TOKEN\n"
    curl -s -X GET "https://api.cloudflare.com/client/v4/zones" \
        -H "Authorization: Bearer $CF_TOKEN" \
        -H "Content-Type: application/json" \
        | jq -r '.result[0].account | {id, name}'
  else
    echo -e "Usage: cf token\n"
  fi
}
_cf_attack() {
CF_ATTACK_MODE=$1;
SITES=$2;
}

cf(){
  if [ -n "$1" ]; then
    case "$1" in
      "token")       [ -n "$2" ] && _cf_token "$2" || _cf_token;;
      "attack")      [ -n "$3" ] && _cf_attack "$2" "$3";;
      "notes")        _cf_notes;;
      "short")       [ -n "$2" ] && _cf_short "$2";;
      "full")        [ -n "$2" ] && _cf_full "$2";;
      "create")      [ -n "$3" ] && _cf_create "$2" "$3";;
      "A"|"a")       [ -n "$3" ] && _cf_a "$2" "$3";;
      *)             _cf_help "$FUNCNAME";; 
    esac 
  else
    _cf_help "$FUNCNAME";
  fi
};

_ngx_help() { echo -e "
~/.strong_aliases Nginx Toolkit.

 Usage:
  $1 [sites|logs|ssl]       : (grep)      grep keywords in /etc/nginx
  $1 live LOG               : (watch)     show TOP15 last unique IPs live
  $1 build                  : (nginx)     configure options list
  $1 reload                 : (nginx)     test configuration && reload
  $1 vars DOMAIN ROOT       : (curl)      show PHP print_r(\$_SERVER)
  $1 make dhparam           : (openssl)   make to ./dhparam.pem dhparam
  $1 make certkey           : (openssl)   make to ./cert.pem self-signed cert + key 

 Examples:
  $1 -V  OR   $1 build | grep ip 
  $1 -t  &&  $1 -s reload 
  $1 vars domain.com /var/www 
  
"; }; 
_ngx_select() { echo "awk '{print \"\033[1;36m\"\$1\"\033[0m\", \"\033[1;31m\"\$$1\"\033[0m\"}'"; }; 
_ngx_grep() { echo; grep --include=*.conf -iRnE $1 /etc/nginx | grep -E 'enabled|-sites' | grep -vE 'pool_manager|server_status|rtc-server' | eval $(_ngx_select $2); echo; }; 
_ngx_make(){ 
  if [ -n "$1" ]; then
    case "$1" in
      "dhparam") openssl dhparam -out dhparam.pem 2048  && echo -e "\n ssl_dhparam $(pwd)/dhparam.pem;\n";;
      "certkey") openssl req -x509 -batch -nodes -days 3650 -newkey rsa:2048 -keyout cert.pem -out cert.pem && echo -e "\n ssl_certificate $(pwd)/cert.pem;\n ssl_certificate_key $(pwd)/cert.pem;\n";;
      *) ;; 
    esac
  else
    echo "Make a choice.. Usage: ngx help "
  fi
};
_ngx_vars(){
  ACTION="$1"
  SITE_DOMAIN="$2"
  SITE_ROOT_PATH="$3"

  case "$ACTION" in
      on)
          SITE_OWNER=$(stat -c %U "$SITE_ROOT_PATH")
          PHP_VARS="HOSTNAME|SCRIPT_URI|HTTP_HOST|SERVER_NAME|SERVER_ADDR|SERVER_PORT|REMOTE_ADDR"
          echo '<?php print_r($_SERVER); ?>' > "$SITE_ROOT_PATH/global56789.php"
          chown "$SITE_OWNER:$SITE_OWNER" "$SITE_ROOT_PATH/global56789.php"
          echo -e "\n$(tput setaf 6)curl -skL https://$SITE_DOMAIN/global56789.php | grep -E \"$PHP_VARS\"$(tput sgr0)\n"
          curl -skL "https://$SITE_DOMAIN/global56789.php" | grep -E "$PHP_VARS"
          echo -e "\nrm -rf $SITE_ROOT_PATH/global56789.php\n"
          ;;
      off)
          rm -f "$SITE_ROOT_PATH/global56789.php"
          unset SITE_ROOT_PATH SITE_DOMAIN SITE_OWNER PHP_VARS
          ;;
      *)
          echo "Usage: check_site {on|off} <site_domain> <site_root_path>"
          return 1
          ;;
    esac
};
ngx(){
  if [ -n "$1" ]; then
    case "$1" in
      "live")         watch -d "tail -n 1000 $2 | awk '{print \$1}' | sort | uniq -c | sort -nr | head -n 15";;
      "sites")       _ngx_grep 'set\s+\$docroot|set\s+\$root_path|root\s+\/' "4";;
      "logs")        _ngx_grep "access_log|error_log" "3";;
      "ssl")         _ngx_grep 'ssl_cert' "2";;
      "build")       nginx -V 2>&1 | grep 'configure' | sed 's/--/\n--/g';;
      "reload")      nginx -t && nginx -s reload;;
      "make")        [ "$#" -ge 2 ] && _ngx_make $2;;
      "vars")        [ "$#" -ge 3 ] && _ngx_vars "on" $2 $3;;
      "help")        _ngx_help $FUNCNAME;;
      *)             _title "Usage: $FUNCNAME help" && nginx "$@";;
    esac
  else
    _ngx_help $FUNCNAME;
  fi
}

_sql_variables(){ mysql -e "SELECT 'innodb_buffer_pool_size' AS variable, ROUND(@@innodb_buffer_pool_size / (1024 * 1024), 2) AS value UNION SELECT 'max_connections' AS variable, @@max_connections AS value UNION SELECT 'query_cache_type' AS variable, @@query_cache_type AS value UNION SELECT 'query_cache_size' AS variable, ROUND(@@query_cache_size / (1024 * 1024), 2) AS value UNION SELECT 'query_cache_limit' AS variable, ROUND(@@query_cache_limit / (1024 * 1024), 2) AS value UNION SELECT 'table_open_cache' AS variable, @@table_open_cache AS value UNION SELECT 'thread_cache_size' AS variable, @@thread_cache_size AS value UNION SELECT 'max_heap_table_size' AS variable, ROUND(@@max_heap_table_size / (1024 * 1024), 2) AS value UNION SELECT 'tmp_table_size' AS variable, ROUND(@@tmp_table_size / (1024 * 1024), 2) AS value UNION SELECT 'key_buffer_size' AS variable, ROUND(@@key_buffer_size / (1024 * 1024), 2) AS value UNION SELECT 'join_buffer_size' AS variable, ROUND(@@join_buffer_size / (1024 * 1024), 2) AS value UNION SELECT 'sort_buffer_size' AS variable, ROUND(@@sort_buffer_size / (1024 * 1024), 2) AS value UNION SELECT 'bulk_insert_buffer_size' AS variable, ROUND(@@bulk_insert_buffer_size / (1024 * 1024), 2) AS value UNION SELECT 'myisam_sort_buffer_size' AS variable, ROUND(@@myisam_sort_buffer_size / (1024 * 1024), 2) AS value;";};
_sql_memory(){ IDS=($(find "/proc/$(ps aux | grep $1 | grep -v grep | awk '{print $2}')/task" -maxdepth 1 -type d ! -name 'task' -exec basename {} \;)); MEMORY=0; for ID in "${IDS[@]}"; do MEMORY=$(expr $(ps -o rss= -p $ID) + $MEMORY); done; echo $((MEMORY / 1024)); }; 
_sql_dbsize(){ mysql -e 'SELECT table_schema AS `Database`, ROUND(SUM(data_length + index_length) / 1024 / 1024) AS `Size (MB)` FROM information_schema.tables GROUP BY table_schema HAVING `Size (MB)` >= 0 UNION SELECT schema_name AS `Database`, 0 AS `Size (MB)` FROM information_schema.schemata WHERE schema_name NOT IN (SELECT table_schema FROM information_schema.tables) ORDER BY `Size (MB)` DESC;'; }; 
_sql_tables(){ mysql -e "SELECT table_name, COUNT(*) AS row_count FROM information_schema.tables WHERE table_schema = '$1' GROUP BY table_name ORDER BY row_count ASC;"; }; 
_sql_makezabbix(){ PASSWORD=$(openssl rand -base64 12); mysql -e "DROP USER IF EXISTS 'zabbix'@'localhost'; DROP USER IF EXISTS 'zabbix'@'127.0.0.1'; CREATE USER 'zabbix'@'localhost' IDENTIFIED BY '$PASSWORD';CREATE USER 'zabbix'@'127.0.0.1' IDENTIFIED BY '$PASSWORD'; GRANT ALL ON *.* TO 'zabbix'@'localhost';GRANT ALL ON *.* TO 'zabbix'@'127.0.0.1';flush privileges;"; mkdir -p /etc/zabbix; echo -e "[client]\nuser=zabbix\npassword=$PASSWORD" > /etc/zabbix/.my.cnf;cat /etc/zabbix/.my.cnf; };
_sql_makebareos(){ PASSWORD=$(openssl rand -base64 12); mysql -e "DROP USER IF EXISTS 'bareos'@'localhost'; CREATE USER 'bareos'@'localhost' IDENTIFIED BY '$PASSWORD'; GRANT USAGE ON *.* TO 'bareos'@'localhost'; GRANT SELECT, LOCK TABLES, SHOW VIEW, EVENT, PROCESS, EXECUTE, TRIGGER ON *.* TO 'bareos'@'localhost'; FLUSH PRIVILEGES;"; echo -e "[client]\nusername=bareos\npassword=$PASSWORD" > /root/.bareos.cnf;cat /root/.bareos.cnf; };

_sql_help(){ echo "
~/.strong_aliases function. Mysql Toolkit (mysql, mysqldump).

Usage:
 $1 memory                  : show RAM Mysql usage
 $1 variables               : show Mysql variables
 $1 bases                   : show databases with size
 $1 create [dbname]         : create database
 $1 base   [dbname]         : show database owners
 $1 tables [dbname]         : show database tables 
 $1 drop   [dbname]         : drop database 
 $1 dump   [dbname]         : dump database to this directory on \"[dbname].sql\"
 $1 copy   [dbname] [newdb] : create database \"newdb\" + copy database \"dbname\" to \"newdb\" 
  
 $1 users                                        : show users
 $1 makeowner  [user]<@host> [password] [dbname] : create user + grant all privileges on the db
 $1 makereader [user]<@host> [password] [dbname] : create user + grant select         on the db
 $1 user       [user]<@host>                     : show user grants 
 $1 password   [user]<@host> [password]          : reset user password
 $1 dropuser   [user]<@host>                     : drop user
 
 $1 makezabbix  : create mysql zabbix user + write access to /etc/zabbix/.my.cnf
 $1 makebareos  : create mysql bareos user + write access to /root/.bareos.cnf
 $1 tuning      : running a script from the repository https://github.com/BMDan/tuning-primer.sh

 "; };

# $1 createuser  [user]@host [password]           : create user
# $1 grantall    [user]@host [dbname]             : grant all privileges to the user on the db 

sql(){
  MESSAGE_CAPTCHA="WARNING!!! Enter \"DROP\" to drop database: ";
  if ! mysql -e "SELECT 1;" &>/dev/null; then
    echo "Password required, file /root/.my.cnf may not be found. Using the function in this mode is not possible."
  else
    if [ $# -eq 0 ]; then
        _sql_help $FUNCNAME;
    else
      case "$1" in
      "memory")    echo -e "\nUsage RAM: $(_sql_memory "mysql") (mb)\n";;
      "bases")     _sql_dbsize;;
      "create")    [ -n "$2" ] && mysql -e "CREATE DATABASE $2;";;
      "base")      [ -n "$2" ] && mysql -e "SELECT user, host, db FROM mysql.db WHERE db = '$2';";;
      "tables")    _sql_tables "$2";;
      "variables") _sql_variables;;
      "drop")   [ -n "$2" ] && read -p "$MESSAGE_CAPTCHA" captcha && [ "$captcha" = "DROP" ] && mysql -e "DROP DATABASE $2;" && sql bases || echo "FALSE";;
      "dump")     [ -n "$2" ] && mysqldump "$2" > "$2.sql";;
      "copy")     [ $# -ge 3 ] && mysql -e "CREATE DATABASE $3;"; mysqldump "$2" | mysql "$3";;
      "users")  mysql -e "SELECT USER,Host FROM mysql.user;";;
      "makeowner")  [ $# -ge 4 ] && mysql -e "CREATE USER $2 IDENTIFIED BY '$3';GRANT ALL PRIVILEGES ON $4 . * TO $2;FLUSH PRIVILEGES;";;
      "makereader") [ $# -ge 4 ] && mysql -e "CREATE USER $2 IDENTIFIED BY '$3';GRANT SELECT ON $4 . * TO $2;FLUSH PRIVILEGES;";;
      #"createuser") [ $# -ge 3 ] && mysql -e "CREATE USER $2 IDENTIFIED BY '$3';";;
      #"grantall") [ $# -ge 3 ] && mysql -e "GRANT ALL PRIVILEGES ON $3 . * TO $2;FLUSH PRIVILEGES;";;
      "user")     [ -n "$2" ] && mysql -e "SHOW GRANTS FOR $2;";;
      "password") [ -n "$2" ] && mysql -e "ALTER USER $2 IDENTIFIED BY '$3';";;
      "dropuser") [ -n "$2" ] && mysql -e "DROP USER $2;";;
      "tuning")   curl -L $MYSQL_TUNING_URL | bash;;
      "makezabbix") _sql_makezabbix;;
      "makebareos") _sql_makebareos;;
      "help")     _sql_help $FUNCNAME;;
      *)          _title "Usage: $FUNCNAME help" && mysql "$@";;
      esac
    fi
  fi
};


_dcr_run(){ 
  if [ -n "$1" ]; then
    case "$1" in
      "portainer") docker version;;
      *) ;; 
    esac
  else
    _title "Make a choice.. Usage: doc help ";
  fi
};
_dcr_uninstall(){  apt-get purge docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras;rm -rf /var/lib/docker; rm -rf /var/lib/containerd; rm /etc/apt/sources.list.d/docker.list;rm /etc/apt/keyrings/docker.asc;};
_dcr_help() { echo -e "
~/.strong_aliases Docker Toolkit.

 Usage:
  $1 all                 :   (docker) container ls -a
  $1 ls                  :   (docker) container ls
  $1 scan [path]         :   (find) (docker-compose|compose).(yml|yaml) in the [path]
  $1 open [container]    :   (docker) exec -it [container] bash
  $1 up                  :   (docker-compose) build && up -d
  $1 down                :   (docker-compose) down -v
  $1 volume              :   (docker volume ls)
  $1 net                 :   (docker network ls)
  
  $1 install             :   (curl) curl -fsSL https://get.docker.com | bash
  $1 uninstall           :   Uninstall Docker Engine, all images, repository 
  
 Usage original docker options:
  $1 version
"; }; 
  #$1 run portainer       :   (docker-compose) download portainer yml to /data/portainer and run

dcr(){
  if [ $# -eq 0 ]; then
      _dcr_help $FUNCNAME;
  else
    case "$1" in
     "all") docker container ls -a;;
     "ls") docker container ls;;
     "scan") [ -n "$2" ] && (find "$2" -type f \( -name "docker-compose.yml" -o -name "docker-compose.yaml" -o -name "compose.yml" -o -name "compose.yaml" \) -exec realpath '{}' \; );; 
     "open")  [ -n "$2" ] && docker exec -it $2 bash;;
     "up") docker-compose build && docker-compose up -d;;
     "down") docker-compose down -v;;
     "volume") docker volume ls;;
     "net") docker network ls;;
     "install") curl -fsSL https://get.docker.com | bash;;
     "uninstall")     _dcr_uninstall;;
     #"run")   [ "$#" -ge 2 ] && _dcr_run $2;;
     "help")     _dcr_help $FUNCNAME;;
     *)          docker "$@";;
    esac
  fi
};



