# Build / repair tools

The project has a working Windows v5 repair/build workflow from the hardware-development session. For the first public source snapshot, the repository intentionally avoids publishing an archive unless it can be verified byte-for-byte after upload.

The documentation, protocol and verified gamepad/IDE-upload test sketches are already public. The preserved repair/build package and cleaner repo-relative tooling will be added in a follow-up update after artifact verification.

## Safety

Before using any SAMD11 flashing workflow, read `../docs/RECOVERY.md` and keep your own original 12,288-byte SAMD11 application backup.

At v0.1.0 only the **HID gamepad** path is hardware-verified. Keyboard and mouse remain test-pending.
