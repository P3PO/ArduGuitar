/* ArduStomp_02
 * code to command the ARduGuitar from an arduino based stomp box.
 * integrating coms and BT
 */

#include <Arduino.h>

#include <outQueue.h>
#include <ArduCom.h>
#include <RN42autoConnect.h>
#include <SD.h>
#include <SDReader.h>

#include "confClass.h" 
#include "actuatorClass.h"

// minimum millis between button presses
#define MIN_TIME_BETWEEN_BUTTON_PRESSES 100

#define VUP_PIN 2
#define VDW_PIN 3
#define TUP_PIN 4
#define TDW_PIN 5
#define N_PIN   6
#define M_PIN   7
#define B_PN    8
#define P_PIN   9
#define A_PIN   A0

// for led shift register shifting
//Pin connected to latch pin (ST_CP) of 74HC595
#define latchPin (13)
//const byte latchPin = 13;
//Pin connected to clock pin (SH_CP) of 74HC595
//const byte clockPin = 12;
#define clockPin (12)
////Pin connected to Data in (DS) of 74HC595
//const byte dataPin = 11;
#define dataPin (11)

ArduComMaster *c;
/*
const int pins[]= {VUP_PIN,
                   VDW_PIN,
                   TUP_PIN,
                   TDW_PIN,
                   N_PIN,
                   M_PIN,
                   B_PN,
                   P_PIN,
                   A_PIN };
*/
const int nbButtons = 9;

confClass *conf;

char pFile[] = "data.tsv",
     aFile[] = "cycle.tsv";
     
PresetClass *p;
AutoClass   *a;
byte curPs;

const byte ledArraySize =24;
boolean leds[ledArraySize];

// these pairs say the LED starting index and how many there are in the button control group
const byte volLedIndex[2] = {1,5},   
           neckLedIndex[2] = {6,1},
           middleLedIndex[2] = {7,1},
           toneLedIndex[2] = {9,5},   
           bridgeLedIndex[2] = {14,2},   
           presetLedIndex[2] = {17,4},   
           autoLedIndex[2] = {21,1},   
           powerLedIndex[2] = {22,1},   
           connectLedIndex[2] = {23,1};

const byte *indexLis[] = { volLedIndex,
                           neckLedIndex,
                           middleLedIndex,
                           toneLedIndex,
                           bridgeLedIndex,  
                           presetLedIndex,
                           autoLedIndex,
                           powerLedIndex,  
                           connectLedIndex};
  
#define VOL     0
#define NECK    1
#define MIDDLE  2
#define TONE    3
#define BRIDGE  4
#define PRESET  5
#define AUTO    6
#define POWER   7
#define CONNECT 8

/////////////////////////


// return a point to the part of the array where the thing starts
boolean* getBools(byte indicator){
  return &leds[indexLis[indicator][0]];
}


// This method sends bits to the shift registers:
void registerWrite() {
  // turn off the output so the leds don't light up
  // while you're shifting bits:
  digitalWrite(latchPin, LOW);

  byte outgoing[] = {0,0,0};
  for (byte i =0;i<24;i++){
    if (leds[i]){
      outgoing[byte(i/8)] |= 1 <<(7 - (i%8));
    }
  }

  //Serial.println("outgoing[0] = " + String(outgoing[0]));
  //Serial.println("outgoing[1] = " + String(outgoing[1]));  
  //Serial.println("outgoing[2] = " + String(outgoing[2]));  
  
  for (char i = 2;i>-1 ;i--){
    shiftOut(dataPin, clockPin, LSBFIRST, outgoing[i]);
  }
  // turn on the output so the LEDs can light up:
  digitalWrite(latchPin, HIGH);
}

////////////////////////////////////////////////////////////
////////////////////// for debugging  //////////////////////
////////////////////////////////////////////////////////////
/// these show*Led* fucntions need to be updated to get rid of msg part
/////
/*
const String buttonNames[] = {"Vol Up",
                              "Vol Down",
                              "Tone Up",
                              "Tone Down",
                              "Neck",
                              "Middle",
                              "Bridge",
                              "Preset",
                              "Auto"};
                             
void showVolLeds(){
  String   s = "Vol: ";
  for (int i=0;i<indexLis[VOL][1];i++){
    s += String(getBools(VOL)[i])  +" ";
  }
  msg(s);
  showLeds();
}

void showNeckLed(){
  msg("Neck: " +String(*getBools(NECK)));
  showLeds();
}
void showMiddleLed(){
  msg("Middle: " +String(*getBools(MIDDLE)));
  showLeds();
}
void showBridgeLeds(){
  String s = "Bridge: ";
  for (int i=0;i<indexLis[BRIDGE][1];i++){
    s += String(getBools(BRIDGE)[i]) +" ";
  }
  msg(s);
  showLeds();
}  
void showToneLeds(){
  String  s = "Tone: ";
  for (int i=0;i<indexLis[TONE][1];i++){
    s += String(getBools(TONE)[i]) +" ";
  }
  msg(s);
  showLeds();
}
void showPresetLeds(){
String  s = "Preset: ";
  for (int i=0;i<indexLis[PRESET][1];i++){
    s += String(getBools(PRESET)[i]) +" ";
  }
  msg(s);
  showLeds();
}
void showAutoLed(){
  msg("Auto: " +String(*getBools(AUTO)));
  showLeds();
}

void showPowConLeds(){
  msg("Power: " +String(*getBools(POWER)));
  msg("Connected: " +String(*getBools(CONNECT)));
  showLeds();
}  
void showLeds(){
  registerWrite();
  msg("LEDs updated!");
}
*/
////////////////////////////////////////////////////////////
////////////////////// end debugging  //////////////////////
////////////////////////////////////////////////////////////

void vtLeds(boolean arr[],byte nb,byte level){
  // set leds for vol, tone, presets
  for(byte i=0;i<nb;i++){
    if (i< level){
      arr[i] = true;
    }
    else {
      arr[i] =  false;
    }
  }
}

long lastActionTime = 0;

boolean actionDelayOK(){
  // don't allow more than one button press per unit of minActionDelay!
  if(millis()-lastActionTime > MIN_TIME_BETWEEN_BUTTON_PRESSES){
    lastActionTime = millis();
    return true;
  }
  else{
    return false;
  }
}
void testAndSend(String s, void (*f)()){
  if (!s.equals("") || f == &registerWrite){
    (*f)();
    commBT(s);
  }
} 
void volUp(){
  //autoOff();
  String ret = conf->incVT(0,1);
  //vtLeds(volLed,5,conf->vtSettings[0].getVal());
  vtLeds(getBools(VOL),indexLis[VOL][1],conf->vtSettings[0].getVal());
  //testAndSend(ret,&showVolLeds);
  testAndSend(ret,&registerWrite);
}
void volDown(){
  //autoOff();
  String ret = conf->incVT(0,-1);
  vtLeds(getBools(VOL),indexLis[VOL][1],conf->vtSettings[0].getVal());
  //testAndSend(ret,&showVolLeds);
  testAndSend(ret,&registerWrite);
}
void toneUp(){
  //autoOff();
  String ret = conf->incVT(1,1);
  vtLeds(getBools(TONE),indexLis[TONE][1],conf->vtSettings[1].getVal());
  //testAndSend(ret,&showToneLeds);
  testAndSend(ret,&registerWrite);
}
void toneDown(){
  //autoOff();
  String ret = conf->incVT(1,-1);
  vtLeds(getBools(TONE),indexLis[TONE][1],conf->vtSettings[1].getVal());
  //testAndSend(ret,&showToneLeds);
  testAndSend(ret,&registerWrite);
}
void setNeckLed(){
  //*getBools(NECK)  = conf->pupSettings[0].getState() >0;
  *getBools(NECK)  = conf->pupSettings[0].getVal() >0;
}
void setMiddleLed(){
  //*getBools(MIDDLE) = conf->pupSettings[1].getState() >0;
  *getBools(MIDDLE) = conf->pupSettings[1].getVal() >0;
}
void setBridgeLed(){
  getBools(BRIDGE)[0] = getBools(BRIDGE)[1] = false;
  //switch(conf->pupSettings[2].getState()){
  switch(conf->pupSettings[2].getVal()){
    case 1:
      getBools(BRIDGE)[1] = true;
    case 2:
      getBools(BRIDGE)[0] = true;
  }
} 
void neck(){
  //autoOff();
  String ret = conf->incPup(0);
  setNeckLed();
  //testAndSend(ret,&showNeckLed);
  testAndSend(ret,&registerWrite);
}
void middle(){
  //autoOff();
  String ret = conf->incPup(1);
  setMiddleLed();
  //testAndSend(ret,&showMiddleLed);
  testAndSend(ret,&registerWrite);
}
void bridge(){
  //autoOff();
  String ret = conf->incPup(2);
  setBridgeLed();
  //testAndSend(ret,&showBridgeLeds);
  testAndSend(ret,&registerWrite);
}
void setPresetLed(){
  for(byte i = 0; i<NB_PRESETS;i++){
    getBools(PRESET)[i] = false;
  }
  getBools(PRESET)[curPs] = true;
  vtLeds(getBools(VOL),indexLis[VOL][1],conf->vtSettings[0].getVal());  
  vtLeds(getBools(TONE),indexLis[TONE][1],conf->vtSettings[1].getVal());
  setNeckLed();
  setMiddleLed();
  setBridgeLed();
}
void preset() {
  //autoOff();  
  String ret =  conf->incPreset(false);  
  setPresetLed();
  //testAndSend(ret,&showPresetLeds);
  testAndSend(ret,&registerWrite);
}

void setAutoLed(){
  *getBools(AUTO)  = a->running(); //conf->autoSettings.getState() >0;
}

void autoIt(){
  if (a->running()){
    autoOff();
    return;
  } 
  a->start(true);
  curPs = a->check();
  String ret = conf->getPresetString(curPs);
  setAutoLed();
  setPresetLed();
  //  testAndSend(ret,&showAutoLed);
  testAndSend(ret,&registerWrite);
}

void autoOff(){
  if (a->running()){
    // FIX
    a->start(false); // conf->incAuto();
    setAutoLed();
    //showAutoLed();
    registerWrite();
  }
}

/*
void msg(String s){
  Serial.print(s + '\n');
}
*/

/*
doerFunPtr buttonFuncs[]= { &volUp,     
                            &volDown,
                            &toneUp,
                            &toneDown,
                            &neck,
                            &middle,
                            &bridge,
                            &preset,
                            &autoIt};
*/                          
actuatorClass *actuators[nbButtons];
/*
actuatorClass actuators[] = {actuatorClass(VUP_PIN,&volUp),
                             actuatorClass(VDW_PIN,&volDown),
                             actuatorClass(TUP_PIN,&toneUp),
                             actuatorClass(TDW_PIN,&toneDown),
                             actuatorClass(N_PIN,&neck),
                             actuatorClass(M_PIN,&middle),
                             actuatorClass(B_PN,&bridge),
                             actuatorClass(P_PIN,&preset),
                             actuatorClass(A_PIN,&autoIt)
                           };
*/

doerFunPtr presetFunc = &preset,
           autoFunc   = &autoIt;

void setupActuators(){
  doerFunPtr buttonFuncs[]= { &volUp,     
                              &volDown,
                              &toneUp,
                              &toneDown,
                              &neck,
                              &middle,
                              &bridge,
                              presetFunc,
                              autoFunc};
  const byte pins[]= {VUP_PIN,
                     VDW_PIN,
                     TUP_PIN,
                     TDW_PIN,
                     N_PIN,
                     M_PIN,
                     B_PN,
                     P_PIN,
                     A_PIN };
                            
   for (byte i=0;i<nbButtons;i++){
     if(buttonFuncs[i]){
       actuators[i] = new actuatorClass(pins[i],buttonFuncs[i]);
     }
     else{
       actuators[i] =  NULL;
     }
   }
   //msg("Actuators setup!");
}

void setupData(){
  p = new PresetClass(pFile);
  //Serial.print("preset file id: ");
  //Serial.println((int)p);
  if(!p->parse()){
    presetFunc =  NULL;
    delete p;
  }
  else {
    curPs = 0;
  }
  a = new AutoClass(aFile,p);
  //Serial.print("auto file id: ");
  //Serial.println((int)a);
  if (!a->parse()){
    autoFunc = NULL;
    delete a;
  }
  conf = new confClass(p,a);
  // FIX THIS next call!
  //commBT(conf->presetString(curPs); //incPreset(true));
  vtLeds(getBools(VOL),indexLis[VOL][1],conf->vtSettings[0].getVal());
  vtLeds(getBools(TONE),indexLis[TONE][1],conf->vtSettings[1].getVal());
  setNeckLed();
  setMiddleLed();
  setBridgeLed();
  setPresetLed();
  //msg("Data setup!");
}

// needs to be updated for BT usage...
void commBT(String s){
  if(!s.equals(String(""))){
    //msg("BT Send: " + s);
    int len = s.length();
    char buf[len+1];
    s.toCharArray(buf,len+1);
    for (byte i=0; i<len;i+=5){
      c->enqueueMsg(&buf[i]);
    }
  }
}

/// needs to be updated to real version after debugging!
void  connectBT(){
  RN42autoConnect(&Serial1).setupRN42AndConnect();
  //msg("rn42 auto connect ok!");
  c = new ArduComMaster(&Serial1,ARDUCOM_MSGSIZE);
  //msg("c instatiated");
  c->doInit();
  //msg ("c initialized.");  
  *getBools(CONNECT) =  true;
  //msg("Connected!");
}

void powerOn(){
  *getBools(POWER) =  true;
  //msg("Power On!");
}

void checkAuto(){
  byte newPs = a->check();
  if (newPs != curPs){
    curPs = newPs;
    // FIX NEXT CALL
    String ret = ""; //conf->setPreset();
    setPresetLed();
    testAndSend(ret,&registerWrite);
  }
}

void setupShiftRegs(){
  pinMode(latchPin, OUTPUT);
  pinMode(dataPin, OUTPUT);  
  pinMode(clockPin, OUTPUT);
}

void byte2char(char c[], byte b){ // arg c better be big enough, remember that \0 will NOT be put on the end !
  if (b>99){
    c[0] = 48 + b/100;
    c[1] = 48 + (b%100)/10;
    c[2] = 48 + b%10;
  }
  else{
    c[0] = 48 + b/10;
    c[1] = 48 + b%10;
  }
}

int freeRam (){
  extern int __heap_start, *__brkval;
  int v;
  return (int) &v - (__brkval == 0 ? (int) &__heap_start : (int) __brkval);
}

void setup(){
  setupShiftRegs();
  for (byte i=0;i<ledArraySize;i++){
    leds[i] = false;
  }
  powerOn();          // ok
  //delay (5000);
  //Serial.begin(115200);
  //while(!Serial);
  //msg("Starting..."); // ok
  connectBT();        // ok
  setupData();        // ok
  setupActuators();   // ok
  //showLeds();         // ok  leds are set to show that we are ready for action!
  registerWrite();
  //msg("5 seconds delay...");
  //msg("looping...");
  //char c[3];
  //byte2char(c,255);
  Serial.begin(115200);
  delay(2000);
  Serial.println(freeRam());
}

void loop(){
  if (actionDelayOK()){
    for (byte i = 0;i<nbButtons-1;i++){
      if (actuators[i]){
        autoOff();
        actuators[i]->update();
      }
    }
    if(actuators[nbButtons-1]){
      actuators[nbButtons-1]->update();
    }
  }
  if (a->running()){
    checkAuto();
  }
  c->stepLoop();
}


