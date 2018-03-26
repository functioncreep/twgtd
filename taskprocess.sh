#!/bin/bash

# GTD inbox processing in Taskwarrior

# Function to draw boxes around lines of text:
function boxdraw {
  if [ -z $1 ]; then
    echo "No text to draw box around!"
  else
    INNER_TEXT=$1
    INNER_TEXT_LENGTH=${#INNER_TEXT}
    TOP_BOTTOM_EDGE="+-"

    for (( i=0; i<=$INNER_TEXT_LENGTH; i++ )); do
      TOP_BOTTOM_EDGE+="-"
    done

    TOP_BOTTOM_EDGE+="+"
    echo $TOP_BOTTOM_EDGE
    echo "| $INNER_TEXT |"
    echo $TOP_BOTTOM_EDGE
  fi
}

# get task uuids from inbox
INBOX_UUIDS=$( task uuids +in status.not:deleted status:pending )
# split resulting string into array
IFS=" " read -r -a INBOX <<< "$INBOX_UUIDS"
# get array length
INBOX_LENGTH=${#INBOX[*]}

ATTEMPTS=0
while [[ $ATTEMPTS -lt 10 ]]; do
  echo "You have $INBOX_LENGTH tasks in your inbox to process."
  read -p "Should I go ahead? (Y/N): " response
  echo;

  if [[ $response == "y" ]]; then
    for (( i=0; i<$INBOX_LENGTH; i++ )); do
      # get task description
      TASK_DESCRIPTION=$( task _get  ${INBOX[$i]}.description )
      TASK_HEADING="Task $(($i+1)): \e[93m$TASK_DESCRIPTION\e[0m"
      # XXX: DEPENDENCY ---> boxes
      # XXX: boxes has some weird indentation going on, on the right side...
      boxdraw "$TASK_HEADING"
      echo

      if (( $i < $INBOX_LENGTH-1 )); then
        read -n 1 -s -p "Press any key for the next task..." key
        echo
        echo
      else
        break
      fi
    done
    exit 1
  elif [[ $response == "n" || $response == "N" ]]; then
    echo "Okay, bye for now."
    exit 1
  else
    echo "...I'm sorry, I didn't understand that. Could you just give me a 'y' or 'n'?"
    echo
    ((ATTEMPTS++))
    continue
  fi
done
echo "You're clearly having some trouble typing... Seeya later."
