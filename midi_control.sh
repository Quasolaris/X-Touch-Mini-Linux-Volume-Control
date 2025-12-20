#!/bin/bash
# ===================[ VARIABLES ]=================== 

# set your outputs here, replace with name of your output sinks (copy from running scrip)
output_config_1="Sound Blaster Play! 3 Analog Stereo"
output_config_2="effect_input.virtual-surround-7.1"

declare -a knob_ids=(KNOB1 KNOB2 KNOB3 KNOB4 KNOB5 KNOB6 KNOB7 KNOB8)
declare -a knob_apps=(APP1 APP2 APP3 APP4 APP5 APP6 APP7 APP8)


# ===================[ FUNCTIONS ]===================
setKnobValue() {

  local -n ref_knob=$1
  printStreamsToSet ${!ref_knob}
  echo
  
  exec 3<&0
  exec </dev/tty
  read -rp "Enter value for ${!ref_knob}: " value

  ref_knob=$value

  exec 0<&3 3<&-

  printconfiguration
}

setOutputID() {
  echo
  echo "-----------------------------------------------------------------"
  echo "Choose Outputs to control (if not needed press enter, two times)"
  echo "-----------------------------------------------------------------"
  echo

  printOutputsID

  exec 3<&0
  exec </dev/tty



  read -p "Enter ID of OUTPUT 1: " output1
  read -p "Enter ID of OUTPUT 2: " output2

  exec 0<&3 3<&-

  printconfiguration
}

printStreamsID() {
  # printing out streams to control and colour IDs in red
  # monitor_(FL|FR|FC|SR|RR|LFE|SL|RL) is to ignore channels if surround is configured on system
  # (PulseAudio Volume Control|GNOME Settings) is to filter out GNOME and Pulse specific entries that are not needed, insert applications to ignore there
  wpctl status | sed -n '/Streams:/,/Video/p; /Video/q' \
  | grep -oE '[0-9]+\. [^>]*' | grep -vE '^ *[0-9]+\. *output' \
  | grep -vE '^ *[0-9]+\. *input' \
  | grep -vE 'monitor_(FL|FR|FC|SR|RR|LFE|SL|RL|MONO)' \
  | grep -vE '(PulseAudio Volume Control|GNOME Settings)' \
  | sed -E 's/^([0-9]+)\./\x1b[31m\1\x1b[0m -/'


}

printOutputsID() {
  # printing out outputs to control and colour IDs in red
  wpctl status | sed -n '/Sinks:/,/Sources:/p; /Sources/q' \
  | grep -oE '[0-9]+\. [^│]*' | sed -E 's/^([0-9]+)\./\x1b[31m\1\x1b[0m -/'


  # looking for surround sinks to choose (use QJackCtl for control of Surround)
  echo
  echo "-----------------------[SURROUND OUTPUTS}------------------------"
  echo
  wpctl status | sed -n '/Filters:/,/Streams/p; /Streams/q' | grep "surround" | grep "Audio/Sink" \
  | grep -oE '[0-9]+\. [^>]*' | grep -vE '^ *[0-9]+\. *output' \
  | grep -vE '^ *[0-9]+\. *input'| sed -E 's/^([0-9]+)\./\x1b[31m\1\x1b[0m -/'
  echo
  echo "-----------------------------------------------------------------"
  echo

}

printStreamsToSet() {
  echo "=================================================================="
  echo "Set new application for ${1}"
  echo "=================================================================="

  printStreamsID
}
count_missing() {
    local cnt=0
    for name in "${knob_ids[@]}"; do
        [[ -z "${values[$name]}" ]] && ((cnt++))
    done
    echo "$cnt"
}

printHeader() {
  echo "=================================================================="
  printf "  \e[31mX-Touch MINI \e[36mLinux \e[32mVolume Control\e[0m\n"
  echo "=================================================================="

}
printconfiguration(){
  # clear terminal and print header with configuration
  clear

  printHeader
  
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
  echo "=================================================================="
  echo " Outputs"
  echo "=================================================================="

  if [[ -n $output1 && -n $output2 ]] then

    outputString=$(wpctl status | grep "${output1}\." 2>/dev/null)
    if [[ $outputString == *"│  * "* ]]; then
      printf "OUTPUT 1: \e[32m ${outputString}\n\e[0m\n\t\n"
      echo "-----------------------------------------------------"
      outputString=$(wpctl status | grep "${output2}\." 2>/dev/null)
      printf "OUTPUT 2: ${outputString}\n\n"
      echo "-----------------------------------------------------"
    else
      outputString=$(wpctl status | grep "${output1}\." 2>/dev/null)
      printf "OUTPUT 1: ${outputString}\n\n\t\n"
      echo "-----------------------------------------------------"
      outputString=$(wpctl status | grep "${output2}\." 2>/dev/null)
      printf "OUTPUT 2: \e[32m${outputString}\n\e[0m\n"
      echo "-----------------------------------------------------"
    fi
  else
    echo "No Outputs set"
  fi

}

# ===================[ CONFIGURATION ]=================== 

if [ "$1" = "-c" ]; then
    output1=$(wpctl status | grep -m 1 "$output_config_1" |  sed -r 's/^[^0-9]*([0-9]+).*$/\1/' | sed 's/\.//' | sed 's/\*//')
    output2=$(wpctl status | grep -m 1 "$output_config_2" |  sed -r 's/^[^0-9]*([0-9]+).*$/\1/' | sed 's/\.//' | sed 's/\*//')
elif [ "$1" = "-h" ]; then
    echo "- Do not set a flag to run in normal mode (no preset outputs)

- Use -c flag to set output sources, set inside script first few lines, look for output_config_1 and output_config_2 variables"
    exit 1
fi


# ===================[ SCRIPT START ]=================== 
# Initialize an associative array that will hold the values.
declare -A values
for name in "${knob_ids[@]}"; do
    values["$name"]=''   # start empty
done
clear

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


      # Knob 8 or assignment KNOB 1
      8)
        if (( $label1 == "note")) then
          if (( $ctrl_value == "127" )) then
            setKnobValue KNOB1
          fi
          
        else 
          vol=$(awk -v v="$ctrl_value" 'BEGIN{printf "%.2f", v/127}')
          wpctl set-volume $KNOB3 $vol
          printconfiguration
        fi
        ;;

      # fader or assignment KNOB 2
      # special event handling because fader has same controller ID
      9)
        case $ev2 in
          change)
            vol=$(awk -v v="$ctrl_value" 'BEGIN{printf "%.2f", v/127*100}')  
            wpctl set-volume @DEFAULT_AUDIO_SINK@ "${vol}%"
          ;;
          on)
            setKnobValue KNOB2
          ;;
        esac
      ;;
      # assignment KNOB 3
      10)
        if (( $label1 == "note")) then
          if (( $ctrl_value == "127" )) then
            setKnobValue KNOB3
          fi
        fi
        ;;
      # assignment KNOB 4
      11)
        if (( $label1 == "note")) then
          if (( $ctrl_value == "127" )) then
            setKnobValue KNOB4
          fi
      fi
      ;;
      # assignment KNOB 5
      12)
        if (( $label1 == "note")) then
          if (( $ctrl_value == "127" )) then
            setKnobValue KNOB5
          fi
      fi
      ;;
      # assignment KNOB 6
      13)
        if (( $label1 == "note")) then
          if (( $ctrl_value == "127" )) then
            setKnobValue KNOB6
          fi
      fi
      ;;
      # assignment KNOB 7
      14)
        if (( $label1 == "note")) then
          if (( $ctrl_value == "127" )) then
            setKnobValue KNOB7
          fi
      fi
      ;;
      # assignment KNOB 8
      15)
        if (( $label1 == "note")) then
          if (( $ctrl_value == "127" )) then
            setKnobValue KNOB8
          fi
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

      17)
        if (( $ctrl_value == "127" )); then 
          setOutputID
        fi
        ;;

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


      
      *) echo "Unknown Input";;
    esac
  done
}
