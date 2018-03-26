#!/bin/bash

# Test for box drawing Function

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

read -p "I wanna draw a box! Gimme some text: " text
boxdraw $text
