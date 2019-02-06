/*//////////////////////////////////////////
 
 A Skeletal Sketch for USM Control Unit
 
 Tasks:
 1. Receive commands over the network from a User Interface Client
 2. Process those commands and execute light control routines
 3. Issue brightness settings to ArduinoMega over serial
 
 //////////////////////////////////////////*/
//Libraries

import processing.net.*;
import processing.serial.*;

///////////////////////////////////////////
// Global variables
Serial serial;

Zone[] zones;
int zone_count = 25;
String mode;
///////////////////////////////////////////
// Setup

void setup() {
  size(1280, 720);
  background(0); 
  frameRate(30);
  noSmooth();

  zones = new Zone[zone_count];

  for (int i = 0; i < zone_count; i++) {
    zones[i]=new Zone(random(width), random(height), 0, 0);
  }

  String portName = Serial.list()[0];
  serial = new Serial(this, portName, 115200);

  mode = "BREATHE";
}

///////////////////////////////////////////
// Draw

void draw() {
  
 background(0);
 
  for (int i = 0; i < zone_count; i++) {
    zones[i].render();
  }
  zones[0].update();
}

///////////////////////////////////////////
// send (serial TX)

void send(byte val) {
  try {
    serial.write(val);
  } 
  catch (Exception e) {
    println(e);
  }
}

///////////////////////////////////////////
// Zone class

class Zone {
  int i2c_id;
  PVector pos=new PVector(0, 0, 0);
  float r=25;
  float brightness;
  float target;
  float cycle; // 0 - 1
  float cycle_rate=.01;


  Zone(float _x, float _y, float _z, int _id) {
    pos.x=_x;
    pos.y=_y;
    pos.z=_z;
    i2c_id=_id;
    brightness=0;
    target=0;
  }


  float ease(float _target, float _rate) {
    return _target*_rate;
  }

  float cycle(float step) {
    return 0.5 * sin(2*PI * (step*255) / 255 ) + 0.5;
  }

  void render() {

    stroke(255);
    strokeWeight(.5);
    fill(max(0, min(brightness, 255)));
    ellipse(pos.x, pos.y, 2*r, 2*r);
  }


  void update() {

    switch (mode) {
    case "BREATHE":
      if (cycle > 1) cycle = 0;
      
      cycle = max(0, (min(cycle, 1)));
      //debug
      fill(255);
      text("cycle: "+cycle, 20, 20);
      text("angle: "+2*PI*cycle, 20, 40);
      brightness = 255*cycle(cycle);
      cycle+=cycle_rate;
      break;
    default:
      println("Unrecognized mode: "+mode);
      break;
    }
  }

  void sendI2C() {
  }
}
