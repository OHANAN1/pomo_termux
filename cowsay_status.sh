#!/bin/bash

clear

bash ~/Programs/pomo/pomo.sh status | while IFS= read -r line; do

  # Save cursor position
  tput sc

  echo "$line" | cowsay

  # Restore cursor position -> Redraws only one line
  tput rc

done
