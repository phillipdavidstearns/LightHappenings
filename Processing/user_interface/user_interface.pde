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
String data = new String();

float manual;
float master;
float masterTarget;

Button fadeUp, fadeDown, on, off, wave, random;
RadioButton modeSelect;
Slider speedSlider, manualSlider, manualLevel;


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
    
    if (abs(delta) < .01) master = masterTarget;

    master += delta * 0.025;
    
    manualLevel.setValue(master);
    
    message="LEVEL:"+master;
    
    if (!lastMessage.equals(message)) {
      client.write(message);
    }
    
    lastMessage=message;
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
