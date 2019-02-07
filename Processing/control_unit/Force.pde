///////////////////////////////////////////
// Force class
//

class Force {

  PVector pos;
  float force=100;
  float strength=0;
  float lifespan=900;
  float age=0;
  float angle=0;
  float rate=random(.0025,.025);

  Force() {
    pos = new PVector(random(width),random(height));
  }
  
  Force(float _x, float _y, float _strength) {
    pos = new PVector(_x, _y);
    strength=_strength;
  }

  void update() {
    strength=force*cycle();
    //age++;
  }
  
  void render(){
    noFill();
    strokeWeight(1);
    stroke(255);
    //stroke(255*(1-age/lifespan));
    ellipse(pos.x,pos.y,strength/2,strength/2);
  }
  
  float cycle() {
    incAngle(rate);
    return 0.5 * sin(2*PI*angle) + 0.5;
  }
  
  void incAngle(float _rate){
    
    //increment angle by rate
    angle+=_rate;
    
    //wrap to constrain to 0-1
    if ( angle > 1) {
      angle = angle-1;
    } else if (angle < 0) {
      angle = 1+angle;
    }
    
  }
  
  boolean alive() {
    return age <= lifespan;
  }
  
  boolean dead() {
    return age > lifespan;
  }
  
}
