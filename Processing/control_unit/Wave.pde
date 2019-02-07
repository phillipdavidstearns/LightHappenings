///////////////////////////////////////////
// Wave class
//

class Wave {

  PVector pos;
  float r=0;
  float rMax=width;
  float s=speed; //rate that r increaces
  float scale=100; // scales the speed
  float strength=1;
  float lifespan=150;
  float age=0;

  Wave() {
    pos = new PVector(random(width),random(height));
    r=0;
  }

  Wave(float _x, float _y, float _s) {
    pos.x=_x;
    pos.y=_y;
    r=0;
    s=_s;
  }

  void update() {
    strength=1-(r/rMax);
    r+=s*scale;
    age++;
  }

  void render() {
    noFill();
    strokeWeight(1);
    stroke(255*strength);
    ellipse(pos.x, pos.y, 2*r, 2*r);
  }

  boolean dead() {
    return r > rMax;
  }
}
