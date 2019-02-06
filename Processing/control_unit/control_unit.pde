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
boolean showID=false;
boolean showBrightness=false;

// I2C setup variables
int i2c_addr_start = 10;
int zone_count = 24;


// Misc global variables
float speed = .005; // speed of animaiton
float speedMin=.0005;
float speedMax=.05;
float freq_offset; // used to determin the frequency offset of the CYCLE routine

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
  size(400, 150);
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
    zones[i]=new Zone(parseInt(row.getString(0)), parseInt(row.getString(1)), i+1, i+i2c_addr_start);
  }

  //initialize the animation
  setMode("RANDOM");

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

  //for (int i = 0; i < zone_count; i++) {
  //  zones[i].drawCrosshairs();
  //}

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
    // check to see if we're setting the mode
    if(modeValid(message)){
      setMode(message);
    } else {
      // if not, check to see if setting speed
      String[] messages = split(message, ':');
      if(messages[0].equals("SPEED")){
        speed = Float.parseFloat(messages[1]);
        //constrain speed
        speed=max(speedMin,min(speedMax,.1));
        verbose("speed set to: "+speed);
      } else {
      }
    }
  }
}

///////////////////////////////////////////
// modeValid()
boolean modeValid(String _message) {
  return (
    _message != null && (
    _message.equals("BREATHE") ||
    _message.equals("RANDOM") ||
    _message.equals("CYCLE") ||
    _message.equals("WAVES") ||
    _message.equals("INTERACTIVE") ||
    _message.equals("PARTICLES") ||
    _message.equals("MANUAL")
    ));
}

///////////////////////////////////////////
// setMode()

void setMode(String _mode) {
  if (modeValid(_mode)) {
    verbose("Setting mode to: "+_mode);
    for (int i = 0; i < zone_count; i++) {
      zones[i].setMode(_mode);
    }
  } else {
    verbose("Invalid mode: "+_mode);
  }
}

///////////////////////////////////////////
// Verbose output

void verbose(String _message) {
  if (verbose) println(_message);
}
