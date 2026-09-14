/*
  Nano Every Expanded USB - verified gamepad smoke test

  Safe behavior:
    - no keyboard reports
    - no mouse reports
    - only a virtual gamepad
    - Button 1 toggles
    - X axis alternates left/right

  After Expanded is installed:
    Windows -> Win+R -> joy.cpl -> game controller Properties
*/

#include "NanoUSB.h"

void setup() {
  NanoUSB.begin(115200);
  delay(2000);
  NanoUSB.releaseAll();
}

void loop() {
  NanoUSB.gamepad(0x0001, -100, 0, 0, 0);
  delay(800);

  NanoUSB.gamepad(0x0000, 100, 0, 0, 0);
  delay(800);

  NanoUSB.gamepad(0x0000, 0, 0, 0, 0);
  Serial.println("NANO_EXPANDED_CDC_OK");
  delay(400);
}
