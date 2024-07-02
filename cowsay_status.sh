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

# Hide the cursor
function hide_cursor() {
    tput cnorm
}

function init_tgui() {
    clear
    echo -e "\n\n\n\n"
    toilet -f ivrit --gay "Pomo"
    echo "Current task: "
    echo "----------------"
    echo "  $TASK"
    echo -e "\n\n\n\n"

    # Hide cursor on exit
    trap hide_cursor EXIT
    tput civis
}


# ╒══════════════════════════════════════════════════════════╕
#                          Main Loop
# ╘══════════════════════════════════════════════════════════╛
counter=0
old_short_status="W"

$PATH_TO_POMO_SCRIPT start

init_tgui

while true; do

  pomodoro_clock=$($PATH_TO_POMO_SCRIPT clock)
  short_status="${pomodoro_clock:1:1}"
  time_left="${pomodoro_clock:2:6}"

  if [ "$short_status" == "W" ]; then
    current_status="Work "
  elif [ "$short_status" == "B" ]; then
    current_status="Break"
  else
    echo "Unknown status: $short_status"
  fi

  # Save cursor position
  tput sc

  # Main output
  echo "Status: $current_status"
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

  # Break script after break so new task can be set
  # Not final version yet, since this is hacky
  if [ "$short_status" == "W" ] && ["$old_short_status" == "B" ]; then
    termux-notification -t "Pomodoro" -c "Break over select new task" --prio high
    termux-tts-speak "Break over select new task"
    $PATH_TO_POMO_SCRIPT stop

    clear

    break
  fi

  if [ "$short_status" != "$old_short_status" ]; then
    termux-toast "Status changed to $current_status"
    termux-vibrate -d 1000
    termux-notification -t "Pomodoro" -c "Status changed to $current_status" --prio high
    termux-tts-speak "Status changed to $current_status"
  fi

  old_status=$current_status

done


