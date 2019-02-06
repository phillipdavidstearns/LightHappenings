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

Zone[] zones;

boolean verbose=true;

// I2C setup variables
int i2c_addr_start = 10;
int zone_count = 24;


// Misc global variables
float speed = .001; // speed of animaiton
float cycle_offset = .0001; // used to determin the frequency offset of the CYCLE routine
String mode = "BREATHE" ; // animation routine

/*
  Supported modes/animation routines:
 CYCLE        Sets each Zone to the global speed + and offset
 BREATH       Sets all zones to the global speed
 RANDOM       Randomizes the 
 WAVES
 INTERACTIVE
 MANUAL
 PARTICLES
 */

// variables for establishing the grid
float grid_padding=20;
int grid_unitsX=15;
int grid_unitsY=4;
float grid_width;
float grid_height;
float grid_offsetX;
float grid_offsetY;
Table grid; // used to map the zones

Server server;

///////////////////////////////////////////
// Setup

void setup() {
  size(600, 200);
  background(0); 
  frameRate(30);
  noSmooth();

  // initialize server
  server = new Server(this, 31337); // WIP: IP address contingent upon wlan settings

  // i2c initialization
  printArray(I2C.list()); //prints available i2c buses
  i2c = new I2C(I2C.list()[0]); // uses the first available i2c bus

  // grid formatting
  grid_width=width-2*grid_padding;
  grid_height=grid_unitsY*grid_width/grid_unitsX;
  grid_offsetX = 0;
  grid_offsetY = (height-grid_height)/2-grid_padding;
  grid=loadTable("grid.txt", "csv"); // grid.txt must be in project folder

  // initialize zones
  zones = new Zone[zone_count];
  for (int i = 0; i < zone_count; i++) {
    TableRow row = grid.getRow(i);
    zones[i]=new Zone(parseInt(row.getString(0)), parseInt(row.getString(1)), i, i+i2c_addr_start);
  }

  //GPIO initialization for RPi
  GPIO.pinMode(4, GPIO.OUTPUT); // GPIO 4 is physical header pin 7
}

///////////////////////////////////////////
// resetDimmers()
// call if the arduinos need to be reset
// not yet implemented in hardware!!!

void resetDimmers() {
  GPIO.digitalWrite(4, 0);
}

///////////////////////////////////////////
// Draw

void draw() {

  //check network communications
  //network();

  background(0);

  for (int i = 0; i < zone_count; i++) {
    zones[i].drawCrosshairs();
  }

  for (int i = 0; i < zone_count; i++) {
    zones[i].render();
    zones[i].update();
  }
}

///////////////////////////////////////////
// Server

void network() {
  // Get the next available client
  Client client = server.available();
  // If the client is not null, and says something, display what it said
  if (client !=null) {
    String whatClientSaid = client.readString();
    if (whatClientSaid != null) {
      println(client.ip() + "t" + whatClientSaid);
      client.write("roger");
    }
  }
}

///////////////////////////////////////////
// Verbose output

void verbose(String _message) {
  if (verbose) println(_message);
}

///////////////////////////////////////////
// Zone class

class Zone {

  int ch_id;
  int i2c_id;
  int gridX=0;
  int gridY=0;
  PVector pos=new PVector(0, 0);
  float r=grid_width/grid_unitsX/2;
  float brightness=0; // value should be from 0-1
  float maxBrightness;
  float minBrightness;
  float cycle; // 0 - 1
  float rate=0;
  float ease=.125;
  long seed=int(random(pow(2, 32)));

  Zone(int _x, int _y, int _ch, int _id) {
    gridX=_x;
    gridY=_y;
    pos.x=grid_offsetX+grid_padding+(gridX-1)*grid_width/(grid_unitsX)+grid_width/(grid_unitsX)/2;
    pos.y=grid_offsetY+grid_padding+(gridY-1)*grid_height/(grid_unitsY)+grid_height/(grid_unitsY)/2;
    ch_id=_ch;
    i2c_id=_id;
    rate=speed;
  }

  void drawCrosshairs() {
    stroke(127);
    strokeWeight(0);
    line(pos.x, 0, pos.x, height);
    line(0, pos.y, width, pos.y);
  }

  void render() {

    // draw rectangle
    stroke(255);
    strokeWeight(.5);
    fill(max(0, min(brightness*255, 255)));
    rectMode(CENTER);
    rect(pos.x, pos.y, 2*r, 2*r);

    // display channel id
    fill(255-brightness*255);
    textAlign(CENTER, CENTER);
    text(ch_id, pos.x, pos.y-r/2); 

    //display Brightness
    fill(255-brightness*255);
    textAlign(CENTER, CENTER);
    text(int(255*brightness), pos.x, pos.y+r/2);
  }

  void update() {

    float bTarget=0; // brightness target for easing

    switch (mode) {
    case "CYCLE":
      bTarget = cycle();
      cycle+=rate;
      break;
    case "BREATHE":
      bTarget = breathe();
      cycle+=rate;
      break;
    case "RANDOM":
      bTarget = cycle();
      cycle+=rate;
      break;
    case "WAVES":
      break;
    case "PARTICLES":
      break;
    case "INTERACTIVE":
      PVector mouse = new PVector(mouseX, mouseY);
      float dist = PVector.dist(pos, mouse);
      float range = grid_width/grid_unitsX;
      brightness=1/pow(dist/range, 2);
      break;
    case "MANUAL":
      break;
    default:
      println("Unrecognized mode: "+mode);
      break;
    }

    brightness+=ease(brightness, bTarget, ease);
    brightness=max(0, min(brightness, 1));
    sendI2C(byte(int(brightness*255)));
  }

  void sendI2C(byte _val) {

    i2c.beginTransmission(i2c_id);
    i2c.write(_val);
    try {  
      i2c.endTransmission();
    } 
    catch (Exception e) {
    }
  }

  float ease(float _current, float _bTarget, float _amt) {
    return (_bTarget-_current)*_amt;
  }

  float cycle() {
    if (cycle > 1) cycle = 0;
    cycle = max(0, (min(cycle, 1)));
    return 0.5 * sin(2*PI*cycle) + 0.5;
  }

  float breathe() {
    if (cycle > 1) cycle = 0;
    cycle = max(0, (min(cycle, 1)));
    return pow(sin(2*PI*cycle), 2);
  }

  float perlin() {
    if (cycle > 1) cycle = 0;
    cycle = max(0, (min(cycle, 1)));
    return 0.5 * sin(2*PI*cycle) + 0.5;
  }
}

///////////////////////////////////////////
// Keybindings

void keyPressed() {
  switch (key) {
  case 'B':
    mode = "BREATHE";
    verbose("Mode: "+mode);
    for (int i = 0; i < zone_count; i++) {
      zones[i].cycle=0;
      zones[i].rate=speed;
    }
    break;
  case 'R':
    mode = "RANDOM";
    verbose("Mode: "+mode);
    for (int i = 0; i < zone_count; i++) {
      randomSeed(zones[i].seed);
      zones[i].rate=speed+random(.01);
      println("Zone: "+i+" Rate: "+zones[i].rate);
    }
    break;
  case 'C':
    mode = "CYCLE";
    verbose("Mode: "+mode);
    for (int i = 0; i < zone_count; i++) {
      zones[i].rate=speed+(cycle_offset*i);
    }
    break;
  case 'W':
    mode = "WAVES";
    verbose("Mode: "+mode);
    break;
  case 'P':
    mode = "PARTICLES";
    verbose("Mode: "+mode);
    break;
  case 'I':
    mode = "INTERACTIVE";
    verbose("Mode: "+mode);
    break;
  }
}
