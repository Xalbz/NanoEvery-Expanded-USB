# ATmega4809 ↔ SAMD11 HID protocol

The ATmega4809 sends framed experimental HID commands over the internal UART at 115200 baud.

> **Validation note:** the protocol defines keyboard, mouse and gamepad commands, but **only gamepad has completed hardware validation so far**.

## Frame

```text
A5 5A C3 3C CMD LEN PAYLOAD... CRC
```

CRC is `CMD XOR LEN XOR every payload byte`.

Ordinary bytes that do not form a valid NanoUSB command remain available to the CDC forwarding path.

## Commands

### `0x01` — keyboard — 🧪 unverified

Length: `8`

```text
modifier, reserved, key1, key2, key3, key4, key5, key6
```

Implemented in the protocol but **not yet physically validated**.

### `0x02` — mouse — 🧪 unverified

Length: `4`

```text
buttons, x, y, wheel
```

Implemented in the protocol but **not yet physically validated**.

### `0x03` — gamepad — ✅ verified

Length: `6`

```text
buttonsLo, buttonsHi, x, y, z, rz
```

This provides 16 buttons and four signed axes. The gamepad path is the only HID command path currently verified on real hardware.

### `0x04` — release all — 🧪 partial/indirect validation only

Length: `0`

Releases HID state. Do not treat release behavior for untested HID classes as independently verified yet.

## Arduino-side helper

See `examples/NanoEvery_NanoUSB_GamepadTest/NanoUSB.h`.

The helper uses `Serial`, not `Serial1`, because `Serial` is the internal Nano Every link to the SAMD11.
