///////////////////////////////////////////
// Keybindings

void keyPressed() {
  if (key != CODED) {
    switch (key) {
    case 'b':
      setMode("BREATHE");
      break;
    case 'r':
      setMode("RANDOM");
      break;
    case 'c':
      setMode("CYCLE");
      break;
    case 'w':
      setMode("WAVES");
      break;
    case 'p':
      setMode("PARTICLES");
      break;
    case 'i':
      setMode("INTERACTIVE");
      break;
    case 'm':
      setMode("MANUAL");
      break;
    default:
      println("Invalid Keybinding.");
      break;
    }
  }
}
