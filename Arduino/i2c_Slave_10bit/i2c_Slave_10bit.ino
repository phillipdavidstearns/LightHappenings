// Simple Sketch for ATtiny85
// Listens to I2C for an 8-bit value
// writes that value to PWM output

// Uses code from:
/*
   ATtiny85 10bit PWM
   v. 1.0
   Copyright (C) 2017 Robert Ulbricht
   https://www.arduinoslovakia.eu

   Based on http://www.technoblogy.com/show?1NGL
            David Johnson-Davies - www.technoblogy.com
            Unknown licence (? CC BY 4.0)

   Core: https://github.com/SpenceKonde/ATTinyCore

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#include <TinyWireS.h>
#include <usiTwiSlave.h>

//display register control pins

#define LED_PIN 1 // pin #6 on the ATtiny85
#define ZONE_ID 101 // use 100-124 for 25 zones

volatile int Dac = 0;
volatile int Cycle = 0;

int brightness;
float fps = 60;
unsigned long int frameMicros;
unsigned long int currentTime;
unsigned long int lastTime;
int count;

//////////////////////////////////////////////////////////////////////////////

void setup() {

  frameMicros = int (1000000 / fps);


  brightness = 0;

  TinyWireS.begin(byte(ZONE_ID)); // join i2c bus


  // Top value for high (Table 12-2)
  OCR1C = 255;
  // Timer/Counter1 doing PWM on OC1A (PB1)
  TCCR1 = 1 << PWM1A    // Pulse Width Modulator A Enable
          | 1 << COM1A0 // OC1x cleared on compare match. Set when TCNT1 = $00
          | 1 << CS10;  // PWM clock = CK
  TIMSK |= 1 << TOIE1; // Timer/Counter1 Overflow Interrupt Enable

  pinMode(LED_PIN, OUTPUT);

  // Serial for testing on ArduinoMEGA
  Serial.begin(115200);

}

//////////////////////////////////////////////////////////////////////////////

void loop() {

  char vals[4];

  currentTime = micros();

  if ( TinyWireS.available() >= 5 ) {
    Serial.print("Data recieved: ");
    for (int i = 0 ; i < 5; i++) {
      char data = TinyWireS.receive();
      Serial.print(data);
      if (data != ';') {
        if (i < 5) vals[i]=atoi(data);
      } else {
        return;
      }
    }
    Serial.print(" converted to int: ");
    brightness = atoi(vals);
    Serial.print(brightness);
  }


  if ( currentTime - lastTime > frameMicros  ) {

    // vanilla 8-bit PWM
    
    analogWrite(LED_PIN, brightness);
    lastTime = currentTime;

    // 10-bit PWM
    analogWrite10(count);
    count++;

  }

}

//////////////////////////////////////////////////////////////////////////////
// 10-bit analogWrite function

void analogWrite10 (int value) {
  cli();
  Dac = value;
  sei();
}

//////////////////////////////////////////////////////////////////////////////
// Overflow interrupt

ISR (TIMER1_OVF_vect) {
  static int remain;
  if (Cycle == 0)
    remain = Dac;
  if (remain >= 256) {
    OCR1A = 255; // high (Table 12-2)
    remain = remain - 256;
  }
  else {
    OCR1A = remain;
    remain = 0;
  }
  Cycle = (Cycle + 1) & 0x03;
}

//////////////////////////////////////////////////////////////////////////////
// END
