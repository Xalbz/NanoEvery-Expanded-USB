# Recovery and flashing safety

Read this before modifying the SAMD11.

## Rule 1: keep your own backup

Before the first experimental SAMD11 application flash, save the complete 12,288-byte application region. Do not rely on another person's backup.

## Rule 2: preserve SAM-BA

The recovery design depends on leaving the lower 4 KB SAM-BA bootloader intact. The project workflow writes only the application region beginning at `0x1000`.

Do **not** perform a full-chip erase as a normal recovery step.

## Entering the preserved SAM-BA bootloader

The procedure used successfully during development was:

1. Unplug Nano Every USB.
2. Temporarily connect the SAMD11 **SWDIO** pad to GND.
3. Keep SWDIO grounded while reconnecting USB.
4. Wait for the SAM-BA USB serial device to enumerate.
5. Remove the SWDIO-to-GND connection while leaving USB connected.
6. Probe the target before writing anything.

Verify the Nano Every schematic/revision before touching pads. Never short 3.3 V to GND and never permanently ground SWDIO.

## Required target checks

The development board reported:

```text
ATSAMD11D14AM
chip ID: 0x10030000
application origin: 0x1000
application capacity: 12288 bytes
Security: false
Locked: none
```

A public flasher should refuse to continue if these assumptions do not match.

## Binary size gate

Never flash an application larger than `12288 bytes`.

The hardware-tested v5 image was 12,208 bytes.
