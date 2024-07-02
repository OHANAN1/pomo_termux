#!/bin/bash

if [ -z "$1" ]
then
    echo "----------------"
    echo "No task provided"
    echo "Usage: $0 <task>"
    exit
fi

# ╒══════════════════════════════════════════════════════════╕
#                           Variables
# ╘══════════════════════════════════════════════════════════╛
TASK="$1"
PATH_TO_POMO_SCRIPT=~/Programs/pomo_termux/pomo.sh

# ╒══════════════════════════════════════════════════════════╕
#                            Setups
# ╘══════════════════════════════════════════════════════════╛
function init_tgui() {
    clear
    echo -e "\n\n\n\n"
    toilet -f ivrit --gay "Pomo"
    echo "Current task: "
    echo "----------------"
    echo "  $TASK"
    echo -e "\n\n\n\n"
}
init_tgui

# Hide the cursor
function hide_cursor() {
    tput cnorm
}
trap hide_cursor EXIT
tput civis

# ╒══════════════════════════════════════════════════════════╕
#                          Main Loop
# ╘══════════════════════════════════════════════════════════╛
bash $PATH_TO_POMO_SCRIPT status | while IFS= read -r line; do
  # Save cursor position
  tput sc
  # Main output
  echo "$line" | cowsay
  # Restore cursor position -> Redraws only one line
  tput rc
done
