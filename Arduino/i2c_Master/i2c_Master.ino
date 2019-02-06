#include <Wire.h>

//display register control pins

#define MASTER_ID 8 //master i2c device on channel 8
#define LED 5

int t; //
float freq; // cycles
float fps;
float frameMicros;
float interval;

byte brightness;
unsigned long int currentTime;
unsigned long int lastTime;

//////////////////////////////////////////////////////////////////////////////

void setup() {
  currentTime = 0;
  lastTime = 0;
  
  t = 0;
  
  freq = 2;
  
  fps = 60;

  interval = 1/fps;
  frameMicros = interval * 1000000;
  
  brightness = 0;

  pinMode(LED, OUTPUT);

  Wire.begin(MASTER_ID);                // join i2c bus with address #8

}

//////////////////////////////////////////////////////////////////////////////

void loop() {
  currentTime = micros();
  if ( currentTime - lastTime > int(frameMicros) ) {
    sendI2C(brightness);
    analogWrite(LED, brightness);
    brightness = cycle();
    lastTime = currentTime;
  }

}

//////////////////////////////////////////////////////////////////////////////

void sendI2C(byte val) {
  for (int i = 100; i < 125; i++) {
    Wire.beginTransmission(i); // transmit to device #8
    Wire.write(val);        // sends five bytes
    Wire.endTransmission();    // stop transmitting
  }
}

//////////////////////////////////////////////////////////////////////////////

byte cycle() {
  t++;
  return byte(float(255) * (0.5 * sin(2 * PI * freq * float(t) * interval ) + .5 ) );
}

//////////////////////////////////////////////////////////////////////////////
