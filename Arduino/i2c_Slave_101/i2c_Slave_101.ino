//doens't work for ATtinys

#include <TinyWireS.h>
#include <usiTwiSlave.h>

//display register control pins

#define LED 1 // pin #6 on the ATtiny85
#define ZONE_ID 101 // use 100-124 for 25 zones

byte brightness;
float fps = 60;
unsigned long int frameMicros;
unsigned long int currentTime;
unsigned long int lastTime;

//////////////////////////////////////////////////////////////////////////////

void setup() {

  frameMicros = int (1000000 / fps);

  pinMode(LED, OUTPUT);

  brightness = 0;

  TinyWireS.begin(byte(ZONE_ID)); // join i2c bus

}

//////////////////////////////////////////////////////////////////////////////

void loop() {
  currentTime = micros();

  while (TinyWireS.available()) {
    brightness = TinyWireS.receive();
  }

  if ( currentTime - lastTime > frameMicros  ) {
    setBrightness(brightness);
    lastTime = currentTime;
  }

}

//////////////////////////////////////////////////////////////////////////////

// function that executes whenever data is received from master
// this function is registered as an event, see setup()


//////////////////////////////////////////////////////////////////////////////

void setBrightness(byte val) {
  analogWrite(LED, val);
}

//////////////////////////////////////////////////////////////////////////////
