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
  float manual; // manual brightness value
  float rate=0;
  float ease=.25;
  long seed=int(random(pow(2, 32)));
  float noiseScale=1500;
  String mode="RANDOM";

  // constructor
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
    // draw crosshairs at center of Zone
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
      bTarget = waves();
      break;
    case "PARTICLES":
      bTarget = particles();
      break;
    case "INTERACTIVE":
      bTarget = interactive();
      break;
    case "MANUAL":
      bTarget = manual;
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
    if (I2CEnable)sendI2C(byte(int(brightness*255)));
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

  // CYCLE mode
  float cycle() {
    incAngle(rate);
    return 0.5 * sin(2*PI*angle) + 0.5;
  }

  // BREATHE mode
  float breathe() {
    incAngle(rate);
    return pow(sin(2*PI*angle), 2);
  }

  // RANDOM mode
  float perlin() {
    incAngle(rate/noiseScale);
    return 2*noise(noiseScale*sin(2*PI*angle))-0.5;
  }

  // INTERACTIVE mode
  float interactive() {
    PVector mouse = new PVector(mouseX, mouseY);
    float dist = PVector.dist(pos, mouse);
    float range = grid_width/grid_unitsX;
    return 1/pow(dist/range, 2);
  }

  // PARTICLES mode
  float particles() {
    float val=0;
    for (int i = 0; i < lamps.size(); i++) {
      Lamp l = lamps.get(i);
      float dist = PVector.dist(pos, l.pos);
      float range = grid_width/grid_unitsX;
      val+=l.strength/pow(dist/range, 2);
    }
    return val;
  }

  // WAVES mode
  float waves() {

    if (waves.size() < maxWaves && random(1) < 0.001) {
      waves.add(new Wave());
    }

    float val=0;
    for (int i = 0; i < waves.size(); i++) {
      Wave w = waves.get(i);
      float dist = PVector.dist(pos, w.pos)-w.r;
      float range = grid_width/grid_unitsX;
      val+=1/pow(dist/range, 2);
    }
    return val;
  }


  void incAngle(float _rate) {
    //increment angle by rate
    angle+=_rate;
    //wrap to constrain to 0-1
    if ( angle > 1) {
      angle = angle-1;
    } else if (angle < 0) {
      angle = 1+angle;
    }
  }

  void setMode(String _mode) {

    mode=_mode;

    switch(mode) {

    case "BREATHE":
      particleMode=false;
      waveMode=false;
      angle=0;
      rate=speed;
      break;

    case "RANDOM":
      particleMode=false;
      waveMode=false;
      noiseSeed(seed);
      noiseDetail(3, .75);
      angle=(random(1));
      rate=speed;
      break;

    case "CYCLE":
      particleMode=false;
      waveMode=false;
      rate=speed+(freq_offset*(ch_id-1));
      break;

    case "INTERACTIVE":
      particleMode=false;
      waveMode=false;
      break;

    case "MANUAL":
      particleMode=false;
      waveMode=false;
      break;

    case "WAVES":
      particleMode=false;
      waveMode=true;
      break;

    case "PARTICLES":
      particleMode=true;
      waveMode=false;
      break;

    default:
      println("Unrecognized mode: "+mode);
      break;
    }
  }
}
