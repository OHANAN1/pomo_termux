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
export POMO_WORK_TIME=25
export POMO_BREAK_TIME=5
POMOS_PER_CYCLE=4

# ╒══════════════════════════════════════════════════════════╕
#                      Utility functions
# ╘══════════════════════════════════════════════════════════╛

function cleanup() {
    tput cnorm
    clear
}

function init_tgui() {
    clear
    toilet -f ivrit --gay "Pomo"
    echo "Current task: "
    echo "----------------"
    echo "  $1"
    echo -e "\n\n\n\n"

    trap cleanup EXIT # Redraw cursor when exiting
    tput civis
}

function notify() {
    termux-vibrate -d 1000 &&
    termux-tts-speak "$1" &&
    termux-notification -t "Pomodoro" -c "$1" --prio high
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

function draw_status() {
  echo "Pomodoro: $counter_pomodoros / $POMOS_PER_CYCLE"
  echo -e "Status: $current_status \n"
  echo "$time_left" | cowthink -f $COWSAY_FILE
}

function select_task() {
    notify "Please select a new task."
    while true; do
        echo "Select a new task:"
        read -r TASK
        if [ -z "$TASK" ]; then
            echo "Task cannot be empty"
        else
            break
        fi
    done
}

function switch_from_break_to_work() {
    notify "The Break is over, select a new task"
    # Pause the timer so the user can select a new task
    $PATH_TO_POMO_SCRIPT pause

    cleanup
    select_task

    counter_pomodoros=$((counter_pomodoros+1))
    notify "Starting pomo cycle $counter_pomodoros for:$TASK"
    init_tgui "$TASK"
    # Restart the timer
    $PATH_TO_POMO_SCRIPT pause
}

function switch_from_work_to_break() {
    if [ $counter_pomodoros -eq "$POMOS_PER_CYCLE" ]; then
        notify "Long break starts now. Bye!"
        exit_pomodoro
    else
        notify "The work is over, take a short break"
    fi
}



# ╒══════════════════════════════════════════════════════════╕
#                          Main Loop
# ╘══════════════════════════════════════════════════════════╛
counter_seconds=0
counter_pomodoros=1
old_short_status="W"

select_task

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

  tput sc # Save cursor position
  draw_status
  tput rc # Restore cursor position -> Redraws only one line

  sleep 1
  
  if [ "$short_status" == "W" ] && [ "$old_short_status" == "B" ]; then
    switch_from_break_to_work
  elif [ "$short_status" == "B" ] && [ "$old_short_status" == "W" ]; then
    switch_from_work_to_break
  fi
  old_short_status=$short_status

done


