/*//////////////////////////////////////////
 
 A Skeletal Sketch for USM Control Unit
 
 Tasks:
 1. Receive commands over the network from a User Interface Client
 2. Process those commands and execute light control routines
 3. Issue brightness settings to ATtiny85 MCUs over I2C
 
 *****************************************************************************
 run this command from the Raspberry Pi command line to execute:
 processing-java --sketch=/home/pi/Documents/USM/LightHappenings/Processing/control_unit/ --force --run
 *****************************************************************************
 
 Written by Phillip David Stearns 2019
 Processing 3.5.2
 No lincenses and No warranties are granted.
 Reuse this code at your own peril.
 
 //////////////////////////////////////////*/
//Libraries

import processing.net.*;
import processing.io.*;

///////////////////////////////////////////
// Global variables

I2C i2c;

Zone[] zones;

//********************
// ENABLE FOR I2C
boolean I2CEnable=false;
//********************

boolean verbose=true;
boolean showID=false;
boolean showBrightness=false;
boolean particleMode=false;
boolean waveMode=false;

// I2C setup variables
int i2c_addr_start = 10;
int zone_count = 24;


// Misc global variables
float speed = .005; // speed of animaiton
float speedMin=.0025;
float speedMax=.025;
float freq_offset; // used to determin the frequency offset of the CYCLE routine
float[] manual;

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

ArrayList<Lamp> lamps;
ArrayList<Force> forces;
ArrayList<Wave> waves;

int maxWaves=6;

///////////////////////////////////////////
// Setup

void setup() {
  size(400, 150);
  background(0); 
  frameRate(30);

  //noSmooth();

  freq_offset=speed*.1;

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

  // initialize zones
  zones = new Zone[zone_count];
  for (int i = 0; i < zone_count; i++) {
    TableRow row = grid.getRow(i);
    zones[i]=new Zone(parseInt(row.getString(0)), parseInt(row.getString(1)), i+1, i+i2c_addr_start);
  }

  //initialize the animation
  setMode("RANDOM");

  lamps = new ArrayList<Lamp>();
  for (int i = 0; i < 5; i++) {
    lamps.add(new Lamp());
  }

  forces = new ArrayList<Force>();
  for (int i = 0; i < 5; i++) {
    forces.add(new Force());
  }

  waves = new ArrayList<Wave>();

  //GPIO initialization for RPi
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

  if (particleMode) {
    // update the lamps
    for (int i = lamps.size()-1; i >=0; i--) {
      Lamp l=lamps.get(i);
      if (l.dead()) {
        lamps.remove(i);
      }

      l.render();
      l.update();
    }

    // update the forces
    for (int i = forces.size()-1; i >=0; i--) {
      Force f=forces.get(i);
      if (f.dead()) {
        forces.remove(i);
      } else {

        f.render();
        f.update();
      }
    }

    // apply forces to lamps
    for (int i = 0; i < lamps.size(); i++) {
      Lamp l = lamps.get(i);
      for (int j = 0; j < forces.size(); j++) {
        Force f = forces.get(j);
        PVector force = PVector.sub(l.pos, f.pos);
        force.setMag(-f.strength/pow(PVector.dist(l.pos, f.pos), 2));
        l.applyForce(force);
      }
    }
  }

  // update waves
  if (waveMode) {
    for (int i = 0; i < waves.size(); i++) {
      Wave w = waves.get(i);
      if (w.dead()) {
        waves.remove(i);
      } else {

        w.render();
        w.update();
      }
    }
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
    if (modeValid(message)) {
      setMode(message);
    } else {

      // if not, split the message
      String[] messages = split(message, ':');
      //for (int i =0; i< messages.length; i++) {
      //  println(messages[i]);
      //}

      switch(messages[0]) {

      case "SPEED":
        if (messages.length==2) {
          speed = Float.parseFloat(messages[1]);
          //constrain speed
          speed=max(speedMin, min(speed, speedMax));

          for (Wave w : waves) {
            w.s=speed;
          }

          //update Zone rates with new speed
          for (int i = 0; i < zone_count; i++) {
            if (zones[i].mode.equals("CYCLE")) {
              zones[i].rate=speed+(freq_offset*(zones[i].ch_id-1));
            } else {
              zones[i].rate=speed;
            }
          }
          verbose("speed set to: "+speed);
        }
        break;

      case "LEVEL":
        if (messages.length==zone_count+1) {
          for (int i = 1; i < messages.length; i++) {
            zones[i-1].manual=Float.parseFloat(messages[i]);
          }
        }
        break;

      case "SYNCH":
        for (int i = 0; i < zone_count; i++) {
          zones[i].rate=speed;
        }
        break;

      case "LAMP":
        lamps.add(new Lamp());
        break;
      case "FORCE":
        forces.add(new Force());
        break;

      case "WAVE":

        if (waves.size() < maxWaves && random(1) < 0.0005) {
          waves.add(new Wave());
        }
        break;

      default:
        verbose("Unrecognized Message from Client");
        break;
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
