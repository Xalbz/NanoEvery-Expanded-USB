# Hardware test matrix

This is the source of truth for what has and has not been physically tested.

## Status legend

- ✅ **Verified** — observed working on physical hardware.
- 🧪 **Ready for test** — implemented/buildable but not yet validated on hardware.
- 🧩 **Planned** — work or design still remains.

## Current matrix

| Area | Function | Status | Notes |
|---|---|---:|---|
| HID | Gamepad enumeration | ✅ | Verified on Windows with the v5 Expanded firmware |
| HID | Gamepad buttons 1-16 | ✅ | Controlled 30-second test passed |
| HID | Gamepad X axis | ✅ | Negative/positive axis reports observed |
| HID | Keyboard enumeration/events | ✅ | Controlled 30-second hardware test passed |
| HID | Keyboard a-z / A-Z / 0-9 | ✅ | Characters and Shift modifier verified in Notepad |
| HID | Keyboard Space / Enter / Tab / Backspace | ✅ | Verified in controlled test |
| HID | Keyboard key release | ✅ | No stuck keys after test; release-all confirmed |
| HID | Mouse X/Y movement | ✅ | Controlled 30-second square movement test passed |
| HID | Mouse stop/release behavior | ✅ | Movement stopped cleanly at end of stage |
| USB support | CDC serial | ✅ | Used successfully after the EP0 repair |
| USB support | CDC line coding / baud handling | ✅ | Previously failing path recovered after v5 EP0 fix |
| Programming | 1200-baud trigger | ✅ | Normal Nano Every upload path reached |
| Programming | JTAG2 / UPDI to ATmega4809 | ✅ | Normal `.ino` upload succeeded |
| Programming | Repeated normal Arduino IDE upload | ✅ | Verified while Expanded stayed installed |
| Recovery | SAM-BA recovery entry | ✅ | Used repeatedly during development |
| Portability | Second Nano Every board | 🧩 | Not yet tested |
| Portability | Linux host | 🧩 | Not yet tested |
| Portability | macOS host | 🧩 | Not yet tested |

## Full HID validation

The controlled `1 -> 2 -> 3` gamepad/mouse/keyboard test passed on the development board on 2026-09-14.

Test sketch:

```text
examples/Full_HID_Validation/Full_HID_Validation.ino
```

Recorded result:

[2026-09-14 full HID validation](test-reports/2026-09-14-full-hid-validation.md)

## Rule for future updates

A feature only moves to ✅ after we have:

1. a real hardware test,
2. exact firmware/build identification,
3. clear reproduction steps,
4. an observed expected result,
5. any failures or limitations documented.

Additional tests will be uploaded as development continues.
