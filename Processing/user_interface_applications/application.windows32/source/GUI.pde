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
  manualSlider = GUI.addSlider("manual")
    .setPosition(GUIoriginX+manualOffsetX, GUIoriginY+manualOffsetY)
    .setSize(vSliderWidth, vSliderHeight)
    .setRange(0, 1) // values can range from big to small as well
    .setValue(0)
    ;
  GUI.getController("manual")
    .getValueLabel()
    .align(ControlP5.CENTER, ControlP5.TOP_OUTSIDE)
    .setPaddingX(0)
    ;
    
    // indicates the level of the manual light settings
    manualLevel = GUI.addSlider("level")
    .setPosition(GUIoriginX+manualOffsetX+60, GUIoriginY+manualOffsetY)
    .setSize(vSliderWidth, vSliderHeight)
    .setRange(0, 1) // values can range from big to small as well
    .setValue(0)
    ;
  GUI.getController("level")
    .getValueLabel()
    .align(ControlP5.CENTER, ControlP5.TOP_OUTSIDE)
    .setPaddingX(0)
    ;

  //// manual brightness slider
  //for (int i = 0; i < qty_zones; i++) {
  //  manualSliders[i] = GUI.addSlider(nf(i, 2))
  //    .setPosition(GUIoriginX+manualOffsetX+manualSlidersX+(manSlideBufferX*(1+i)), GUIoriginY+manualOffsetY+manualSlidersY+manSlideBufferY)
  //    .setSize(vSliderWidth/2, vSliderHeight)
  //    .setRange(0, 1) // values can range from big to small as well
  //    .setValue(0)
  //    ;
  //  GUI.getController(nf(i, 2))
  //    .getValueLabel()
  //    .align(ControlP5.CENTER, ControlP5.TOP_OUTSIDE)
  //    .setPaddingX(0)
  //    ;
  //}

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
  if(manualSlider.getValue() < 1){
    manualSlider.setValue(manualSlider.getValue()+0.1);
  } else if (manualSlider.getValue() > 1) {
    manualSlider.setValue(1);
  }
}

public void down(){
  if(manualSlider.getValue() > 0){
    manualSlider.setValue(manualSlider.getValue()-0.1);
  } else if (manualSlider.getValue() < 0) {
    manualSlider.setValue(0);
  }
}

public void on(){
  //masterTarget=1;
  manualSlider.setValue(1);
}

public void off(){
  //masterTarget=0;
  manualSlider.setValue(0);
}

public void wave(){
  message="WAVE";
}

public void rando(){
  manualSlider.setValue(random(1));
  modeSelect.setValue(int(random(6)+1));
  speedSlider.setValue(random(.0025,.025));
}

void controlEvent(ControlEvent theEvent) {

  // event handling for the mode radio
  if (theEvent.isFrom(modeSelect)) {
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

  // event handling for the speed slider
  if (theEvent.isFrom(speedSlider)) {
    client.write("SPEED:"+theEvent.getValue());
  }

  // event handling for the speed slider
  if (theEvent.isFrom(manualSlider)) {
    masterTarget=manualSlider.getValue();
  }

}
