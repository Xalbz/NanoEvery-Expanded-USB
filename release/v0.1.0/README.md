# v0.1.0 release notes

This first public snapshot documents the successful Nano Every Expanded USB milestone and publishes the test sketches, protocol, recovery notes and USB diagnosis.

## HID validation boundary

- ✅ Gamepad: hardware-tested.
- 🧪 Keyboard: implemented but not yet hardware-tested.
- 🧪 Mouse: implemented but not yet hardware-tested.

Supporting CDC and normal Arduino IDE upload paths were also tested, but those tests are not treated as proof of keyboard or mouse HID operation.

## Binary release policy

The exact hardware-tested v5 SAMD11 application hash is stored in `SHA256SUMS.txt`. The binary and repair bundle are not included in this initial source snapshot unless they can be uploaded and verified byte-for-byte against the known-good local artifacts.

Additional test artifacts will be added as the project progresses.
