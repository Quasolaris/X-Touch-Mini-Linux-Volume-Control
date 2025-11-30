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

printapplications(){
  clear
  echo "========================================================="
  echo "  Stream IDs under volume control per Knob"
  echo "========================================================="
  for name in "${knob_ids[@]}"; do
      printf '  %-4s = \e[31m %s \e[0m\n' "$name" "${!name}"
  done

  echo 
  echo
  echo "========================================================="
  echo "  Applications under volume control per Knob"
  echo "========================================================="
  for name in "${knob_apps[@]}"; do
      printf '  %-4s = \e[36m %s \e[0m \n' "$name" "${!name}"
      echo "-----------------------------------------------------"
  done
}

echo "================================="
printf "\e[31mX-Touch MINI \e[36mLinux \e[32mVolume Control\e[0m\n"
echo "================================="

filledAppliactions=0

echo "------------------------------------------"
echo "Set Applications Audio Streams to control"
echo "------------------------------------------"


# printing out streams to control
wpctl status | sed -n '/Streams:/,/Video/p; /Video/q'

echo
echo "To add application enter the ID (ex. 134. Strawberry -> 134 is the ID)"
echo "To stop filling applications just hit enter without a value entered"
echo

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

printapplications

aseqdump -p  "X-TOUCH MINI" |
{
  # Ignore first two output lines of aseqdump (info and header)
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
        wpctl set-volume $KNOB1 $vol;;

      # Knob 2
      2) 
        vol=$(awk -v v="$ctrl_value" 'BEGIN{printf "%.2f", v/127}')
        wpctl set-volume $KNOB2 $vol;;

      # Knob 3
      3) 
        vol=$(awk -v v="$ctrl_value" 'BEGIN{printf "%.2f", v/127}')
        wpctl set-volume $KNOB3 $vol;;
      # Knob 4
      4) 
        vol=$(awk -v v="$ctrl_value" 'BEGIN{printf "%.2f", v/127}')
        wpctl set-volume $KNOB3 $vol;;
      # Knob 5
      5) 
        vol=$(awk -v v="$ctrl_value" 'BEGIN{printf "%.2f", v/127}')
        wpctl set-volume $KNOB3 $vol;;

      # Knob 6
      6) 
        vol=$(awk -v v="$ctrl_value" 'BEGIN{printf "%.2f", v/127}')
        wpctl set-volume $KNOB3 $vol;;

      # Knob 7
      7) 
        vol=$(awk -v v="$ctrl_value" 'BEGIN{printf "%.2f", v/127}')
        wpctl set-volume $KNOB3 $vol;;

      # Knob 8
      8) 
        vol=$(awk -v v="$ctrl_value" 'BEGIN{printf "%.2f", v/127}')
        wpctl set-volume $KNOB3 $vol;;

      # fader
      9)
        vol=$(awk -v v="$ctrl_value" 'BEGIN{printf "%.2f", v/127*100}')  
        wpctl set-volume @DEFAULT_AUDIO_SINK@ "${vol}%";;
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

      23) 
        if (( $ctrl_value == "127" )); 
          then printapplications
        fi
        ;;
      
      *) echo "Unknown Input";;
    esac
  done
}
