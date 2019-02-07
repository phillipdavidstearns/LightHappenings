//////////////////////////////////////////////////////
// initGUI()

void initGUI() {

  int GUIoriginX=40;
  int GUIoriginY=40;

  int buttonWidth=40;
  int buttonHeight=40;

  int vSliderWidth=40;
  int vSliderHeight=300;

  int manualSlidersX=40;
  int manualSlidersY=0;
  int manSlideBufferX=30;
  int manSlideBufferY=0;

  int speedOffsetX=180;
  int speedOffsetY=0;

  int manualOffsetX=260;
  int manualOffsetY=0;

  int modeOffsetX=0;
  int modeOffsetY=0;

  int buttonOffsetX=100;
  int buttonOffsetY=0;

  GUI = new ControlP5(this);

  fadeUp = GUI.addButton("up")
    .setValue(100)
    .setPosition(GUIoriginX+modeOffsetX+buttonOffsetX, GUIoriginY+modeOffsetY+buttonOffsetY)
    .setSize(buttonWidth, buttonHeight)
    ;
  fadeDown = GUI.addButton("down")
    .setValue(100)
    .setPosition(GUIoriginX+modeOffsetX+buttonOffsetX, GUIoriginY+modeOffsetY+buttonOffsetY+41)
    .setSize(buttonWidth, buttonHeight)
    ;


  on = GUI.addButton("on")
    .setValue(100)
    .setPosition(GUIoriginX+modeOffsetX+buttonOffsetX, GUIoriginY+modeOffsetY+buttonOffsetY+41*2)
    .setSize(buttonWidth, buttonHeight)
    ;
  off = GUI.addButton("off")
    .setValue(100)
    .setPosition(GUIoriginX+modeOffsetX+buttonOffsetX, GUIoriginY+modeOffsetY+buttonOffsetY+41*3)
    .setSize(buttonWidth, buttonHeight)
    ;
  wave = GUI.addButton("addwave")
    .setPosition(GUIoriginX+modeOffsetX+buttonOffsetX, GUIoriginY+modeOffsetY+buttonOffsetY+41*4)
    .setSize(buttonWidth, buttonHeight)
    ;
  random = GUI.addButton("rando")
    .setPosition(GUIoriginX+modeOffsetX+buttonOffsetX, GUIoriginY+modeOffsetY+buttonOffsetY+41*5)
    .setSize(buttonWidth, buttonHeight)
    ;

  //speed slider
  speedSlider = GUI.addSlider("speed")
    .setPosition(GUIoriginX+speedOffsetX, GUIoriginY+speedOffsetY)
    .setSize(vSliderWidth, vSliderHeight)
    .setRange(.0025, .025) // values can range from big to small as well
    .setValue(.005)
    ;

  // manual brightness slider
  manualSlider = GUI.addSlider("master")
    .setPosition(GUIoriginX+manualOffsetX, GUIoriginY+manualOffsetY)
    .setSize(vSliderWidth, vSliderHeight)
    .setRange(0, 1) // values can range from big to small as well
    .setValue(0)
    ;
  GUI.getController("master")
    .getValueLabel()
    .align(ControlP5.CENTER, ControlP5.TOP_OUTSIDE)
    .setPaddingX(0)
    ;

  // manual brightness slider
  for (int i = 0; i < qty_zones; i++) {
    manualSliders[i] = GUI.addSlider(nf(i, 2))
      .setPosition(GUIoriginX+manualOffsetX+manualSlidersX+(manSlideBufferX*(1+i)), GUIoriginY+manualOffsetY+manualSlidersY+manSlideBufferY)
      .setSize(vSliderWidth/2, vSliderHeight)
      .setRange(0, 1) // values can range from big to small as well
      .setValue(0)
      ;
    GUI.getController(nf(i, 2))
      .getValueLabel()
      .align(ControlP5.CENTER, ControlP5.TOP_OUTSIDE)
      .setPaddingX(0)
      ;
  }

  modeSelect = GUI.addRadioButton("modeSelect")
    .setPosition(GUIoriginX+modeOffsetX, GUIoriginY+modeOffsetY)
    .setSize(buttonWidth, buttonHeight)
    .setColorForeground(color(120))
    .setColorActive(color(255))
    .setColorLabel(color(255))
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

public void up(){
}

public void down(){
}

public void on(){
}

public void off(){
}

public void wave(){
}

public void rando(){
}

void controlEvent(ControlEvent theEvent) {

  // event handling for the mode radio
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

  // event handling for the speed slider
  if (theEvent.isFrom(speedSlider)) {
    message="SPEED:"+theEvent.getValue();
  }

  // event handling for the speed slider
  if (theEvent.isFrom(manualSlider)) {

    for (int i = 0; i < qty_zones; i++) {
      //GUI.getController(nf(i, 2)).setValue(theValue);
      manualSliders[i].setValue(theEvent.getValue());
    }
  }

  for (int i = 0; i < qty_zones; i++) {
    if (theEvent.isFrom(manualSliders[i])) fromManSliders = true;
  }

  //println(theEvent);
  //if (message != null) println("Message is: "+message);
}
