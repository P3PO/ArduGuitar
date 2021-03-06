// sliders

int rectV[] = {111,20,200,20};
int rectT[] = {rectV[x],4*rectV[y],rectV[dX],rectV[dY]};

boolean initSliders(ControlP5 cp5) {
  cp5.addSlider("volume")
     .setBroadcast(false) 
     .setPosition(rectV[x],rectV[y])
     .setSize(rectV[dX],rectV[dY])
     .setRange(0,5)
     .setValue(5)
     .setNumberOfTickMarks(6)
     //.setSliderMode(Slider.FLEXIBLE)
     .setSliderMode(Slider.FIX)
     .setColorActive(itemActiveColor)
     .setColorForeground(itemForegroundColor)
     .setBroadcast(true)
     ;
  // reposition the value and caption Labels for controller 'tone'
  cp5.getController("volume").getValueLabel().setVisible(false);
  cp5.getController("volume").getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);
  cp5.getController("volume").captionLabel().toUpperCase(false);
  cp5.getController("volume").getCaptionLabel().setFont(createFont("Free Sans",14));
  
  // add a vol/tone slider
  cp5.addSlider("tone")
     .setBroadcast(false)
     .setPosition(rectT[x],rectT[y])
     .setSize(rectT[dX],rectT[dY])
     .setRange(0,5)
     .setValue(5)
     .setNumberOfTickMarks(6)
     //.showTickMarks(false)
     //.setSliderMode(Slider.FLEXIBLE)
     .setSliderMode(Slider.FIX)
     .setColorActive(itemActiveColor)
     .setColorForeground(itemForegroundColor)
     .setBroadcast(true)
     ;
  // reposition the value and caption Labels for controller 'tone'
  cp5.getController("tone").getValueLabel().setVisible(false); 
  cp5.getController("tone").getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);
  cp5.getController("tone").captionLabel().toUpperCase(false);
  cp5.getController("tone").getCaptionLabel().setFont(createFont("Free Sans",14));
  
  arduinoSetVolume((int)currentVolume);
  arduinoSetTone((int)currentTone);
  println("Sliders initialized.");
  return true;
}

