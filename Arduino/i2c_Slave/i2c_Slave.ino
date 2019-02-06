// Simple Sketch for ATtiny85
// Listens to I2C for an 8-bit value
// writes that value to PWM output

#include <TinyWireS.h>
#include <usiTwiSlave.h>

#define LED_PIN 1 // pin #6 on the ATtiny85
#define ZONE_ID 10

// This chart decodes the LED # to I2C ID and the label taped to the ATtiny85s
// LED ID  Label
// 01  10  100
// 02  11  101
// 03  12  102
// 04  13  103
// 05  14  104
// 06  15  105
// 07  16  106
// 08  17  107
// 09  18  108
// 10  19  109
// 11  20  110
// 12  21  111
// 13  22  112
// 14  23  113
// 15  24  114
// 16  25  115
// 17  26  116
// 18  27  117
// 19  28  118
// 20  29  119
// 21  30  120
// 22  31  121
// 23  32  122
// 24  33  123
// 25  34  124


float fps = 60;
float ease_rate = 0.125;
float brightness;
float target;
unsigned long int frameMicros;
unsigned long int currentTime;
unsigned long int lastTime;

//////////////////////////////////////////////////////////////////////////////

void setup() {

  frameMicros = int (1000000 / fps);

  pinMode(LED_PIN, OUTPUT);

  brightness = 0;
  target = 0;

  TinyWireS.begin(byte(ZONE_ID)); // join i2c bus

}

//////////////////////////////////////////////////////////////////////////////

void loop() {
  
  currentTime = micros();

  while (TinyWireS.available()) {
    target = float(int(TinyWireS.receive()));
  }

  brightness+=ease(brightness, target, ease_rate); 

  if ( currentTime - lastTime > frameMicros  ) {
    analogWrite(LED_PIN, byte(max(0,min(255,brightness))));
    lastTime = currentTime;
  }

}

//////////////////////////////////////////////////////////////////////////////

float ease(float _val, float _target, float _ease) {
  return ( _target - _val ) * _ease;
}
