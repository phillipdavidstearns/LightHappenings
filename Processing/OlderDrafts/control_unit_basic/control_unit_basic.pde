/*//////////////////////////////////////////
 
 A Skeletal Sketch for USM Control Unit
 
 Tasks:
 1. Receive commands over the network from a User Interface Client
 2. Process those commands and execute light control routines
 3. Issue brightness settings to ATtiny85 MCUs over I2C
 
 //////////////////////////////////////////*/
//Libraries

import processing.net.*;
import processing.io.*;

///////////////////////////////////////////
// Global variables

I2C i2c;
byte[] brightness;
int i2c_addr_start = 100;
int zone_count = 6;

float[] theta;
float[] step;

///////////////////////////////////////////
// Setup

void setup() {
  size(1280, 720);
  background(0); 

  printArray(I2C.list());
  startI2C();
  
  theta = new float[zone_count];
  step = new float[zone_count];
  
  for (int i = 0 ; i < zone_count ; i++){
    step[i]=.05+(i*.001);
  }

  brightness = new byte[zone_count];

  frameRate(30);
}

///////////////////////////////////////////
// Draw

void draw() {
  //sendI2C(100, cycle(theta1));
  //sendI2C(101, cycle(theta2));
  for (int i = 0; i < zone_count; i++) {
    theta[i]+=step[i];
    brightness[i] = cycle(theta[i]);
  }
  updateDimmers();
}

///////////////////////////////////////////
// Receive Client Event

///////////////////////////////////////////
// Send to Client

///////////////////////////////////////////
// Update Dimmers

void updateDimmers() {
  for (int i = i2c_addr_start; i < (i2c_addr_start + brightness.length); i++) {
    sendI2C(i, brightness[i-i2c_addr_start]);
  }
}

///////////////////////////////////////////
// Send I2C Event

void sendI2C(int addr, byte val) {

  i2c.beginTransmission(addr);
  i2c.write(val);

  try {  
    i2c.endTransmission();
  } 
  catch (Exception e) {
    //println(e);
    //println("closing i2c connection");
    //i2c.close();
    //println("reinitializing i2c connection");
    //startI2C();
  }
}

///////////////////////////////////////////
// Start I2C

void startI2C() {
  i2c = new I2C(I2C.list()[0]);
}

byte cycle(float theta) {

  return byte ( 255 * ( 0.5 * sin(2*PI*theta) + 0.5 ));
}
