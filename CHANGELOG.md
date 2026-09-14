# Changelog

## v0.1.0 — 2026-09-14

First public experimental snapshot.

### Hardware-verified HID

- **Gamepad**
  - USB gamepad enumeration
  - buttons 1-16
  - live X-axis reports
  - neutral/release behavior
- **Mouse**
  - relative X/Y movement
  - repeated right/down/left/up movement pattern
  - clean stop/release behavior
- **Keyboard**
  - lowercase `a-z`
  - uppercase `A-Z` using Shift
  - number row `0-9`
  - Space / Enter / Tab / Backspace
  - key release behavior

The full controlled hardware test is stored in:

```text
examples/Full_HID_Validation/Full_HID_Validation.ino
```

and documented in:

```text
docs/test-reports/2026-09-14-full-hid-validation.md
```

### Supporting infrastructure verified

- CDC serial forwarding/configuration after the EP0 fix
- 1200-baud programming trigger
- JTAG2/UPDI programming of ATmega4809
- normal Arduino IDE `.ino` upload while Expanded remains installed
- SAM-BA recovery route retained and used during development

### v5 EP0 fix

- widened USB string-descriptor request length handling from 8-bit to 16-bit
- safely capped descriptor scratch length at 255
- retained endpoint-count repair
- retained control-OUT sequencing repair
- retained short-read copy repair
- retained HID `SET_IDLE` status-ZLP repair

### Next validation work

- second Nano Every repeatability test
- additional Windows-host testing
- Linux host test
- macOS host test
- cleaner repo-relative Windows installer
- Arduino library API built around the now-verified gamepad/mouse/keyboard protocol
