class ArduGuitarConf {
    public class GuiConf {
  public String baseFile       = "Pickups1196x768.png",
      overlayFiles[] = {"neck1196x768.png",
            "middle1196x768.png",
            "bridgeNorth1196x768.png",
            "bridgeBoth1196x768.png"};
  public int nbOverlays = 4;
  
  public int textSizeInit= 48,
      textSizeEllipse = 32,
      textSizeVT = 54;

  public int bogus = -60;   // -60 => startup message for 1 second
  public int colorHues[] = {0, //red
          60, //yellow
          120, // green
          240, //blue
          300};  // violet
                              // O // turquoise
  public int colorSat  = 100,
      colorBrit = 100;

  public float ellipseHFactor = 1/10.0,
      ellipseXFactor = 15.0/16.0,
      ellipseWFactor = 1/8.0,
      nXF = 1/4.0,
      mXF = 1/2.0,
      bnXF = 5.0/8.0,
      bbXF= 7.0/8.0;

  public int configDelay = 750;
  
  public GuiConf(ArduGuitarConf.ModelConf mc){
     // overlays = new PImage[mc.nbPickups];
      //xRange = new int[mc.nbPickups];
     // yRange = new int[mc.nbPickups];      
  }
    }
    public class ModelConf {
  public int nbPickups = 4;

  public int currentPreset = 0;
  public int vol = 11,
      tone = 11,
      pv=11,
      pt=11;
  public ModelConf(){
  }
    }
    public class HalConf {
  public HalConf(ArduGuitarConf.ModelConf mc){
  }
    }
    public class PresetsConf {
  public int nbPresets;
  public String names[] = {"Rock",
         "Woman",
         "Jazz",
         "Comp",
         "Lead"};
  int defaultVT[][] = {{11,11},
           {11,0},
           {8,6},
           {8,11},
           {11,11}};
  boolean defaultSelectors[][] = {{false,false,false,true},
          {true,true,false,true},
          {true,false,false,false},
          {false,true,false,false},
          {true,true,false,true}};
      public String tableFileName = "/home/bob/temp/data.tsv";
        public String tableCols[] = { "name",
              "vol",
              "tone",
              "neck",
              "middle",
              "bNorth",
              "bBoth"};
  public PresetsConf(ArduGuitarConf.ModelConf mc){
      nbPresets = names.length;
  }
    }
    public class ProtocolConf {
  public String errorKey = "e";
  public ProtocolConf(ArduGuitarConf.ModelConf mc){
  }
    }
    public class BluetoothConf {
  public String btName = "linvor";
  //String btAddress = "00:12:11:19:08:54";  
  // linvor on-board Ibanez RG-140  -- doesn't work because of bug in Ketai???
  public BluetoothConf(ArduGuitarConf.ModelConf mc){
  }
    }
    public ModelConf mc;
    public GuiConf gc;
    public HalConf hc;
    public PresetsConf psc;
    public ProtocolConf pc;
    public BluetoothConf bc;
    
    public ArduGuitarConf() {
  mc = new ModelConf();
  gc = new GuiConf(mc);
  hc = new HalConf(mc);
  psc =  new PresetsConf(mc);
  pc = new ProtocolConf(mc);
  bc = new BluetoothConf(mc);
    }
}

ArduGuitarConf ac = new ArduGuitarConf();
