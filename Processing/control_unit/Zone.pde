///////////////////////////////////////////
// Zone class
// Defines the region of LEDs to be controlled

class Zone {

  int ch_id; // LED channel # 1-24
  int i2c_id; // I2C ID number from 10-33
  // Wall Sculpture Grid Coordinates of the Lighting Zone
  int gridX;
  int gridY;
  PVector pos=new PVector(0, 0);
  float r=grid_width/grid_unitsX/2;
  float brightness=0; // range: 0-1
  float maxBrightness;
  float minBrightness;
  float angle; // 0 - 1
  float rate=0;
  float ease=.125;
  long seed=int(random(pow(2, 32)));
  String mode="RANDOM";

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
    
    if (showID) {
      // display channel id
      fill(255-brightness*255);
      textAlign(CENTER, CENTER);
      text(ch_id, pos.x, pos.y-r/2);
    }

    if (showBrightness) {
      //display Brightness
      fill(255-brightness*255);
      textAlign(CENTER, CENTER);
      text(int(255*brightness), pos.x, pos.y+r/2);
    }
  }

  void update() {

    float bTarget=0; // brightness target for easing

    switch (mode) {
    case "CYCLE":
      bTarget = cycle();
      break;
    case "BREATHE":
      bTarget = breathe();
      break;
    case "RANDOM":
      bTarget = perlin();
      break;
    case "WAVES":
      break;
    case "PARTICLES":
      break;
    case "INTERACTIVE":
      bTarget = interactive();
      break;
    case "MANUAL":
      break;
    default:
      println("Unrecognized mode: "+mode);
      break;
    }
      
      
    // constraing brightness target 
    bTarget=max(0, min(bTarget, 1));
    // update brightness value and constraing between 0-1
    brightness+=ease(brightness, bTarget, ease);
    // send brightness down I2C wire
    sendI2C(byte(int(brightness*255)));
  }


  // send value to I2C device, if transmission fails, soldier on.
  void sendI2C(byte _val) {
    i2c.beginTransmission(i2c_id);
    i2c.write(_val);
    try {  
      i2c.endTransmission();
    } 
    catch (Exception e) {
      // an error is printed to the console as part of the IO library
    }
  }

  //easy easing
  float ease(float _val, float _target, float _amt) {
    return (_target - _val) * _amt;
  }

  float cycle() {
    // wrap angle to constrain between 0-1
    if ( angle > 1) {
      angle = angle-1;
    } else if (angle < 0) {
      angle = 1+angle;
    }

    //angle = max(0, (min(angle, 1)));
    float cycleVal =  0.5 * sin(2*PI*angle) + 0.5;
    angle+=rate;
    return cycleVal;
  }

  float breathe() {
    if (angle > 1) angle = 0;
    angle = max(0, (min(angle, 1)));
    float breatheVal = pow(sin(2*PI*angle), 2);
    angle+=rate;
    return breatheVal;
  }

  float perlin() {
    if (angle > 1) angle = 0;
    angle = max(0, (min(angle, 1)));
    noiseSeed(seed);
    float perlinVal = 2*noise(500*sin(2*PI*angle))-0.5;
    angle+=rate;
    return perlinVal;
  }

  float interactive() {
    PVector mouse = new PVector(mouseX, mouseY);
    float dist = PVector.dist(pos, mouse);
    float range = grid_width/grid_unitsX;
    return 1/pow(dist/range, 2);
  }

  void setMode(String _mode) {
    
    mode=_mode;
    
    switch(mode) {
    case "BREATHE":
      angle=0;
      rate=speed;
      break;
      
    case "RANDOM":
      noiseDetail(3, .75);
      angle=(random(1));
      rate=speed/500;
      break;

    case "CYCLE":
      rate=speed+(freq_offset*(ch_id-1));
      break;

    case "INTERACTIVE":
      break;

    case "MANUAL":
      break;

    case "WAVES":
      break;

    case "PARTICLES":
      break;

    default:
      break;
    }
  }
}
