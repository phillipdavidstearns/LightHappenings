//////////////////////////////////////////////////////
// initGUI()

void initGUI() {

  int GUIoriginX=40;
  int GUIoriginY=40;

  int buttonWidth=40;
  int buttonHeight=40;

  int vSliderWidth=40;
  int vSliderHeight=300;

  int speedOffsetX=0;
  int speedOffsetY=0;

  int manualOffsetX=160;
  int manualOffsetY=0;

  int modeOffsetX=60;
  int modeOffsetY=0;

  GUI = new ControlP5(this);

  speedSlider = GUI.addSlider("speed slider")
    .setPosition(GUIoriginX+speedOffsetX, GUIoriginY+speedOffsetY)
    .setSize(vSliderWidth, vSliderHeight)
    .setRange(.0025, .025) // values can range from big to small as well
    .setValue(.005)
    ;

  manualSlider = GUI.addSlider("manual slider")
    .setPosition(GUIoriginX+manualOffsetX, GUIoriginY+manualOffsetY)
    .setSize(vSliderWidth, vSliderHeight)
    .setRange(0, 1) // values can range from big to small as well
    .setValue(0)
    ;

  GUI.getController("manual slider")
    .getValueLabel()
    .align(ControlP5.CENTER, ControlP5.TOP_OUTSIDE)
    .setPaddingX(0)
    ;

  modeSelect = GUI.addRadioButton("mode selector")
    .setPosition(GUIoriginX+modeOffsetX, GUIoriginY+modeOffsetY)
    .setSize(buttonWidth, buttonHeight)
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
}

//////////////////////////////////////////////////////
//

void controlEvent(ControlEvent theEvent) {

  if (theEvent.isFrom(modeSelect)) {
    switch(int(theEvent.getValue())) {
    case 1:
      message="BREATHE";
      break;
    case 2:
      message="CYCLE";
      break;
    case 3:
      message="RANDOM";
      break;
    case 4:
      message="PARTICLES";
      break;
    case 5:
      message="WAVES";
      break;
    case 6:
      message="MANUAL";
      break;
    }
  }
  
  if (theEvent.isFrom(speedSlider)) {
    message="SPEED:"+theEvent.getValue();
  }
  
  if (theEvent.isFrom(manualSlider)) {
    message="LEVEL:"+theEvent.getValue();
  }
  
  
  
}
