#!/bin/bash

# GTD inbox processing in Taskwarrior

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
      echo -e $TASK_HEADING | boxes -d stone
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
