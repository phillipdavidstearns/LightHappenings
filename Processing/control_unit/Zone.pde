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
  float angle; // 0 - 1
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
      bTarget = cycle();
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
    if ( angle > 1) angle = 0;
    angle = max(0, (min(angle, 1)));
    float cycleVal =  0.5 * sin(2*PI*angle) + 0.5;
    angle+=rate;
    return cycleVal;
  }

  float breathe() {
    if (angle > 1) angle = 0;
    angle = max(0, (min(angle, 1)));
    float breatheVal = pow(sin(2*PI*angle),2);
    angle+=rate;
    return breatheVal;
  }

  float perlin() {
    if (angle > 1) angle = 0;
    angle = max(0, (min(angle, 1)));
    float perlinVal = pow(sin(2*PI*angle),2);
    angle+=rate;
    return perlinVal;
  }

  float interactive() {
    PVector mouse = new PVector(mouseX, mouseY);
    float dist = PVector.dist(pos, mouse);
    float range = grid_width/grid_unitsX;
    return 1/pow(dist/range, 2);
  }
}
