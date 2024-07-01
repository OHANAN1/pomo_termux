#!/bin/bash

function init_tgui() {
    clear
    toilet -f ivrit --gay "Pomo"
}
init_tgui

# Hide the cursor
function hide_cursor() {
    tput cnorm
}
trap hide_cursor EXIT

bash ~/Programs/pomo_termux/pomo.sh status | while IFS= read -r line; do

  # Save cursor position
  tput sc

  echo "$line" | cowsay

  # Restore cursor position -> Redraws only one line
  tput rc

done
