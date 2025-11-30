# Behringer X-Touch MINI Script to control your audio sources
A simple script that when run, asks for what applications to control and then gives the X-Touch Mini the ability to control the volumes of the audio streams (ex. Browser, Discord, Music Player etc.). Fader controls master volume and play, next, previous and stop buttons are also mapped.

This script should also work with other MIDI controllers, but you will need to change the mappings, see the Sources chapter for an explanation on how to do it.

## Functionalities
- Knobs 1 - 8 control the volume of 8 sources chosen on script start (0-127 mapped from 0.0 to 1.0)
- Fader control the main volume (0-127 mapped from 0 to 100%)
- Buttons mapped:
  - Play
  - Stop
  - Next
  - Previous   

## Implemented Mappings (Work in Progress)
<img width="1861" height="586" alt="image" src="https://github.com/user-attachments/assets/4917a26a-6b60-478f-b0c0-9778e6928ab7" />


## Terminal Output (Work In Progress)
<img width="735" height="1518" alt="image" src="https://github.com/user-attachments/assets/f04bc6d8-7946-481d-bb98-98d28b3504d3" />




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


## Instructions to use with other MIDI Controller
Same steps as for X-Touch MINI but you maybe need to change the mappings, for that read the article in the Sources chapter of the README.


### Sources
This [article](https://linux.reuf.nl/projects/midi.htm) by Martin de Reuver made it possible for me to write this script. I tried countless scripts, programs and repos but none worked, which is why I decided to write my own.
