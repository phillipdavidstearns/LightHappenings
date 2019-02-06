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


#include <Wire.h>

//display register control pins

#define LED_PIN 1 // pin #6 on the ATtiny85
#define ZONE_ID 101 // use 100-124 for 25 zones

int brightness;
float fps = 60;
unsigned long int frameMicros;
unsigned long int currentTime;
unsigned long int lastTime;

//////////////////////////////////////////////////////////////////////////////

void setup() {

  frameMicros = int (1000000 / fps);


  brightness = 0;

  Wire.begin(byte(ZONE_ID)); // join i2c bus

  pinMode(LED_PIN, OUTPUT);

  // Serial for testing on ArduinoMEGA
  Serial.begin(115200);

}

//////////////////////////////////////////////////////////////////////////////

void loop() {

  char vals[4];

  currentTime = micros();

  if ( Wire.available() >= 5 ) {
    Serial.print("Data recieved: ");
    for (int i = 0 ; i < 5; i++) {
      char data = Wire.read();
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


  }

}

//////////////////////////////////////////////////////////////////////////////
// END
