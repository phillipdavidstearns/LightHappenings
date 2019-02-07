///////////////////////////////////////////
// Keybindings

void keyPressed() {
  if (key != CODED) {
    switch (key) {
    case 'f':
      forces.add(new Force());
      break;
    case 'l':
      lamps.add(new Lamp());
      break;
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
      if (waves.size() < maxWaves) {
      waves.add(new Wave());
    }
      break;
    case '.':
      if (waves.size() < maxWaves) {
      waves.add(new Wave());
    }
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
