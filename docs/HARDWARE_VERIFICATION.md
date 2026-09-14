# Hardware verification

## Scope of this document

This file records **only what has actually been observed on physical hardware**.

The most important boundary for the first release is:

> **Gamepad is the only HID function hardware-tested so far.**  
> Keyboard and mouse support may be present in the firmware, but they are not yet claimed as working.

## Verified date

2026-09-14

## Tested hardware

- Arduino Nano Every
- Main MCU: ATmega4809
- USB MCU: ATSAMD11D14AM
- SAMD11 application origin: `0x1000`
- SAMD11 application capacity: `12,288 bytes`

## Tested v5 firmware

- Size: `12,208 bytes`
- Free application space: `80 bytes`
- SHA-256:

```text
a504f33ecf0e985efda9eff4813cf823ffb52de69c5a3abd907071df3247e28e
```

## HID result

### ✅ Gamepad — hardware verified

The controlled gamepad test confirmed that Windows enumerated the HID game controller and received live gamepad reports from the ATmega4809 through the SAMD11.

The safe smoke test was intentionally gamepad-only to avoid accidental keyboard input or pointer movement.

### ⏳ Keyboard — not yet hardware-tested

The protocol/descriptor path exists in the experimental firmware, but no public claim of working keyboard behavior is made yet.

### ⏳ Mouse — not yet hardware-tested

The protocol/descriptor path exists in the experimental firmware, but no public claim of working mouse behavior is made yet.

## Supporting infrastructure also verified

These tests were required to prove the Expanded firmware did not destroy the Nano Every's normal development path:

- CDC serial forwarding/configuration after the EP0 repair.
- 1200-baud programming trigger.
- JTAG2/UPDI communication to the ATmega4809.
- Normal Arduino IDE `.ino` upload while Expanded remained installed.
- The uploaded ATmega4809 sketch then produced stable 115200-baud serial output.

This supports the end-to-end programming/CDC path, but it does **not** validate untested HID classes.

## Ongoing validation

New tests will be added as the project moves forward. The live status belongs in [TEST_MATRIX.md](TEST_MATRIX.md). A function should be marked verified only after a repeatable physical test has been recorded.
