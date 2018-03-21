#!/bin/bash

# GTD inbox processing in Taskwarrior

# get task uuids from inbox
INBOX_UUIDS=$( task uuids +in status.not:deleted status:pending )
# split resulting string into array
IFS=" " read -r -a INBOX <<< "$INBOX_UUIDS"
# get array length
INBOX_LENGTH=${#INBOX[*]}

for (( i=0; i<$INBOX_LENGTH; i++ )); do
  # get task description
  TASK_DESCRIPTION=$( task _get  ${INBOX[$i]}.description 
  echo "Task $(($i+1)) Description: $TASK_DESCRIPTION"

  if (( $i < $INBOX_LENGTH-1 )); then
    read -n 1 -s -r -p "Press any key for the next task..." key
  else
    break
  fi
done
