/**
 
 A Skeletal Sketch for USM Control Unit
 
 Tasks:
 1. Receive commands over the network from a User Interface Client
 2. Process those commands and execute light control routines
 3. Issue brightness settings to ATtiny85 MCUs over I2C
 
 *****************************************************************************
 run this command from the Raspberry Pi command line to execute:
 processing-java --sketch=/home/pi/Documents/USM/LightHappenings/Processing/control_unit/ --force --run
 
 to load at boot:
 ~/.config/lxsession/LXDE-pi/autostart
 
 add line:
 @/usr/local/bin/processing-java --sketch=/home/pi/Documents/USM/LightHappenings/Processing/control_unit/ --force --run
 *****************************************************************************
 
 Written by Phillip David Stearns 2019
 Processing 3.5.2
 No lincenses and No warranties are granted.
 Reuse this code at your own peril.
 
 */

///////////////////////////////////////////
//Libraries

import processing.net.*;
import processing.io.*;

///////////////////////////////////////////
// Global variables

// networking Objects
Server server;

// I2C Object and related variables
I2C i2c;
//********************
// ENABLE FOR I2C
boolean I2CEnable=true;
//********************
int i2c_addr_start = 10;

// Array of Zone Objects and related variables
Zone[] zones;
int zone_count = 24;

// switches for debugging
boolean verbose=false;
boolean showID=false;
boolean showBrightness=false;

// switches for different modes
boolean particleMode=false;
boolean waveMode=false;

// Misc global variables
float speed = .005; // speed of animation
float speedMin=.0025;
float speedMax=.025;
float freq_offset; // used to determin the frequency offset of the CYCLE routine
int maxWaves=6; // max nuber of waves that can be active


// variables for establishing the grid of Zones
float grid_padding=20;
int grid_unitsX=15;
int grid_unitsY=4;
float grid_width;
float grid_height;
float grid_offsetX;
float grid_offsetY;
Table grid; // used to map the zones

// ArrayLists of Objects for particle systems
ArrayList<Lamp> lamps; // force directed light sources
ArrayList<Force> forces; // forces that move lights
ArrayList<Wave> waves; // an expanding circle that turns on Zones it passes

///////////////////////////////////////////
// Setup

void setup() {

  size(800, 300);
  background(0); 
  frameRate(30);

  // initialize server
  server = new Server(this, 31337); // the RPi is set to 192.168.0.100

  // i2c initialization
  printArray(I2C.list()); //prints available i2c buses
  i2c = new I2C(I2C.list()[0]); // uses the first available i2c bus

  // grid formatting
  grid_width=width-2*grid_padding;
  grid_height=grid_unitsY*grid_width/grid_unitsX;
  grid_offsetX = 0;
  grid_offsetY = (height-grid_height)/2-grid_padding;
  grid=loadTable("grid.txt", "csv"); // grid.txt must be in project folder

  // calculate constant for cycle rate offset
  freq_offset=speed*.1;

  // initialize zones
  zones = new Zone[zone_count];
  for (int i = 0; i < zone_count; i++) {
    // get the row of the grid table
    TableRow row = grid.getRow(i);
    // assign the values to the x and y grid coordinatates of a new Zone
    // set I2C  and channel ID
    zones[i]=new Zone(parseInt(row.getString(0)), parseInt(row.getString(1)), i+1, i+i2c_addr_start);
  }

  //initialize the animation
  setMode("RANDOM");

  // create new Lamps and add to ArrayList
  lamps = new ArrayList<Lamp>();
  for (int i = 0; i < 5; i++) {
    lamps.add(new Lamp());
  }

  // create new Forces and add to ArrayList
  forces = new ArrayList<Force>();
  for (int i = 0; i < 5; i++) {
    forces.add(new Force());
  }

  // initialize ArrayList of Waves
  waves = new ArrayList<Wave>();

  // GPIO initialization for RPi to reset ATTiny85s if frozen
  //GPIO.pinMode(4, GPIO.OUTPUT); // GPIO 4 is physical header pin 7
}

///////////////////////////////////////////
// resetDimmers()
// call if the arduinos need to be reset
// not yet implemented in hardware!!!

//void resetDimmers() {
//  GPIO.digitalWrite(4, 0);
//}

///////////////////////////////////////////
// draw()

void draw() {
  background(0);

  //check network communications
  network();

  // display frameRate
  //fill(255);
  //text(frameRate, 20, 20);

  // draw crosshairs
  //for (int i = 0; i < zone_count; i++) {
  //  zones[i].drawCrosshairs();
  //}

  // update the zones
  for (int i = 0; i < zone_count; i++) {
    zones[i].render();
    zones[i].update();
  }
  
  // update the particle system
  if (particleMode){
    updateLamps();
    updateForces();
    applyForcesToLamps();
  }

  // update waves
  if (waveMode) updateWaves();
  
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
