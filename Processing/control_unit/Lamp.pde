///////////////////////////////////////////
// Lamp class
// Defines a light source to be used in PARTICLE mode

class Lamp {

  PVector pos = new PVector();
  PVector vel = new PVector();
  PVector acc = new PVector();
  PVector force = new PVector();
  float strength=1;
  float mass=1;
  float lifespan=900;
  float age = 0;
  float maxSpeed=5;
  
  Lamp() {
    pos = new PVector(random(width),random(height));
    vel = new PVector(random(-2, 2), random(-2, 2));
  }

  Lamp(float _x, float _y) {
    pos = new PVector(_x, _y);
    vel = new PVector(random(-2, 2), random(-2, 2));
  }
  
  Lamp(float _x, float _y, float _strength) {
    pos = new PVector(_x, _y);
    vel = new PVector(random(-2, 2), random(-2, 2));
    strength=_strength;

  }

  void update() {
    
    strength=1-age/lifespan;
    
    //F=ma rewritten as a=F/m
    acc=force.div(mass);
    //acceleration is the rate of change of velocity
    vel.add(acc);
    vel.limit(maxSpeed);
    vel.setMag(vel.mag()*.999);
    //velocity is the rate of change of location
    pos.add(vel);
    
    // wrap the particles around the screen
    wrap();

    //zero out the forces
    force = new PVector();
    
    //increment the age;
    //age++;
    
  }

  void render() {
    stroke(int(255*strength));
    strokeWeight(5);
    point(pos.x, pos.y);
  }

  void applyForce(PVector _force) {
    force.add(_force);
  }
  
  void wrap(){
    pos.x=(pos.x+width)%width;
    pos.y=(pos.y+height)%height;
  }

  boolean alive() {
    return age <= lifespan;
  }
  
  boolean dead() {
    return age > lifespan;
  }
}

///////////////////////////////////////////
// updateLamps

void updateLamps(){
// update the lamps
  for (int i = lamps.size()-1; i >=0; i--) {
    Lamp l=lamps.get(i);
    if (l.dead()) {
      lamps.remove(i);
    }

    l.render();
    l.update();
  }
}

///////////////////////////////////////////
// applyForcesToLamps()

void applyForcesToLamps(){
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
