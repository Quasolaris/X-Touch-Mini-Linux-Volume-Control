# Behringer X-Touch MINI Script to control your audio sources

## This repository moved to Codeberg
GitHub is no longer a place where I want to upload and share my code, for different reasons. I therefore decided to move my repositories to Codeberg, you can find this migrated repository here:

https://codeberg.org/Quasolaris/X-Touch-Mini-Linux-Volume-Control

I will leave the repositories as they are for now on GitHub. Later this year I will archive them.

---
A simple script that gives the X-Touch Mini by Behringer the ability to control the volumes of audio streams (ex. Browser, Discord, Music Player etc.). The sources to control are set through clicking the buttons beneath the knobs. To set outputs to switch from and to (ex. speakers to headphones and back), click the button next to MC. For all mappings see the image under *Implemented Mappings*.

This script should also work with other MIDI controllers, but you will need to change the mappings, see the Sources chapter for an explanation on how to do it.

## Functionalities
- Knobs 1 - 8 control the volume of 8 sources chosen with the buttons beneath the knobs (0-127 mapped from 0.0 to 1.0)
- Knob buttons 1 - 8 (See image below) used to map application
  - Click button and choose an application from the list   
- Fader control the main volume (0-127 mapped from 0 to 100%)
- Buttons mapped:
  - Play
  - Stop
  - Next
  - Previous
- MC Button switches between two outputs (ex. Speakers and Headphones), which are set via button next to it
- Button next to MC (Row 2 button on the bottom) set the outputs
- Record Button Resets Terminal view, in case error messages made it unreadable  

## Implemented Mappings
<p align="center">
<img width="1080" height="340" alt="image" src="https://github.com/user-attachments/assets/a54908f6-a30a-49a2-90eb-b2600ce210aa" />
</p>

## Terminal Output

<p align="center">
<img width="704" height="550" alt="image" src="https://github.com/user-attachments/assets/1083599e-cd7e-4864-8902-815acc7fb7b7" />
</p>

<p align="center">

  Set Sources to control     |  Set Outputs to switch
:-------------------------:|:-------------------------:
<img width="437" height="488" alt="sources selection" src="https://github.com/user-attachments/assets/6e7585c6-e786-47a9-9cb5-10c88fd05843" /> | <img width="437" height="488" alt="output selection" src="https://github.com/user-attachments/assets/1feeec5b-4482-43f4-be5d-cec026c4ab60" />

</p>

## Dependencies
- [playerctl](https://man.archlinux.org/man/playerctl.1.en)
  - Arch
  - Debian / Ubuntu
  - Other distributions will have it as well

## Instructions for using X-Touch MINI
1. Plugin your Behringer X-Touch MINI
2. Run `aseqdump -l` to make sure, your X-Touch MINI is recognized and named `X-TOUCH MINI` under *Client name*
3. If it is named otherwise go to the Script and change the line `aseqdump -p  "X-TOUCH MINI"` to `aseqdump -p  "WHAT YOUR MIDI CONTROLLER IS NAMED"`
4. Run the script `bash midi_control.sh`
5. Follow the instructions
6. Control your volumes

### Set outputs sinks to have them already selected when script is run
You can set the outputs to have them automatically assigned on script run. To do this you need to replace the two variable values with your outputs:
```bash
#!/bin/bash
# ===================[ VARIABLES ]=================== 

# set your outputs here, replace with name of your output sinks (copy from running scrip)
output_config_1="Sound Blaster Play! 3 Analog Stereo"
output_config_2="effect_input.virtual-surround-7.1"
```

Then you can run the script with the `-c` flag `midi_control.sh -c`, this will assign the set outputs to the MC-Button. When the selection is empty when you run the script, then the sinks were not found and you may have a typo in the output name.


## Instructions to use with other MIDI Controller
Same steps as for X-Touch MINI but you maybe need to change the mappings, for that read the article in the Sources chapter of the README.


### Sources
This [article](https://linux.reuf.nl/projects/midi.htm) by Martin de Reuver made it possible for me to write this script. I tried countless scripts, programs and repos but none worked, which is why I decided to write my own.
