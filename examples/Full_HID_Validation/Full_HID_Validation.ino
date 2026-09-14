/*
  ================================================================
  Nano Every Expanded USB - CONTROLLED HID VALIDATION V2
  BY BlaX / Xalbz
  ================================================================

  Commands from Serial Monitor:

      1 = GAMEPAD test  (30 sec)
      2 = MOUSE test    (30 sec)
      3 = KEYBOARD test (30 sec)

  No Enter/newline is required.
  Just send the number.

  Sequence is locked:
      1 -> 2 -> 3

  After test 3:
      SAFE IDLE / PING MODE

  Mouse test generates NO clicks.
  Keyboard test avoids CTRL / ALT / GUI / dangerous shortcuts.
*/

#include <Arduino.h>

const unsigned long TEST_TIME     = 30000UL;
const unsigned long PING_INTERVAL = 5000UL;
const uint32_t USB_LINK_BAUD = 115200;

const uint8_t CMD_KEYBOARD    = 0x01;
const uint8_t CMD_MOUSE       = 0x02;
const uint8_t CMD_GAMEPAD     = 0x03;
const uint8_t CMD_RELEASE_ALL = 0x04;

enum TestStage
{
  WAIT_GAMEPAD,
  WAIT_MOUSE,
  WAIT_KEYBOARD,
  FINISHED
};

TestStage stage = WAIT_GAMEPAD;
unsigned long lastPing = 0;

void sendFrame(uint8_t cmd, const uint8_t* payload, uint8_t len)
{
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

  for (uint8_t i = 0; i < len; i++)
  {
    frame[pos++] = payload[i];
    crc ^= payload[i];
  }

  frame[pos++] = crc;
  Serial.write(frame, pos);
}

void releaseAll()
{
  sendFrame(CMD_RELEASE_ALL, nullptr, 0);
  delay(50);
}

void gamepad(uint16_t buttons, int8_t x, int8_t y, int8_t z, int8_t rz)
{
  uint8_t p[6];
  p[0] = buttons & 0xFF;
  p[1] = buttons >> 8;
  p[2] = (uint8_t)x;
  p[3] = (uint8_t)y;
  p[4] = (uint8_t)z;
  p[5] = (uint8_t)rz;
  sendFrame(CMD_GAMEPAD, p, 6);
}

void mouseReport(uint8_t buttons, int8_t x, int8_t y, int8_t wheel)
{
  uint8_t p[4];
  p[0] = buttons;
  p[1] = (uint8_t)x;
  p[2] = (uint8_t)y;
  p[3] = (uint8_t)wheel;
  sendFrame(CMD_MOUSE, p, 4);
}

void keyboardReport(uint8_t modifier, uint8_t key)
{
  uint8_t p[8] = { modifier, 0, key, 0, 0, 0, 0, 0 };
  sendFrame(CMD_KEYBOARD, p, 8);
}

void keyboardRelease()
{
  keyboardReport(0, 0);
}

void pressKey(uint8_t key, uint8_t modifier = 0)
{
  keyboardReport(modifier, key);
  delay(55);
  keyboardRelease();
  delay(40);
}

void typeCharacter(char c)
{
  uint8_t modifier = 0;
  uint8_t key = 0;

  if (c >= 'a' && c <= 'z')
  {
    key = 0x04 + (c - 'a');
  }
  else if (c >= 'A' && c <= 'Z')
  {
    modifier = 0x02;
    key = 0x04 + (c - 'A');
  }
  else if (c >= '1' && c <= '9')
  {
    key = 0x1E + (c - '1');
  }
  else if (c == '0')
  {
    key = 0x27;
  }
  else if (c == ' ')
  {
    key = 0x2C;
  }
  else if (c == '\n' || c == '\r')
  {
    key = 0x28;
  }
  else
  {
    return;
  }

  pressKey(key, modifier);
}

void typeText(const char* text)
{
  while (*text)
  {
    typeCharacter(*text);
    text++;
  }
}

void countdown(const char* target)
{
  Serial.println();
  Serial.println("COMMAND RECEIVED OK");
  Serial.println();
  Serial.print("Switch to: ");
  Serial.println(target);
  Serial.println();

  for (int i = 5; i > 0; i--)
  {
    Serial.print("STARTING IN ");
    Serial.println(i);
    delay(1000);
  }

  Serial.println();
  Serial.println("TEST START");
  Serial.println();
}

void runGamepadTest()
{
  countdown("joy.cpl -> Game Controller Properties");

  unsigned long start = millis();
  uint8_t button = 0;

  while (millis() - start < TEST_TIME)
  {
    uint16_t mask = ((uint16_t)1 << button);

    gamepad(mask, -100, 0, 0, 0);
    delay(180);
    gamepad(mask, 100, 0, 0, 0);
    delay(180);
    gamepad(0, 0, 0, 0, 0);
    delay(100);

    button++;
    if (button >= 16) button = 0;
  }

  releaseAll();

  Serial.println();
  Serial.println("==============================");
  Serial.println("GAMEPAD TEST FINISHED");
  Serial.println("ALL GAMEPAD INPUT RELEASED");
  Serial.println("==============================");
  Serial.println();
  Serial.println("NEXT:");
  Serial.println("Send number 2 for MOUSE test.");
  Serial.println();
}

void runMouseTest()
{
  countdown("desktop / safe empty area");

  unsigned long start = millis();
  uint8_t phase = 0;

  while (millis() - start < TEST_TIME)
  {
    switch (phase)
    {
      case 0: mouseReport(0, 15, 0, 0); break;
      case 1: mouseReport(0, 0, 15, 0); break;
      case 2: mouseReport(0, -15, 0, 0); break;
      case 3: mouseReport(0, 0, -15, 0); break;
    }

    phase++;
    if (phase >= 4) phase = 0;
    delay(180);
  }

  mouseReport(0, 0, 0, 0);
  releaseAll();

  Serial.println();
  Serial.println("==============================");
  Serial.println("MOUSE TEST FINISHED");
  Serial.println("NO MORE MOVEMENT");
  Serial.println("NO BUTTONS PRESSED");
  Serial.println("==============================");
  Serial.println();
  Serial.println("NEXT:");
  Serial.println("Open Notepad.");
  Serial.println("Then send number 3.");
  Serial.println();
}

void runKeyboardTest()
{
  countdown("NOTEPAD - click inside document");

  unsigned long start = millis();

  while (millis() - start < TEST_TIME)
  {
    typeText("abcdefghijklmnopqrstuvwxyz\n");
    if (millis() - start >= TEST_TIME) break;

    typeText("ABCDEFGHIJKLMNOPQRSTUVWXYZ\n");
    if (millis() - start >= TEST_TIME) break;

    typeText("0123456789\n");
    if (millis() - start >= TEST_TIME) break;

    typeText("BLAX NANO EVERY EXPANDED USB TEST\n");

    pressKey(0x2B); // Tab
    pressKey(0x28); // Enter
    pressKey(0x2A); // Backspace
    pressKey(0x2C); // Space
  }

  keyboardRelease();
  releaseAll();

  Serial.println();
  Serial.println("==============================");
  Serial.println("KEYBOARD TEST FINISHED");
  Serial.println("ALL KEYS RELEASED");
  Serial.println("==============================");
  Serial.println();
}

void printMenu()
{
  Serial.println();
  Serial.println("==========================================");
  Serial.println(" BLAX NANO EVERY EXPANDED USB HID TEST");
  Serial.println("==========================================");
  Serial.println();
  Serial.println("TEST CONTROL:");
  Serial.println();
  Serial.println("  1 = GAMEPAD");
  Serial.println("  2 = MOUSE");
  Serial.println("  3 = KEYBOARD");
  Serial.println();
  Serial.println("Tests must run in order:");
  Serial.println("1 -> 2 -> 3");
  Serial.println();
  Serial.println("NO ENTER IS REQUIRED.");
  Serial.println("The number itself starts the stage.");
  Serial.println();
  Serial.println("------------------------------------------");
  Serial.println();
  Serial.println("READY FOR TEST 1");
  Serial.println("Send: 1");
  Serial.println();
}

void setup()
{
  pinMode(LED_BUILTIN, OUTPUT);
  digitalWrite(LED_BUILTIN, LOW);

  Serial.begin(USB_LINK_BAUD);
  delay(2000);

  releaseAll();
  printMenu();
}

void readCommands()
{
  while (Serial.available() > 0)
  {
    char c = Serial.read();

    if (c != '1' && c != '2' && c != '3')
      continue;

    if (c == '1')
    {
      Serial.println();
      Serial.println("RX: 1");

      if (stage != WAIT_GAMEPAD)
      {
        Serial.println("IGNORED: Gamepad stage already completed.");
        continue;
      }

      stage = WAIT_MOUSE;
      runGamepadTest();
      return;
    }

    if (c == '2')
    {
      Serial.println();
      Serial.println("RX: 2");

      if (stage != WAIT_MOUSE)
      {
        Serial.println("IGNORED: Run test 1 first.");
        continue;
      }

      stage = WAIT_KEYBOARD;
      runMouseTest();
      return;
    }

    if (c == '3')
    {
      Serial.println();
      Serial.println("RX: 3");

      if (stage != WAIT_KEYBOARD)
      {
        Serial.println("IGNORED: Run tests 1 and 2 first.");
        continue;
      }

      stage = FINISHED;
      runKeyboardTest();
      releaseAll();

      Serial.println();
      Serial.println("##########################################");
      Serial.println(" ALL THREE TESTS COMPLETE");
      Serial.println("##########################################");
      Serial.println();
      Serial.println("SAFE IDLE MODE ACTIVE");
      Serial.println("No more HID activity will be generated.");
      Serial.println();

      lastPing = millis();
      return;
    }
  }
}

void loop()
{
  if (stage != FINISHED)
  {
    readCommands();
    return;
  }

  if (millis() - lastPing >= PING_INTERVAL)
  {
    lastPing = millis();
    Serial.println("PING | SAFE IDLE | HID RELEASED");
    digitalWrite(LED_BUILTIN, !digitalRead(LED_BUILTIN));
  }
}
