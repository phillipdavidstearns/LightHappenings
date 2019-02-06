import controlP5.*;
import processing.net.*; 



ControlP5 GUI;
Client client;

String ip = "192.168.0.100"; // the IP address of RPi running the light control sketch
int port = 31337; // RPi is listening on this port

int attempts=0;

int radioX = 20, radioY = 20;

RadioButton mode;

//////////////////////////////////////////////////////
// setup()

void setup() {

  size(300, 400);

  background(0);

  // initialize the client
  initClient();

  // print the IP address
  println(client.ip());

  // GUI initialization
  initGUI();
}

//////////////////////////////////////////////////////
// draw()

void draw() {

  background(0);

  if (!client.active() && attempts <=5) {
    if ( attempts == 5 ) {
      println("Unable to establish connection with server.");
    }
    attempts++;
  }

  // Server can talk back.
  if (client.available() > 0) {
    println(client.readString());
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
