# USB trace diagnosis: CDC `GetCommState` hang

## Symptom

The Expanded firmware enumerated as a CDC device and initially handled control traffic, but Windows eventually hung while querying serial-port state. In Arduino IDE the selected baud could appear to snap back or the port could become unresponsive.

## Trace boundary

The USB trace showed this sequence:

1. CDC `GET_LINE_CODING` (`bmRequestType=0xA1`, `bRequest=0x21`, `wLength=7`) completed normally.
2. Windows requested USB string descriptors with `wLength=0x0100` (256).
3. Those requests failed.
4. A later, otherwise identical `GET_LINE_CODING` no longer completed and eventually timed out.

## Root cause

The pinned historical Arduino SAMD core had a width mismatch:

```cpp
USBSetup.wLength                  // uint16_t
sendStringDescriptor(..., maxlen) // historical maxlen was uint8_t
```

When Windows requested 256 bytes:

```text
0x0100 → narrowed to uint8_t → 0x00
```

The helper rejected the zero-length value and the standard control path stalled endpoint 0. The later CDC hang was a secondary symptom.

## v5 repair

v5 changes both declaration and definition of the helper so `maxlen` remains 16-bit, then caps the temporary string-descriptor scratch length to 255 before allocation.

The repair also preserves earlier control-path fixes:

- endpoint iteration uses element count rather than raw byte size
- control-OUT setup/data bank sequencing repaired
- short control reads copy only bytes actually received
- HID `SET_IDLE` returns the required status ZLP

## Hardware result

After the v5 repair the same board successfully passed CDC serial configuration, **HID gamepad** operation, and normal Arduino IDE uploads through the Expanded SAMD11 firmware. Gamepad is the only HID function claimed as hardware-tested at this stage; keyboard and mouse remain pending.
