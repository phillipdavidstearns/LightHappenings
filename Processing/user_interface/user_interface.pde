import processing.net.*; 
Client client;


String ip = "172.16.2.231"; // this should be the location of the RPi running the light control sketch

void setup() {
  size(200, 200);
  initClient();
  println(client.ip());
}

void draw(){
  if (client.available() > 0) {
     println(client.readString());
  }
}


void initClient(){
  client = new Client(this, ip, 31337);
  client.write("contact!");
}
