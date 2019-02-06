#include <SoftwareSerial.h>


//display register control pins

#define LED_PIN 1 // pin #6 on the ATtiny85
#define ID 0 // use 100-124 for 25 zones

#define RX_PIN 3
#define TX_PIN 4

SoftwareSerial mySerial(RX_PIN, TX_PIN); // RX, TX

byte brightness;
float fps = 60;
unsigned long int frameMicros;
unsigned long int currentTime;
unsigned long int lastTime;

//////////////////////////////////////////////////////////////////////////////

void setup() {

  frameMicros = int (1000000 / fps);

  pinMode(LED_PIN, OUTPUT);

  brightness = 0;

  mySerial.begin(115200);

}

//////////////////////////////////////////////////////////////////////////////

void loop() {
  currentTime = micros();

  if (mySerial.available() >= 2) {
    if (mySerial.read() == ID) {
      brightness = mySerial.read();
    }
  }

  if ( currentTime - lastTime > frameMicros  ) {

    analogWrite(LED_PIN, brightness);
    lastTime = currentTime;
  }

}

//////////////////////////////////////////////////////////////////////////////
