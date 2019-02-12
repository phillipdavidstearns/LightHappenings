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
    // true if the radius is greater than the max
    return r > rMax;
  }
}

///////////////////////////////////////////
// updateWaves()

void updateWaves() {
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
