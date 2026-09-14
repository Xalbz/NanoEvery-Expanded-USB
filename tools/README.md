# Windows build / repair tools

The first public snapshot keeps the exact v5 repair workflow together as a release archive instead of prematurely rewriting the hardware-tested scripts.

Download:

`../release/v0.1.0/NanoEvery_CDC_Repair_v5_EP0_StringFix.zip`

The package contains the Windows repair/build scripts used for the successful v5 EP0 repair and gamepad test, including the SAMD11 recovery/flashing workflow and pinned-source build tooling.

## Why the tools are archived for v0.1.0

The working scripts grew during hardware debugging and still contain assumptions about the original development-lab folder layout. Keeping the verified package intact gives us a reproducible reference while a cleaner repo-relative installer is developed.

## Safety

Before using any SAMD11 flashing tool, read `../docs/RECOVERY.md` and keep your own original 12,288-byte SAMD11 application backup.

Never treat keyboard or mouse as hardware-verified just because the firmware builds. At v0.1.0 only the HID gamepad path has completed live hardware validation.
