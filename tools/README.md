# Build / repair tools

This project has a working Windows build/recovery workflow from the hardware-development session.

## Published now

- `windows/NanoEvery_MuxTO_BuildLab_v6.bat`
  - reconstructs the pinned historical MuxTO build environment
  - build-only: it does **not** open a COM port or flash the board
  - downloads/checks pinned toolchain components before building

## Not published yet

The full v5 repair/flash bundle used during the successful hardware session is being held back until the uploaded artifact can be checked byte-for-byte against the known-good local copy. This avoids presenting a damaged or incomplete archive as the tested release.

The repo already contains the verified gamepad test, Arduino IDE upload verification sketch, protocol, recovery notes, USB trace diagnosis and live test matrix.

As development continues, additional tested tools and hardware-test artifacts will be uploaded here.

## Safety

Before using any SAMD11 flashing workflow, read `../docs/RECOVERY.md` and keep your own original 12,288-byte SAMD11 application backup.

At v0.1.0 only the **HID gamepad** path is hardware-verified. Keyboard and mouse remain test-pending.
