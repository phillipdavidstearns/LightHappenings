///////////////////////////////////////////
// Keybindings

void keyPressed() {
  if (key != CODED) {
    switch (key) {
    case '1':
      client.write("SPEED:0.001");
      break;
    case '2':
      client.write("SPEED:0.002");
      break;
    case '3':
      client.write("SPEED:0.004");
      break;
    case '4':
      client.write("SPEED:0.008");
      break;
    case '5':
      client.write("SPEED:0.016");
      break;
    case '6':
      client.write("SPEED:0.032");
      break;
    case 'B':
      client.write("BREATHE");
      break;
    case 'R':
      client.write("RANDOM");
      break;
    case 'C':
      client.write("CYCLE");
      break;
    case 'W':
      client.write("WAVES");
      break;
    case 'P':
      client.write("PARTICLES");
      break;
    case 'I':
      client.write("INTERACTIVE");
      break;
    case 'M':
      client.write("MANUAL");
      break;
    case 'K':
      attempts=0;
      initClient(); 
      break;
    default:
      println("Invalid Keybinding.");
      break;
    }
  }
}
