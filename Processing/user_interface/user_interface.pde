import controlP5.*;
import processing.net.*; 



ControlP5 GUI;
Client client;
String ip = "127.0.0.1"; // for testing only
//String ip = "192.168.0.100"; // the IP address of RPi running the light control sketch
int port = 31337; // RPi is listening on this port

int qty_zones = 24;

String message=new String();
String lastMessage=new String();


boolean fromManSliders = false;
String data = new String();


Button fadeUp, fadeDown, on, off;
RadioButton modeSelect;
Slider speedSlider, manualSlider;
Slider[] manualSliders;

//////////////////////////////////////////////////////
// setup()

void setup() {

  size(1200, 400);

  background(0);

  manualSliders = new Slider[qty_zones];

  // initialize the client
  //initClient();
  client = new Client(this, ip, port);

  // print the IP address
  println(client.ip());

  // GUI initialization
  initGUI();
}

//////////////////////////////////////////////////////
// draw()

void draw() {

  background(0);
  if (!lastMessage.equals(message)) {
    client.write(message);
  }

  lastMessage=message;

  if (fromManSliders) {
    data=new String("LEVEL");
    for (int i = 0; i < qty_zones; i++) {
      data+=":"+manualSliders[i].getValue();
    }
    fromManSliders=false;
    message=data;
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
