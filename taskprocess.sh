#!/bin/bash

# GTD inbox processing in Taskwarrior

# Function to draw boxes around lines of text:
function boxdraw {
  if [[ -z $1 ]]; then
    echo "No text to draw box around!"
  else
    INNER_TEXT=$1
    # clean escape characters
    INNER_TEXT_CLEANED=$(echo -e $INNER_TEXT)
    INNER_TEXT_LENGTH=${#INNER_TEXT_CLEANED}
    TOP_BOTTOM_EDGE="+-"

    for (( i=0; i<=$INNER_TEXT_LENGTH; i++ )); do
      TOP_BOTTOM_EDGE+="-"
    done

    TOP_BOTTOM_EDGE+="+"
    echo $TOP_BOTTOM_EDGE
    echo -e "| \e[93m$INNER_TEXT\e[0m |"
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

  if [[ $response =~ [yY(yes|Yes|YES)] ]]; then
    for (( x=0; x<$INBOX_LENGTH; x++ )); do
      # get task description
      # TASK_DESCRIPTION=$( task _get  ${INBOX[$x]}.description )
      # TASK_HEADING="Task $(($x+1)): $TASK_DESCRIPTION"

      # create task action array and populate with task info
      declare -A task
      task['uuid']=${INBOX[$x]}
      task['id']=$( task _get  ${INBOX[$x]}.id )
      task['description']=$( task _get  ${INBOX[$x]}.description )
      task['heading']="Task $(($x+1)): ${task['description']}"

      boxdraw "${task['heading']}"
      echo

      # Begin task processing flow --------
      if (( $x < $INBOX_LENGTH-1 )); then
        read -p "Is this task actionable? (Y/N): " response
        echo
        
        case $response in
        [yY]*)

          task['actionable']=true

          boxdraw "${task['heading']}"
          echo
          read -p "Will it take more than 2 minutes? (Y/N): " response
          echo

          case $response in
          [yY]*)

            echo "Actionable task workflow goes here..."
            echo
            exit 1

          ;;
          [nN]*)

            echo "Good! So go do it! I'll start the task for you and wait until it's done..."
            echo
            task ${task['id']} start
            echo
            read -p "(Type 'complete' to let me know when the task is finished, or 'stop' to stop the task and return to processing)----> " response
            echo

            case $response in
            [complete]*)
              
              echo "Nice! I'll mark that task done."
              echo
              task ${task['id']} done
              echo
              echo "Next!"
              echo

            ;;
            [stop]*)

              echo "Ok, stopping that task..."
              echo
              task ${task['id']} stop
              echo
              exit 1

            ;;
            *)

              echo "...Sorry? I didn't understand that."
              echo
              exit 1

            ;;
            esac

          ;;
          *)

            echo "Wrong answah!"
            exit 1

          ;;
          esac

        ;;
        [nN]*)

          task['actionable']=false
          echo "You answered no!"
          echo
          exit 1

        ;;
        *)

          echo "...Uhh what?"
          echo
          exit 1

        ;;
        esac

      else
        break
      fi
      # End task processing flow --------

    done
    exit 1

  elif [[ $response =~ [nN(no|No|NO)] ]]; then
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
