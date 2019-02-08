import controlP5.*;
import processing.net.*; 



ControlP5 GUI;
Client client;
//String ip = "127.0.0.1"; // for testing only
String ip = "192.168.0.100"; // the IP address of RPi running the light control sketch
int port = 31337; // RPi is listening on this port

int qty_zones = 24;

String message=new String();
String lastMessage=new String();


boolean targetReached = false;
boolean auto=false;
String data = new String();
int loop;

float manual;
float master=1;
float masterTarget=1;

Button fadeUp, fadeDown, on, off, wave, random;
RadioButton modeSelect;
Slider speedSlider, manualSlider, manualLevel;
Toggle autoToggle;

//////////////////////////////////////////////////////
// setup()

void setup() {

  size(450, 400);

  background(0);


  // initialize the client
  //initClient();
  client = new Client(this, ip, port);

  // print the IP address
  println(client.ip());

  // GUI initialization
  initGUI();
  frameRate(30);
 
}

//////////////////////////////////////////////////////
// draw()

void draw() {

  background(0); 

  if (modeSelect.getValue() == 6) {

    float delta = masterTarget - master;

    if (abs(delta) < .01) masterTarget = master;
    
    master += delta * 0.05;
    
    manualLevel.setValue(master);

    message="LEVEL:"+master;

    if (!lastMessage.equals(message)) {
      client.write(message);
    }

    lastMessage=message;
  }
  
  if (auto) {
    //println(frameCount % 100);
    if (frameCount % 5400 == 0) {
      loop++;
      loop%=5;
      println(loop);
      float[] values = new float[6];
      values[loop]=1;
      modeSelect.setArrayValue(values);
    }
  }
  
}

//////////////////////////////////////////////////////
// initClient()

void initClient() {

  try {
    client = new Client(this, ip, port);
  } 
  catch (Exception e) {
  }
}

//////////////////////////////////////////////////////
//
