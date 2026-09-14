# Architecture

## Goal

Use the Nano Every's existing ATSAMD11D14AM as an expanded USB coprocessor without sacrificing the board's normal Arduino development workflow.

## Two-MCU design

### ATmega4809

- Runs the user's Arduino sketch.
- Talks to the SAMD11 through the Nano Every's internal UART.
- Uses `Serial` for the internal SAMD11 link on the Nano Every core.
- `Serial1` remains the physical RX/TX header UART.

### ATSAMD11D14AM

Expanded firmware combines three responsibilities:

1. **USB CDC bridge** between host and ATmega4809.
2. **JTAG2/UPDI programmer** so Arduino IDE can still program the ATmega4809.
3. **Experimental USB HID reports** generated from framed UART commands sent by the ATmega4809.

## USB application layout

```text
SAMD11 flash
0x0000 ┌─────────────────────────────┐
       │ Preserved SAM-BA bootloader │ 4 KB
0x1000 ├─────────────────────────────┤
       │ Expanded application        │ max 12 KB
0x4000 └─────────────────────────────┘
```

The project treats `0x1000..0x3FFF` as the writable application region and refuses larger application images.

## HID implementation versus validation

The experimental HID layer defines:

- keyboard reports — **not yet hardware-tested**
- relative mouse reports — **not yet hardware-tested**
- 16-button gamepad with X/Y/Z/Rz axes — **hardware-tested**

The presence of keyboard or mouse code is not treated as proof that those functions work. Test status is tracked separately in [TEST_MATRIX.md](TEST_MATRIX.md).
