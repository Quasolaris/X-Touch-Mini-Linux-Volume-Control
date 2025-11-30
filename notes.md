# Behringer X-Touch Mini media control for Arch
## Get IDs of control units

To get the ID of the device:
```bash
aseqdump -l
```
Possible output:
```bash
 36:0    X-TOUCH MINI                     X-TOUCH MINI MIDI 1
```
To then listen to the events the device creates and their parameters:
```bash
aseqdump -p 36:0
```

Possible output:
```bash
Waiting for data. Press Ctrl+C to end.
Source  Event                  Ch  Data
 36:0   Control change         10, controller 9, value 100
 36:0   Note on                10, note 20, velocity 127
 36:0   Note off               10, note 20, velocity 0
 36:0   Control change         10, controller 8, value 1
 36:0   Control change         10, controller 8, value 4
 36:0   Control change         10, controller 8, value 7
 36:0   Control change         10, controller 8, value 10
```

To get application list for specific volume control:
```bash
pactl list sink-inputs | grep -E 'Sink Input|application.name' -A2
```



[Unit]
Description=PipeWire volume controller (pw‑volume)
After=pipewire.service
Wants=pipewire.service

[Service]
Type=simple
ExecStart=/usr/bin/pw-volume      # ← adjust if you installed it elsewhere
Restart=on-failure
RestartSec=5

# --------------------------------------------------------------------
#  INSTALL SECTION – makes the unit enable‑able
# --------------------------------------------------------------------
[Install]
# Start the daemon when the system reaches the normal multi‑user state.
# (You could also use graphical.target if you only need it in a GUI session.)
WantedBy=multi-user.target







Install pw-volume:
```bash
yay -S pw-volume
```

[Documentation of PW-Volume for Arch](https://wiki.archlinux.org/title/WirePlumber#)

To get audio devices:
```bash
wpctl status
```

Possible output:
```bash
Audio
 ├─ Devices:
 │      53. Scarlett Solo 4th Gen               [alsa]
 │      54. USB Audio                           [alsa]
 │      56. Sound Blaster Play! 3               [alsa]
```

