/*
  BlaX Nano Every Expanded - Arduino IDE upload verification
  Open Serial Monitor at 115200 baud after upload.
  Send P or p to verify bidirectional CDC traffic.

  This verifies the normal IDE/CDC path; it is not a keyboard/mouse HID test.
*/

#define TEST_VERSION "BLAX_EXPANDED_IDE_TEST_V1"

unsigned long lastPrint = 0;
unsigned long counter = 0;
bool ledState = false;

void setup()
{
  pinMode(LED_BUILTIN, OUTPUT);
  digitalWrite(LED_BUILTIN, LOW);
  Serial.begin(115200);
  delay(1000);

  Serial.println();
  Serial.println("========================================");
  Serial.println("  BLAX NANO EVERY EXPANDED");
  Serial.println("  ARDUINO IDE UPLOAD TEST");
  Serial.println("========================================");
  Serial.print("Firmware ID : ");
  Serial.println(TEST_VERSION);
  Serial.println("Upload      : SUCCESS");
  Serial.println("ATmega4809  : RUNNING");
  Serial.println("CDC Serial  : RUNNING");
  Serial.println();
  Serial.println("Send P in Serial Monitor for PONG.");
  Serial.println("========================================");
}

void loop()
{
  if (millis() - lastPrint >= 1000)
  {
    lastPrint = millis();
    ledState = !ledState;
    digitalWrite(LED_BUILTIN, ledState);

    Serial.print("LIVE | seconds=");
    Serial.print(millis() / 1000);
    Serial.print(" | packet=");
    Serial.println(counter++);
  }

  while (Serial.available())
  {
    char c = Serial.read();
    if (c == 'P' || c == 'p')
    {
      Serial.println();
      Serial.println("PONG - USB CDC RX/TX VERIFIED!");
      Serial.println();
    }
  }
}
