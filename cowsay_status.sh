#!/bin/bash

if [ -z "$1" ]
then
    echo "----------------"
    echo "No task provided"
    echo "Usage: $0 <task>"
    exit
fi

TASK="$1"

function init_tgui() {
    clear
    toilet -f ivrit --gay "Pomo"
    echo "Current task: $TASK"
    echo -e "\n\n\n\n"
}
init_tgui



# Hide the cursor
function hide_cursor() {
    tput cnorm
}
trap hide_cursor EXIT


tput civis
bash ~/Programs/pomo_termux/pomo.sh status | while IFS= read -r line; do

  # Save cursor position
  tput sc

  echo "$line" | cowsay

  # Restore cursor position -> Redraws only one line
  tput rc

done
