//////////////////////////////////////////////////////
// initGUI()

void initGUI() {

  GUI = new ControlP5(this);

  mode = GUI.addRadioButton("mode selector")
    .setPosition(radioX, radioY)
    .setSize(40, 40)
    .setColorForeground(color(120))
    .setColorActive(color(255))
    .setColorLabel(color(255))
    //.setItemsPerRow(5)
    .setSpacingColumn(50)
    .addItem("BREATHE", 1)
    .addItem("CYCLE", 2)
    .addItem("RANDOM", 3)
    .addItem("PARTICLES", 4)
    .addItem("WAVES", 5)
    .addItem("MANUAL", 6)
    ;

  // set style
  for (Toggle t : mode.getItems()) {
    t.getCaptionLabel().setColorBackground(color(0));
    t.getCaptionLabel().getStyle().moveMargin(0, 0, 0, 0);
    t.getCaptionLabel().getStyle().movePadding(0, 0, 0, 0);
    t.getCaptionLabel().getStyle().backgroundWidth = 0;
    t.getCaptionLabel().getStyle().backgroundHeight = 0;
  }
}

//////////////////////////////////////////////////////
//

void controlEvent(ControlEvent theEvent) {
  if (theEvent.isFrom(mode)) {


    switch(int(theEvent.getValue())) {
    case 1:
      client.write("BREATHE");
      break;
    case 2:
      client.write("CYCLE");
      break;
    case 3:
      client.write("RANDOM");
      break;
    case 4:
      client.write("PARTICLES");
      break;
    case 5:
      client.write("WAVES");
      break;
    case 6:
      client.write("MANUAL");
      break;
    }
  }
}

void radioButton(int a) {
  println("a radio Button event: "+a);
}
