import processing.net.*; 

Client client;

String ip = "192.168.0.100"; // the IP address of RPi running the light control sketch
int port = 31337; // RPi is listening on this port

int attempts=0;

void setup() {
  
  size(600, 200);
  
  // initialize the client
  initClient();
  
  // print the IP address
  println(client.ip());
  
}

void draw() {
  
  if(!client.active() && attempts <=5){
    if ( attempts == 5 ){
    println("Unable to establish connection with server.");
    }
    attempts++;
  }
  
  // Server can talk back.
  if (client.available() > 0) {
    println(client.readString());
  }
  
  
  
}

void initClient(){
  try{
    client = new Client(this, ip, port);
    } catch (Exception e){
    }
}
