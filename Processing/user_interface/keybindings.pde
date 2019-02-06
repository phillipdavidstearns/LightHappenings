///////////////////////////////////////////
// Keybindings

void keyPressed() {
  if (key != CODED) {
    switch (key) {
    case '1':
      message="SPEED:0.001";
      break;
    case '2':
      message="SPEED:0.002";
      break;
    case '3':
      message="SPEED:0.004";
      break;
    case '4':
      message="SPEED:0.008";
      break;
    case '5':
      message="SPEED:0.016";
      break;
    case '6':
      message="SPEED:0.032";
      break;
    case 'B':
      message="BREATHE";
      break;
    case 'R':
      message="RANDOM";
      break;
    case 'C':
      message="CYCLE";
      break;
    case 'W':
      message="WAVES";
      break;
    case 'P':
      message="PARTICLES";
      break;
    case 'I':
      message="INTERACTIVE";
      break;
    case 'M':
      message="MANUAL";
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
