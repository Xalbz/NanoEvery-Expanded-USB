#pragma once
#include <Arduino.h>

/*
  NanoUSB - ATmega4809 side of the Nano Every SAMD11 experimental protocol.

  IMPORTANT FOR NANO EVERY:
    Serial  = internal UART link to SAMD11 / USB monitor
    Serial1 = physical RX/TX header pins

  Hardware-validation status:
    gamepad = verified
    keyboard = not yet verified
    mouse = not yet verified
*/

class NanoUSBClass {
public:
  void begin(unsigned long baud = 115200) { Serial.begin(baud); }

  void keyboardReport(uint8_t modifier,
                      uint8_t key1 = 0, uint8_t key2 = 0,
                      uint8_t key3 = 0, uint8_t key4 = 0,
                      uint8_t key5 = 0, uint8_t key6 = 0) {
    uint8_t p[8] = {modifier, 0, key1, key2, key3, key4, key5, key6};
    sendFrame(0x01, p, sizeof(p));
  }

  void keyboardRelease() { keyboardReport(0, 0, 0, 0, 0, 0, 0); }

  void mouse(uint8_t buttons, int8_t x, int8_t y, int8_t wheel = 0) {
    uint8_t p[4] = {buttons, (uint8_t)x, (uint8_t)y, (uint8_t)wheel};
    sendFrame(0x02, p, sizeof(p));
  }

  void mouseRelease() { mouse(0, 0, 0, 0); }

  void gamepad(uint16_t buttons,
               int8_t x = 0, int8_t y = 0,
               int8_t z = 0, int8_t rz = 0) {
    uint8_t p[6] = {
      (uint8_t)(buttons & 0xFF),
      (uint8_t)(buttons >> 8),
      (uint8_t)x, (uint8_t)y, (uint8_t)z, (uint8_t)rz
    };
    sendFrame(0x03, p, sizeof(p));
  }

  void gamepadRelease() { gamepad(0, 0, 0, 0, 0); }
  void releaseAll() { sendFrame(0x04, nullptr, 0); }

private:
  void sendFrame(uint8_t cmd, const uint8_t* payload, uint8_t len) {
    if (len > 8) return;

    uint8_t frame[15];
    uint8_t pos = 0;
    uint8_t crc = 0;

    frame[pos++] = 0xA5;
    frame[pos++] = 0x5A;
    frame[pos++] = 0xC3;
    frame[pos++] = 0x3C;
    frame[pos++] = cmd;
    frame[pos++] = len;
    crc ^= cmd;
    crc ^= len;

    for (uint8_t i = 0; i < len; ++i) {
      uint8_t b = payload[i];
      frame[pos++] = b;
      crc ^= b;
    }

    frame[pos++] = crc;
    Serial.write(frame, pos);
  }
};

NanoUSBClass NanoUSB;
