# Hardware verification

## Scope of this document

This file records **only what has actually been observed on physical hardware**.

As of 2026-09-14, the development board has completed controlled hardware validation of all three currently implemented HID paths:

- ✅ Gamepad
- ✅ Mouse
- ✅ Keyboard

The detailed controlled test is recorded in [test-reports/2026-09-14-full-hid-validation.md](test-reports/2026-09-14-full-hid-validation.md).

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

## HID results

### ✅ Gamepad — hardware verified

The controlled 30-second gamepad stage confirmed:

- Windows gamepad enumeration.
- Buttons 1 through 16.
- X-axis movement in both directions.
- Neutral/release behavior after reports stop.

### ✅ Mouse — hardware verified

The controlled 30-second mouse stage confirmed:

- Relative X movement.
- Relative Y movement.
- Repeated right/down/left/up movement pattern.
- Clean stop/release behavior after the stage.

The test intentionally generated no clicks.

### ✅ Keyboard — hardware verified

The controlled 30-second keyboard stage confirmed in Windows Notepad:

- lowercase `a-z`
- uppercase `A-Z` via Shift modifier
- number row `0-9`
- Space
- Enter
- Tab
- Backspace
- key release behavior

The test intentionally avoided Ctrl, Alt, GUI/Windows-key and other disruptive shortcuts.

## Safe end state

After the third stage the sketch sends the release-all command and enters a safe idle state. No more HID activity is generated; CDC periodically prints:

```text
PING | SAFE IDLE | HID RELEASED
```

## Supporting infrastructure also verified

These tests prove the Expanded firmware still preserves the Nano Every's normal development path:

- CDC serial forwarding/configuration after the EP0 repair.
- 1200-baud programming trigger.
- JTAG2/UPDI communication to the ATmega4809.
- Normal Arduino IDE `.ino` upload while Expanded remained installed.
- The uploaded ATmega4809 sketch then produced stable 115200-baud serial output.

## Validation boundary

The current results are for the development Nano Every and Windows host used during development. Cross-board repeatability and Linux/macOS hosts remain separate future validation targets.

The live status belongs in [TEST_MATRIX.md](TEST_MATRIX.md). A feature should only be marked verified after a repeatable physical test has been recorded.
