///////////////////////////////////////////
// network()

void network() {

  // Get the next available client
  Client client = server.available();

  // If the client is not null, and says something, display what it said
  if (client !=null) {

    String message = client.readString();

    println(message);

    // check to see if we're setting the mode
    if (modeValid(message)) {
      setMode(message);
    } else {

      // if not, split the message
      String[] messages = split(message, ':');
      //for (int i =0; i< messages.length; i++) {
      //  println(messages[i]);
      //}

      switch(messages[0]) {

      case "SPEED":
        if (messages.length==2) {
          try {
            speed = Float.parseFloat(messages[1]);
          } 
          catch(Exception e) {
          }

          //constrain speed
          speed=max(speedMin, min(speed, speedMax));

          for (Wave w : waves) {
            w.s=speed;
          }

          //update Zone rates with new speed
          for (int i = 0; i < zone_count; i++) {
            if (zones[i].mode.equals("CYCLE")) {
              zones[i].rate=speed+(freq_offset*(zones[i].ch_id-1));
            } else {
              zones[i].rate=speed;
            }
          }
        }
        break;

      case "LEVEL":

        if (messages.length==2) {
          for (int i = 0; i < zone_count; i++) {
            try {
              zones[i].manual=Float.parseFloat(messages[1]);
            } 
            catch(Exception e) {
            }
          }
        }
        break;

      case "SYNCH":
        for (int i = 0; i < zone_count; i++) {
          zones[i].rate=speed;
        }
        break;

      case "LAMP":
        lamps.add(new Lamp());
        break;

      case "FORCE":
        forces.add(new Force());
        break;

      case "WAVE":
        if (waves.size() < maxWaves && random(1) < 0.0005) {
          waves.add(new Wave());
        }
        break;

      default:

        verbose("Unrecognized Message from Client");
        println(message);
        break;
      }
    }
  }
}
