#include <SoftPWM_timer.h>
#include <SoftPWM.h>

int numLEDs = 25;

int startPin = 22;
int numPins = 20;

int t; //unit time ~33.3ms
float freq; // cycles

float fps = 60;
unsigned long int frameMicros;
unsigned long int currentTime;
unsigned long int lastTime;

byte values[25];

void setup() {

  for ( int i = 0 ; i < numLEDs; i++){
    values[i]=0;
  }

  for (int i = startPin ; i < (startPin + numPins + 1); i++) {
    pinMode(i, OUTPUT);
  }

  for (int i = 2 ; i < 7; i++) {
    pinMode(i, OUTPUT);
  }

  t = 0;
  freq = .01;

  frameMicros = int (1000000 / fps);

  SoftPWMBegin();

}

//////////////////////////////////////////////////////////////////////////////

void loop() {

  currentTime = micros();

  if ( currentTime - lastTime > frameMicros  ) {
    setBrightness(cycle());
    lastTime = currentTime;
  }

  
}

//////////////////////////////////////////////////////////////////////////////

byte cycle() {
  t++;
  return byte(float(255) * (0.5 * sin(2 * PI * freq * float(t)) + .5 ) );
}


//////////////////////////////////////////////////////////////////////////////

void setBrightness(byte val) {
  for (int i = startPin ; i < (startPin + numPins + 1); i++) {
    SoftPWMSet(i, val);
  }
  for (int i = 2 ; i < 7; i++) {
    analogWrite(i, val);
  }

}
