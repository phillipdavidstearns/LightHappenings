//doens't work for ATtinys

#include <Wire.h>

//display register control pins

#define LED 5 // pin #3 on the ATtiny85
#define ZONE_ID 100 // use 100-124 for 25 zones

byte brightness;
float fps=60;
float frameMicros;
unsigned long int currentTime;
unsigned long int lastTime;

//////////////////////////////////////////////////////////////////////////////

void setup() {

  frameMicros = 1000000 / fps;

  pinMode(LED, OUTPUT);

  brightness = 0;

  Wire.begin(ZONE_ID);                // join i2c bus with address #8
  Wire.onReceive(receiveEvent); // register event
}

//////////////////////////////////////////////////////////////////////////////

void loop() {
  currentTime = micros();
  
  if ( currentTime - lastTime > int(frameMicros) ) {
    setBrightness(brightness);
    lastTime = currentTime;
  }
}

//////////////////////////////////////////////////////////////////////////////

// function that executes whenever data is received from master
// this function is registered as an event, see setup()
void receiveEvent() {
  while(Wire.available()){
    brightness = Wire.read();
  }
}

//////////////////////////////////////////////////////////////////////////////

void setBrightness(byte val) {
  analogWrite(LED, val);
}

//////////////////////////////////////////////////////////////////////////////
