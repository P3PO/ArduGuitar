class ArduGuitarConf {
    public class GuiConf {
	public String 
	    baseFile       = "Pickups1196x768.png",
	    overlayFiles[] = {"neck1196x768.png",
			      "middle1196x768.png",
			      "bridgeNorth1196x768.png",
			      "bridgeBoth1196x768.png"};
	public int nbOverlays;
	public int textSizeInit= 48,
	    textSizeEllipse = 32,
	    textSizeVT = 54;

	public int bogus = -60;   // -60 => startup message for 1 second 
	// isConfiguring now handles this
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

	public int strokeWeight = 4;

	public GuiConf(ArduGuitarConf.ModelConf mc){
	    //overlays = new PImage[mc.nbPickups];
	    nbOverlays= overlayFiles.length;
	}
    }
    public class ModelConf {
	public int nbPickups = 4;
	public int vt[] = {11, 11},
	    minVT = 0,
	    maxVT = 11;
	public ModelConf(){
	}
    }
    public class HalConf {
        public int configDelay = 750;
	public float vtFactor = 5.0/11.0;
	public String volPins[] = {"09","10","12"},
	    tonePin   = "11",
	    selectorPins[]   = {"02", //neck
				"03", // middlePin
				"05",  // splitPin
				"04"}, //bridgePin

	    onOff[] = {"255","000"}, // true, false
	    // this is the factor used to convert Gui scale vol and tone on [0,11]
	    // to Arduino scale on [0,5]
	    // Model.guiVTMax, and the denominator Model.arduinoVTMax
	    // vol levels: [0,1,2,3,4,5]
	    volPWM[][]  = {{"000","012","014","018","027","255"},
			   // volPWM[0]-> volPins[0]
			   {"255","030","020","015","013","000"},
			   // volPWM[1]-> volPins[1]
			   {"000","000","000","000","000","255"}},  
	                   // 3rd vactrol for max volume
	                   // volPWM[2]-> volPins[2]
	    // tone levels: [0,1,2,3,4,5]
	    tonePWM[] = {"255","090","046","027","017","000"};

	public HalConf(ArduGuitarConf.ModelConf mc){
	}
    }
    public class PresetsConf {
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
	public String tableFileName = "//sdcard/ArduGuitar/data.tsv";
	public String tableCols[] = { "name",
				      "vol",
				      "tone",
				      "neck",
				      "middle",
				      "bNorth",
				      "bBoth"};
	public PresetsConf(ArduGuitarConf.ModelConf mc){
	}
    }
    public class BluetoothConf {
	public int errorRecoveryDelay = 50;
	public String errorKey = "e";
	public String btName = "no bluetooth module";

	//String btAddress = "00:12:11:19:08:54";  
	// linvor on-board Ibanez RG-140  -- 
	// doesn't work because of bug in Ketai???
	public BluetoothConf(ArduGuitarConf.ModelConf mc){
	}
    }
    public ModelConf mc;
    public GuiConf gc;
    public HalConf hc;
    public PresetsConf psc;
    public BluetoothConf bc;
    
    public ArduGuitarConf() {
	mc = new ModelConf();
	gc = new GuiConf(mc);
	hc = new HalConf(mc);
	psc =  new PresetsConf(mc);
	bc = new BluetoothConf(mc);
    }
}

ArduGuitarConf ac = new ArduGuitarConf();
