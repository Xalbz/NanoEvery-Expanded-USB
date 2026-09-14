# Nano Every Expanded USB

> **Experimental / early hardware release**  
> **HID test status:** gamepad, mouse and keyboard have now all been physically verified on the development Nano Every under Windows using the controlled full-HID validation sketch.

**Nano Every Expanded USB** is an unofficial community project that explores using the Arduino Nano Every's onboard **ATSAMD11D14AM** as a more capable USB coprocessor while preserving the normal ATmega4809 Arduino workflow.

Project by **BlaX / Xalbz**.

## Current status

The first successful hardware milestone was reached on **2026-09-14**, and the same day the project completed a controlled full-HID validation.

What has now been demonstrated on the development board:

- ✅ Expanded SAMD11 firmware boots and enumerates.
- ✅ **USB HID gamepad** enumerates and sends live button/axis reports.
- ✅ **USB HID mouse** sends relative X/Y movement and stops cleanly after release.
- ✅ **USB HID keyboard** sends letters, Shift-uppercase, numbers and basic safe control keys with proper release behavior.
- ✅ CDC serial remains usable after the EP0 repair.
- ✅ The 1200-baud programming trigger still works.
- ✅ JTAG2/UPDI programming of the ATmega4809 still works.
- ✅ A normal `.ino` sketch can be uploaded from Arduino IDE while Expanded remains installed.

The full controlled HID test is stored at:

```text
examples/Full_HID_Validation/Full_HID_Validation.ino
```

and the recorded result is here:

[docs/test-reports/2026-09-14-full-hid-validation.md](docs/test-reports/2026-09-14-full-hid-validation.md)

## v0.1.0 public snapshot

The first public snapshot is intentionally **source/documentation first**. It contains the verified HID tests, Arduino IDE upload verification sketch, protocol, recovery notes, USB trace diagnosis and live test matrix.

The exact locally tested SAMD11 firmware hash is recorded in [release/v0.1.0/SHA256SUMS.txt](release/v0.1.0/SHA256SUMS.txt). Additional tested artifacts will be uploaded as development continues.

## Architecture

The Nano Every contains two MCUs:

- **ATmega4809** — runs the Arduino sketch.
- **ATSAMD11D14AM** — handles USB and programming.

Expanded keeps this two-MCU design:

```mermaid
flowchart LR
    PC[Windows / USB host]
    S[SAMD11 Expanded firmware]
    A[ATmega4809 Arduino sketch]
    G[USB HID Gamepad]
    K[USB HID Keyboard]
    M[USB HID Mouse]

    PC <-- CDC Serial --> S
    PC <-- JTAG2 programming --> S
    S -- UPDI --> A
    A <-- internal UART --> S
    S --> G
    S --> K
    S --> M
```

The key design goal is to gain extra USB capability **without throwing away normal Nano Every sketch uploading**.

## Hardware-tested firmware snapshot

The v5 EP0 repair image used in the successful HID/programming tests measured:

```text
12,208 / 12,288 bytes
80 bytes free
```

SHA-256:

```text
a504f33ecf0e985efda9eff4813cf823ffb52de69c5a3abd907071df3247e28e
```

See [Hardware verification](docs/HARDWARE_VERIFICATION.md).

## Why v5 mattered: the CDC / EP0 bug

During development, Windows could enumerate the Expanded CDC interface and then later hang while reading serial-port state. USB tracing showed that Windows requested a string descriptor with `wLength = 0x0100` (256), while the pinned historical SAMD core passed the request into a helper whose `maxlen` parameter was only 8-bit:

```cpp
sendStringDescriptor(const uint8_t *string, uint8_t maxlen)
```

That narrowed `256` to `0`, broke the control request, and poisoned endpoint 0 for later CDC requests.

v5 widens that descriptor-length path and safely caps the temporary descriptor size. Full notes are in [docs/USB_TRACE_DIAGNOSIS.md](docs/USB_TRACE_DIAGNOSIS.md).

## Controlled full HID validation

The verification sketch uses explicit single-character commands from Serial Monitor:

```text
1 = GAMEPAD test  (30 sec)
2 = MOUSE test    (30 sec)
3 = KEYBOARD test (30 sec)
```

The sequence is locked to `1 -> 2 -> 3` and each stage ends with HID release behavior. After the keyboard stage the sketch enters safe idle mode and generates no further HID activity.

### Gamepad — verified

The 30-second stage cycles buttons 1-16 and moves the X axis in both directions.

### Mouse — verified

The 30-second stage moves the pointer in repeated right/down/left/up patterns. It intentionally performs no mouse clicks.

### Keyboard — verified

The 30-second stage was observed in Windows Notepad and covers:

- `a-z`
- `A-Z` using Shift
- `0-9`
- Space
- Enter
- Tab
- Backspace
- release behavior between strokes

The test intentionally avoids Ctrl, Alt, GUI/Windows-key and other potentially disruptive shortcuts.

## Normal Arduino IDE upload — verified

See:

```text
examples/IDE_Upload_Verification/IDE_Upload_Verification.ino
```

Upload it normally as **Arduino Nano Every**, then open Serial Monitor at **115200 baud**. A successful run prints:

```text
BLAX NANO EVERY EXPANDED
ARDUINO IDE UPLOAD TEST
Firmware ID : BLAX_EXPANDED_IDE_TEST_V1
Upload      : SUCCESS
ATmega4809  : RUNNING
CDC Serial  : RUNNING
LIVE | seconds=1 | packet=0
LIVE | seconds=2 | packet=1
...
```

Sending `P` should return:

```text
PONG - USB CDC RX/TX VERIFIED!
```

## Test policy

This repository intentionally distinguishes three states:

| Label | Meaning |
|---|---|
| ✅ **Hardware verified** | Seen working on a physical Nano Every during a controlled test |
| 🧪 **Ready for test** | Implemented/buildable, but not yet physically validated |
| 🧩 **Planned** | Design/work remains |

No feature should move to **Hardware verified** until we actually test it and record the result.

Current detailed matrix: [docs/TEST_MATRIX.md](docs/TEST_MATRIX.md).

## Flashing safety

This project modifies the **SAMD11 application region**. A broken image can make normal USB disappear until recovery.

Before flashing anything:

1. Read [docs/RECOVERY.md](docs/RECOVERY.md).
2. Make and keep **your own** original SAMD11 application backup.
3. Preserve the lower 4 KB SAM-BA recovery bootloader.
4. Do not use a full-chip erase as a normal flashing/recovery step.
5. Reject application images larger than **12,288 bytes**.
6. Verify the target before writing (`ATSAMD11D14AM`, chip ID `0x10030000` on the tested board).

You are modifying USB firmware at your own risk.

## ATmega4809 ↔ SAMD11 HID protocol

The HID channel uses the Nano Every's internal `Serial` UART at 115200 baud:

```text
A5 5A C3 3C CMD LEN PAYLOAD... CRC
```

The protocol currently defines and has now physically validated keyboard, mouse and gamepad commands on the development board.

See [docs/PROTOCOL.md](docs/PROTOCOL.md).

## Contributing / test reports

Hardware testing is especially useful. If you test another Nano Every, another Windows machine, or another host OS, please record the exact board, firmware hash, OS, steps and result.

See [CONTRIBUTING.md](CONTRIBUTING.md) and the hardware-test issue template.

## Credits

This project builds on Arduino's Nano Every / MuxTO and SAMD/megaAVR core work, plus historical MattairTech SAMD11/BOSSA tooling used to reconstruct the build/recovery environment. See [NOTICE.md](NOTICE.md).

This is **not an official Arduino project** and is not endorsed by Arduino.
