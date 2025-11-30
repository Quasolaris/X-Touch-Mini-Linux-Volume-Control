#!/bin/bash
declare -a knob_ids=(KNOB1 KNOB2 KNOB3 KNOB4 KNOB5 KNOB6 KNOB7 KNOB8)
declare -a knob_apps=(APP1 APP2 APP3 APP4 APP5 APP6 APP7 APP8)


# Initialize an associative array that will hold the values.
declare -A values
for name in "${knob_ids[@]}"; do
    values["$name"]=''   # start empty
done
count_missing() {
    local cnt=0
    for name in "${knob_ids[@]}"; do
        [[ -z "${values[$name]}" ]] && ((cnt++))
    done
    echo "$cnt"
}

printconfiguration(){
  # clear terminal and print header with configuration
  clear

  echo "=================================================================="
  printf "  \e[31mX-Touch MINI \e[36mLinux \e[32mVolume Control\e[0m\n"
  echo "=================================================================="
  printf '\t    ID \t\t Volume \t Application'
  echo
  for name in "${knob_ids[@]}"; do
      id="${!name}"

      if [[ -n $id ]] then
        appName=$(wpctl status | grep "${id}\." | sed 's/[0-9|\.]*//g' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | tr -d $'\t' 2>/dev/null)
        volume=$(wpctl get-volume $id | tr -d $'\t' | sed 's/[a-Z|:]*//g' 2>/dev/null)
        printf '  %-4s =  \e[32m %s \e[0m \t %s \t\t\e[36m %s \e[0m\n' "$name" "${!name}" "$volume" "$appName"
      else
        printf '  %-4s = %s \e[31m %s \e[0m \n' "$name" "${!name}" "NOT SET"
      fi
  done

  echo 
  echo
  echo "========================================================="
  echo " Outputs"
  echo "========================================================="

  if [[ -n $output1 && -n $output2 ]] then

    outputString=$(wpctl status | grep "${output1}\." 2>/dev/null)
    if [[ $outputString == *"│  * "* ]]; then
      printf "OUTPUT 1: \e[32m ${outputString}\n\e[0m\n\t $(wpctl get-volume $output1)\n"
      echo "-----------------------------------------------------"
      outputString=$(wpctl status | grep "${output2}\." 2>/dev/null)
      printf "OUTPUT 2: ${outputString}\n\n\t $(wpctl get-volume $output2)\n"
      echo "-----------------------------------------------------"
    else
      outputString=$(wpctl status | grep "${output1}\." 2>/dev/null)
      printf "OUTPUT 1: ${outputString}\n\n\t $(wpctl get-volume $output1)\n"
      echo "-----------------------------------------------------"
      outputString=$(wpctl status | grep "${output2}\." 2>/dev/null)
      printf "OUTPUT 2: \e[32m${outputString}\n\e[0m\n\t $(wpctl get-volume $output2)\n"
      echo "-----------------------------------------------------"
    fi
  else
    echo "No Outputs set"
  fi

}

echo "================================="
printf "\e[31mX-Touch MINI \e[36mLinux \e[32mVolume Control\e[0m\n"
echo "================================="

filledAppliactions=0

echo "------------------------------------------"
echo "Set Applications Audio Streams to control"
echo "------------------------------------------"

echo
# printing out streams to control
wpctl status | sed -n '/Streams:/,/Video/p; /Video/q'

echo
echo "To add application enter the ID (ex. 134. Strawberry -> 134 is the ID)"
echo "To stop filling applications just hit enter without a value entered"
echo

lastKnob=""
# asking user to fill in streams (applications)
while (( $(count_missing) > 0 )); do
    if [[ $filledAppliactions > 0 ]]; then
      break 
    fi

    # Iterate over the variables that are still empty
    for name in "${knob_ids[@]}"; do
        # Skip ones we already have
        [[ -n "${values[$name]}" ]] && continue

        read -rp "Enter value for $name: " input

        # Reject empty input (pressing Enter without typing)
        if [[ -z "$input" ]]; then
            printf "\e[31m  → Nothing entered – Stopping application collection\e[0m\n"
            filledAppliactions=1
            lastKnob=$name
            break
        fi

        # Store the accepted value
        values["$name"]="$input"
        echo "  → $name set."
    done
    echo   # blank line for readability
done

# fill in input to variables 
for name in "${knob_ids[@]}"; do
    declare "$name=${values[$name]}"
done


index=1
# filling in applications and stream ids for user orientation
for name in "${knob_apps[@]}"; do
  
  indexSTR="KNOB${index}"
  appID=${values[$indexSTR]}
  
  if [[ -n $appID ]]; then
    appName=$(wpctl status | grep "${appID}\." | sed 's/[0-9|\.]*//g' 2>/dev/null)
  #echo "APPNAME: ${appName}"
    declare "$name=${appName}"
  fi

  index=$((index+1))
done

echo
echo "---------------------------------------------------------------------"
echo "Choose Output IDs for switching (if not needed press enter, two times)"
echo "---------------------------------------------------------------------"
echo
wpctl status | sed -n '/Sinks:/,/Sources:/p; /Sources/q'

read -p "Enter ID of OUTPUT 1: " output1
read -p "Enter ID of OUTPUT 2: " output2

# used for setting output
outputFlip=0

printconfiguration

aseqdump -p  "X-TOUCH MINI" |
{
# mapping of variables
# Header:     Source  Event               Ch  Data
# Fields:     20:0    Control change      0,  controller 11,      value   32
# Variables:  src     ev1     ev2         ch  label1     ctrl_no  label2  ctrl_value

  read
  read
  while IFS=" ," read src ev1 ev2 ch label1 ctrl_no label2 ctrl_value rest
  do
    case $ctrl_no in

      # Knob 1
      1) 
        vol=$(awk -v v="$ctrl_value" 'BEGIN{printf "%.2f", v/127}')
        wpctl set-volume $KNOB1 $vol
        printconfiguration;;


      # Knob 2
      2) 
        vol=$(awk -v v="$ctrl_value" 'BEGIN{printf "%.2f", v/127}')
        wpctl set-volume $KNOB2 $vol
        printconfiguration;;


      # Knob 3
      3) 
        vol=$(awk -v v="$ctrl_value" 'BEGIN{printf "%.2f", v/127}')
        wpctl set-volume $KNOB3 $vol
        printconfiguration;;

      # Knob 4
      4) 
        vol=$(awk -v v="$ctrl_value" 'BEGIN{printf "%.2f", v/127}')
        wpctl set-volume $KNOB3 $vol
        printconfiguration;;

      # Knob 5
      5) 
        vol=$(awk -v v="$ctrl_value" 'BEGIN{printf "%.2f", v/127}')
        wpctl set-volume $KNOB3 $vol
        printconfiguration;;


      # Knob 6
      6) 
        vol=$(awk -v v="$ctrl_value" 'BEGIN{printf "%.2f", v/127}')
        wpctl set-volume $KNOB3 $vol
        printconfiguration;;


      # Knob 7
      7) 
        vol=$(awk -v v="$ctrl_value" 'BEGIN{printf "%.2f", v/127}')
        wpctl set-volume $KNOB3 $vol
        printconfiguration;;


      # Knob 8
      8) 
        vol=$(awk -v v="$ctrl_value" 'BEGIN{printf "%.2f", v/127}')
        wpctl set-volume $KNOB3 $vol
        printconfiguration;;


      # fader
      9)
        vol=$(awk -v v="$ctrl_value" 'BEGIN{printf "%.2f", v/127*100}')  
        wpctl set-volume @DEFAULT_AUDIO_SINK@ "${vol}%"
        printconfiguration;;

      # << button
      18) 
        if (( $ctrl_value == "127" )); 
          then playerctl previous
        fi
        ;;

        # >> button
      19) 
        if (( $ctrl_value == "127" )); 
          then playerctl next
        fi
        ;;

        # stop button
      21) 
        if (( $ctrl_value == "127" )); 
          then playerctl stop
        fi
        ;;

        # play button
      22) 
        if (( $ctrl_value == "127" )); 
          then playerctl play
        fi
        ;;

      # reset terminal and redraw configuration
      23) 
        if (( $ctrl_value == "127" )); 
          then printconfiguration
        fi
        ;;

      # switch output
      16)
        if (( $ctrl_value == "127" )); then 
          if (( $outputFlip == "1" )); 
            then 
              wpctl set-default $output1
              printconfiguration
              outputFlip=0
          else
              wpctl set-default $output2
              printconfiguration
              outputFlip=1
          fi
        fi
        ;;
      
      *) echo "Unknown Input";;
    esac
  done
}
