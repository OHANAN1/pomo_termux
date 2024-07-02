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
counter=0

while true; do

  pomodoro_clock=$($PATH_TO_POMO_SCRIPT clock)
  status="${pomodoro_clock:1:1}"
  time_left="${pomodoro_clock:2:6}"

  # Save cursor position
  tput sc

  # Main output
  if [ "$status" == "W" ]; then
    echo "Work "
  elif [ "$status" == "B" ]; then
    echo "Break"
  else
    echo "Unknown status: $status"
  fi
  echo $time_left | cowsay

  # Restore cursor position -> Redraws only one line
  tput rc

  sleep 1

  # Redraw the whole screen every 30 seconds
  counter=$((counter+1))
  if [ $counter -eq 30 ]; then
    init_tgui
    counter=0
  fi

  if [ "$status" == "B" ]; then

    termux-toast "${1}"
    termux-vibrate -d 1000
    termux-tts-speak "${1}"
    termux-notification -t "Pomodoro" -c "${1}" --prio high

    clear

    break
  fi

done


