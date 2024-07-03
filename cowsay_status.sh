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
COWSAY_FILE=~/Programs/pomo_termux/tutoro.cow

# ╒══════════════════════════════════════════════════════════╕
#                            Setups
# ╘══════════════════════════════════════════════════════════╛

# cleanup -> Add cursor back
function cleanup() {
    tput cnorm
}

function init_tgui() {
    clear
    toilet -f ivrit --gay "Pomo"
    echo "Current task: "
    echo "----------------"
    echo "  $1"
    echo -e "\n\n\n\n"

    # Hide cursor on exit
    trap cleanup EXIT
    tput civis
}

# ╒══════════════════════════════════════════════════════════╕
#                      Utility functions
# ╘══════════════════════════════════════════════════════════╛

function notify() {
    termux-notification -t "Pomodoro" -c "$1" --prio high
    termux-tts-speak "$1"
    termux-vibrate -d 1000
}

function exit_pomodoro() {
    notify "Exiting pomodoro"
    $PATH_TO_POMO_SCRIPT stop

    clear
    exit
}

function get_current_status() {
  if [ "$1" == "W" ]; then
    echo "Work "
  elif [ "$1" == "B" ]; then
    echo "Break"
  else
    echo "Unknown status: $short_status"
  fi


}

# ╒══════════════════════════════════════════════════════════╕
#                          Main Loop
# ╘══════════════════════════════════════════════════════════╛
counter_seconds=0
counter_pomodoros=0
old_short_status="W"

$PATH_TO_POMO_SCRIPT start
notify "Starting pomodoro for task $TASK"

init_tgui "$TASK"

while true; do

  # Redraw the whole screen every 30 seconds
  counter_seconds=$((counter_seconds+1))
  if [ $counter_seconds -eq 30 ]; then
    init_tgui "$TASK"
    counter_seconds=0
  fi

  pomodoro_clock=$($PATH_TO_POMO_SCRIPT clock)
  short_status="${pomodoro_clock:1:1}"
  time_left="${pomodoro_clock:2:6}"

  current_status=$(get_current_status "$short_status")

  # Save cursor position
  tput sc

  # Main output
  echo -e "Status: $current_status \n"
  echo "$time_left" | cowsay -f $COWSAY_FILE

  # Restore cursor position -> Redraws only one line
  tput rc

  sleep 1


  # When the break is over new cycle starts
  if [ "$short_status" == "W" ] && [ "$old_short_status" == "B" ]; then
    notify "The Break is over, select a new task"

    counter_pomodoros=$((counter_pomodoros+1))
    # Break every 4 pomodoros
    if [ $counter_pomodoros -eq 4 ]; then
        notify "Long break starts now. Bye!"
        termux-vibrate -d 1000
        exit_pomodoro
    fi

    clear

    while true; do
        notify "Select a new task"
        cleanup

        read -sp "Select new Task: " TASK
        if [ -z "$TASK" ]; then
            echo "Task cannot be empty"
        else
            break
        fi
    done

    notify "Starting pomodoro for task $TASK"
    init_tgui "$TASK"


  fi

  if [ "$short_status" != "$old_short_status" ]; then
    termux-toast "Status changed to $current_status"
    notify "Status changed to $current_status"
    termux-vibrate -d 1000
    old_short_status=$short_status

  fi

done


