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
boolean showID=true;
boolean showBrightness=true;

// I2C setup variables
int i2c_addr_start = 10;
int zone_count = 24;


// Misc global variables
float speed = .001; // speed of animaiton
float freq_offset; // used to determin the frequency offset of the CYCLE routine
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

  freq_offset=speed*.1;

  // initialize server
  server = new Server(this, 31337); // 

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
// draw()

void draw() {

  //check network communications
  network();

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
// network()

void network() {
  // Get the next available client
  Client client = server.available();
  // If the client is not null, and says something, display what it said
  if (client !=null) {
    String message = client.readString();
    if ( message != null && (
      message.equals("BREATHE") ||
      message.equals("RANDOM") ||
      message.equals("CYCLE") ||
      message.equals("WAVES") ||
      message.equals("INTERACTIVE") ||
      message.equals("PARTICLES") ||
      message.equals("MANUAL")
      )) {
      setMode(message);
    }
    println(client.ip() + ": " + message);
    client.write("Mode set to: "+message);
  }
}

///////////////////////////////////////////
// setMode()

void setMode(String _mode) {
  switch(_mode) {
  case "BREATHE":
    mode = _mode;
    verbose("Mode: "+mode);
    for (int i = 0; i < zone_count; i++) {
      zones[i].angle=0;
      zones[i].rate=speed;
    }
    break;

  case "RANDOM":
    mode = _mode;
    verbose("Mode: "+mode);
    for (int i = 0; i < zone_count; i++) {
      randomSeed(zones[i].seed);
      zones[i].rate=speed+random(speed);
    }
    break;

  case "CYCLE":
    mode=_mode;
    verbose("Mode: "+mode);
    for (int i = 0; i < zone_count; i++) {
      zones[i].rate=speed+(freq_offset*i);
    }
    break;
    
  case "INTERACTIVE":
    mode=_mode;
    verbose("Mode: "+mode);
    break;
    
  case "MANUAL":
    mode=_mode;
    verbose("Mode: "+mode);
    break;
    
  case "WAVES":
    mode=_mode;
    verbose("Mode: "+mode);
    break;
    
  case "PARTICLES":
    mode=_mode;
    verbose("Mode: "+mode);
    break;
    
  default:
    break;
  }
}

///////////////////////////////////////////
// Verbose output

void verbose(String _message) {
  if (verbose) println(_message);
}
