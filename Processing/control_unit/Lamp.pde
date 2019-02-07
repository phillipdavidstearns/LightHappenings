///////////////////////////////////////////
// Lamp class
// Defines a light source to be used in PARTICLE mode

class Lamp {

  PVector pos;
  PVector vel;
  PVector acc;
  PVector force;
  float strength;
  float mass=1;
  float lifespan;
  float age = 0;

  Lamp(float _x, float _y, float _strength) {
    pos = new PVector(_x, _y);
    vel = new PVector(random(-2, 2), random(-2, 2));
    acc = new PVector();
    strength=_strength;
  }

  void update() {
    strength=1-age/lifespan;
    //F=ma rewritten as a=F/m
    acc=force.mult(1/mass);
    //acceleration is the rate of change of velocity
    vel.add(acc);
    //velocity is the rate of change of location
    pos.add(vel);

    //zero out the forces
    force = new PVector();
    age++;
  }

  void render() {
    stroke(255);
    strokeWeight(3);
    point(pos.x, pos.y);
  }

  void applyForce(PVector _force) {
    force.add(_force);
  }

  boolean alive() {
    return age <= lifespan;
  }
}

///////////////////////////////////////////
// Force class
//

class Force {

  PVector pos;
  float strength;
  float lifespan;
  float age;

  Force(float _x, float _y, float _strength) {
    pos.x=_x;
    pos.y=_y;
    strength=_strength;
  }

  void update() {
  }
  
  boolean alive() {
    return age <= lifespan;
  }
}

///////////////////////////////////////////
// Wave class
//

class Wave {

  PVector pos;
  float r;
  float s; //rate that r increaces
  color c = 255;
  float lifetime;
  float age;
  float strength;
  float lifespan;
  float age;


  Wave(float _x, float _y, float _s) {
    pos.x=_x;
    pos.y=_y;
    r=0;
    s=_s;
  }

  void render() {
    noFill();
    strokeWeight(1);
    stroke(c);
  }
}
