/*
  Android ArduGuitar 100 good to go!  
  version reserved for testing...
*/

////////////////////////////////////////////////////////////

//required for BT enabling on startup
import android.content.Intent;
import android.os.Bundle;
import android.view.KeyEvent;
import android.view.MotionEvent;

import java.util.concurrent.*;  // for the sync queue

import ketai.net.bluetooth.*;
import ketai.net.*;
import ketai.ui.*;

class ArduGuitarGui {
    ArduGuitarConf.GuiConf conf;
    color colors[];    

    public KetaiGesture gesture;
    public KetaiVibrate vibe;

    PImage base;
    PImage overlays[];
    
    boolean down = false;  

    public int 
        pv,
	pt,
	xI = 0,
	yI = 0,
	xRange[],
	yRange[],
	currentPreset = 0,
        bogus;
  
    public ArduGuitarGui(ArduGuitarConf arduConf, KetaiGesture g, KetaiVibrate v){
        //println("creating gui instance.");
	conf = arduConf.gc;
        //println("conf created.");

        xRange = new int[arduConf.mc.nbPickups];
        //println("xRange created.");
        yRange = new int[arduConf.mc.nbPickups];      
        //println("yRange created.");
        gesture = g;
        vibe = v;
        bogus = conf.bogus;
	//println("about to do colormode.");
        colorMode(HSB, 359, 100, 100);
	smooth();
	fill(255);
	noStroke();
        //println("about to load images.");
	loadImages();
	ellipseMode(CENTER);
        //println("exiting gui constructor.");
    }
    void finishInit(){
      //println("about to call model methods....");
      pv = model.vol();
      pt = model.tone();
      colors = new color[model.presets.nbPresets()];
      //println("length of colors:" + colors.length);
      for (int i=0;i<colors.length;i++){
        colors[i] = color(conf.colorHues[i],conf.colorSat,conf.colorBrit);
      }
    }
    void loadImages(){
	base = loadImage(conf.baseFile);
	overlays = new PImage[conf.nbOverlays];
	for (int i=0; i<conf.nbOverlays ;i++){
	    overlays[i] = loadImage(conf.overlayFiles[i]);
	}  
    }  
    
    void draw(){
	background(0,0,0,0);
	drawPickups();
	drawPresetButtons();
	drawVT();
    }
    
    void drawPickups(){
	image(base,
              0,
              0,
              width, 
              height);
	
	for (int i=0;i<model.selectorsVec.length;i++){
	    if (model.selectorsVec[i])
		image(overlays[i],
                      0,
                      0,
                      width,
                      height);

	}
    }

    void drawPresetButtons(){
	int yEllipse = round(height*conf.ellipseHFactor), 
	    yText = 0,
	    xEllipse = round(width*conf.ellipseXFactor),
	    wEllipse = round(width*conf.ellipseWFactor),
	    yInc = round(height*2*conf.ellipseHFactor);
	
	textSize(conf.textSizeEllipse);
	for (int i =0;i<model.presets.nbPresets();i++){
	    stroke(colors[i]);
	    strokeWeight(conf.strokeWeight);
	    fill(0,0,0,0);
	    if (currentPreset==i){
		fill(colors[i]);
	    }
	    ellipse(xEllipse,yEllipse,wEllipse,yInc/2);
	    fill(color((hue(colors[i])+180)%360,conf.colorSat,conf.colorBrit));
	    textAlign(CENTER,CENTER);
	    text(model.presets.presetNames[i],xEllipse,yText+yInc/2);
	    noStroke();
	    yEllipse += yInc;
	    yText += yInc;
	    fill(0,0,0,0);
	}
    }

  void drawVT(){
    fill(0,0,100);

    textAlign(CENTER,TOP);
    textSize(conf.textSizeVT);
    text(vtString("vol: ",model.vol()),width/2,2); 

    textAlign(CENTER,BOTTOM);
    text(vtString("tone: ",model.tone()),width/2,height-2);
    fill(0,0,0,0);
  }
    String vtString(String vt, int val) {
	String res = vt;
	if (val<10){
	    vt +=" ";
	}
	return vt + val;
    }
}

ArduGuitarModel model;
ArduGuitarGui gui;

void setup() {
     orientation(LANDSCAPE);
     //println("oreintation landscape.");
     KetaiGesture ges = new KetaiGesture(this);
     KetaiVibrate vib = new KetaiVibrate(this);    
     model =  new ArduGuitarModel(ac,ges,vib);
     //println("created model.");
     gui = model.gui;
     gui.finishInit();
     println("leaving setup...");     
}

void connectingMsg(){
    background(0,0,0);
    fill(0,0,100);
    textAlign(CENTER);
    textSize(ac.gc.textSizeInit);
    stroke(0,0,ac.gc.colorBrit);
    text("Connecting to " + ac.bc.btName +"...",width/2,ac.gc.textSizeInit);  
    // will be overwritten by background()...
    gui.bogus++;
}

void draw() {
    if (gui.bogus<0){
     connectingMsg();
    } 
    else if (model.hal.isConfiguring){
        if(model.hal.doConnect()){
          model.doPreset(model.currentPresetName);
        }
    }
    else {  // we're connected!
	gui.draw();
    }
}

void onTap(float x, float y){       
    if (model.hal.isConfiguring){
	return;
    }
    boolean sendPickupsFlag = true;
    
    if (x < width*ac.gc.nXF) {
	model.setSelector(0, !model.selector(0));;
    }
    else if (x < width*ac.gc.mXF) {   
	model.setSelector(1, !model.selector(1));
    }
    else if (x < width*ac.gc.bnXF) {
	model.setSelector(2, !model.selector(2));
	if (model.selector(2)){
	    model.setSelector(3,false);
	}
    }
    else if (x < width*ac.gc.bbXF){
	model.setSelector(3, !model.selector(3));
	if (model.selector(3)){
	    model.setSelector(2,false);
	}
    }
    else {
	for (int i=0;i<model.presets.nbPresets();i++){
	    if (y < height*(i+1)/model.presets.nbPresets()) {
		//println("color selected: " + i);
		gui.currentPreset = i;
                model.doPreset(model.presets.presetNames[i]);
		break;
	    }
	}
    }
}

void onLongPress(float x, float y){
    if (model.hal.isConfiguring){
	return;
    }
    if (x < width*ac.gc.bbXF) {
	//println(" doAllOnOff!");
	model.toggleSelectors();
    }
    else {
	saveToPreset(x,y);
	gui.vibe.vibrate(1000);
	//println("vibrate!");    
    }
}

void keyPressed() {
    if (model.hal.isConfiguring){
	return;
    }
    if (key == CODED && keyCode == MENU) {
	//println("Maine-Menu press!");
        model.presets.unload();
        gui.vibe.vibrate(1000);
    }
}

void saveToPreset(float x,float y){
  int selected = 0;
  for (int i=0;i< model.presets.nbPresets();i++){
      if (y < height*(i+1)/model.presets.nbPresets()) {
      //println("color selected: " + i);
      selected = i;
      break;
    }
  }
  saveToPreset(selected);
  onTap(x,y);
}
  
void saveToPreset(int i) {
    Preset p = model.presets.get(model.presets.presetNames[i]);
    p.setVol(model.vol());
    p.setTone(model.tone());
    p.setSelectors(model.selectors());
    gui.vibe.vibrate(1000);
    //println("Preset: " + model.presets.presetNames[i] + " updated!");
}  
  
void mousePressed() {
    if (model.hal.isConfiguring){
	return;
    }
    if(!gui.down){
	gui.xI = mouseX;
	gui.yI = mouseY;
	gui.pv = model.vol();
	gui.pt = model.tone();
	gui.down = true;
    }
    //println("pressed");
}

void mouseDragged(){
    if (model.hal.isConfiguring){
	return;
    }
    if (gui.xI>=width*ac.gc.bbXF){
	return;
    }
    checkDirection();
    model.setVol(constrain(round(map(mouseX - gui.xI,
				     gui.xRange[0],
				     gui.xRange[1],
				     gui.xRange[2],
				     gui.xRange[3])),
			   ac.mc.minVT,ac.mc.maxVT));
    model.setTone(constrain(round(map(mouseY - gui.yI, 
				      gui.yRange[0],
				      gui.yRange[1],
				      gui.yRange[2],
				      gui.yRange[3])),
			    ac.mc.minVT,ac.mc.maxVT));
}

void checkDirection(){
    if (mouseX>=gui.xI){
	gui.xRange[0] = 0;
	gui.xRange[1] = width-gui.xI;
	gui.xRange[2] = gui.pv;
	gui.xRange[3] = ac.mc.maxVT;
    
    }
    else{
	gui.xRange[0] = -gui.xI;
	gui.xRange[1] = 0;
	gui.xRange[2] = 0;
	gui.xRange[3] = gui.pv;
    }
    if (mouseY>=gui.yI){
	gui.yRange[0] = ac.mc.minVT;
	gui.yRange[1] = height-gui.yI;
	gui.yRange[2] = gui.pt;
	gui.yRange[3] = ac.mc.minVT;
    
    }
    else{
	gui.yRange[0] = ac.mc.minVT;
	gui.yRange[1] = -gui.yI;
	gui.yRange[2] = gui.pt;
	gui.yRange[3] = ac.mc.maxVT;
    }
}

void mouseReleased() {
    gui.down = false;
    //println("released");
}

public boolean surfaceTouchEvent(MotionEvent event) {
    //call to keep mouseX, mouseY, etc updated
    super.surfaceTouchEvent(event);
    //forward event to class for processing
    return gui.gesture.surfaceTouchEvent(event);
}

