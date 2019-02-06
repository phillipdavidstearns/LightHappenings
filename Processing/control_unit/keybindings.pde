///////////////////////////////////////////
// Keybindings

void keyPressed() {
  if (key != CODED) {
    switch (key) {
    case 'B':
      setMode("BREATHE");
      break;
    case 'R':
      setMode("RANDOM");
      break;
    case 'C':
      setMode("CYCLE");
      break;
    case 'W':
      setMode("WAVES");
      break;
    case 'P':
      setMode("PARTICLES");
      break;
    case 'I':
      setMode("INTERACTIVE");
      break;
    case 'M':
      setMode("MANUAL");
      break;
    default:
      println("Invalid Keybinding.");
      break;
    }
  }
}
