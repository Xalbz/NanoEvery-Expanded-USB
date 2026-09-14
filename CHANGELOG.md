# Changelog

## v0.1.0 — 2026-09-14

First public experimental snapshot.

### Hardware-verified HID

- **Gamepad only**
  - USB gamepad enumeration
  - live button/axis reports

### Supporting infrastructure verified

- CDC serial forwarding/configuration after the EP0 fix
- 1200-baud programming trigger
- JTAG2/UPDI programming of ATmega4809
- normal Arduino IDE `.ino` upload while Expanded remains installed
- SAM-BA recovery route retained and used during development

### Present but not yet hardware-tested

- USB keyboard HID path
- USB mouse HID path

These two must remain marked **unverified** until dedicated hardware tests are completed and uploaded.

### v5 EP0 fix

- widened USB string-descriptor request length handling from 8-bit to 16-bit
- safely capped descriptor scratch length at 255
- retained endpoint-count repair
- retained control-OUT sequencing repair
- retained short-read copy repair
- retained HID `SET_IDLE` status-ZLP repair

### Next validation work

- keyboard hardware test
- mouse hardware test
- second-board repeatability test
- additional host/Windows-machine testing
- cleaner repo-relative Windows installer
