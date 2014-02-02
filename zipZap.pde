

/*
 * Base Example 
 *
 *   Sketch that features the basic building blocks of a Spacebrew client app.
 * 
 */

import spacebrew.*;


//local: 172.29.3.140
String server="sandbox.spacebrew.cc";
String name="Rafa FM_1";
String description ="This is set up to suscribe to mobile slider clients publishing range values";
//incoming range var
float inputX=30;    
float inputY=30;
float inputZ=30;

color c= color(0);


Spacebrew sb;

import beads.*; // import the beads library
AudioContext ac; // create our AudioContext
// declare our unit generators
WavePlayer modulator;
WavePlayer modulator2;
WavePlayer carrier;
WavePlayer carrier2;
WavePlayer carrier3;

Glide modulatorFrequency;
// our envelope and gain objects
Envelope gainEnvelope;
Gain synthGain;

// our delay objects
TapIn delayIn;
TapOut delayOut;
Gain delayGain;




void setup() {
  size(400, 300);

  // initialize our AudioContext
  ac = new AudioContext();
  // create the modulator, this WavePlayer will
  // control the frequency of the carrier

  //GLIDER\\
  modulatorFrequency = new Glide(ac, 20, 50);

  ///<<<<<<<
  modulator = new WavePlayer(ac, modulatorFrequency, 
  Buffer.SQUARE);
  // create a custom frequency modulation function
  Function frequencyModulation = new Function(modulator)
  {
    public float calculate() {
      // return x[0], scaled into an appropriate
      // frequency range
      return (x[0] * 200)  ;
    }
  };
  //another wave player for the second modulator with its own frequencyModulation function

  ///<<<<<<<
  modulator2 = new WavePlayer(ac, modulatorFrequency, Buffer.NOISE);
  //function to calculate frequency modulation, the return is store into carrier and carrier2
  Function frequencyModulation2 = new Function(modulator2)
  {
    public float calculate() {
      // return x[0], scaled into an appropriate 
      // frequency range
      return (x[0] * 100.0) + inputY/2;
    }
  };


  // create a 3rd WavePlayer, control the frequency
  // with the function created above
  ///<<<<<<<
  carrier = new WavePlayer(ac, frequencyModulation, Buffer.SQUARE);

  //and a 4th wave player for carrier2
  ///<<<<<<<
  carrier2=new WavePlayer(ac, frequencyModulation2, Buffer.SQUARE);

  // create the envelope object that will control the gain
  gainEnvelope = new Envelope(ac, 0);
  // create a Gain object, connect it to the gain envelope
  synthGain = new Gain(ac, 1, gainEnvelope);

  // set up our delay
  // create the delay input - the second parameter sets the
  // maximum delay time in milliseconds
  delayIn = new TapIn(ac, 2000);
  // connect the synthesizer to the delay
  delayIn.addInput(synthGain);
  // create the delay output - the final parameter is the
  // length of the initial delay time in milliseconds
  delayOut = new TapOut(ac, delayIn, 250.0);
  // the gain for our delay
  delayGain = new Gain(ac, 1, 0.50);
  // connect the delay output to the gain
  delayGain.addInput(delayOut);
  // To feed the delay back into itself, simply uncomment
  // this line.
  delayIn.addInput(delayGain);

  // connect the delay output to the AudioContext
  ac.out.addInput(delayGain);


  // connect the carrier to the Gain input
  synthGain.addInput(carrier);
  synthGain.addInput(carrier2);
  // connect the Gain output to the AudioContext
  ac.out.addInput(synthGain);
  ac.start(); // start audio processing



  // instantiate the sb variable
  sb = new Spacebrew( this );

  // add each thing you publish to
  //PARAMS: addPublish(name,type,default);
  //types: boolean,string,range
  //  sb.addPublish( "buttonPress", "boolean", false ); 
  sb.addPublish("xValue", "range", 0);
  sb.addPublish("yValue", "range", 0);
  sb.addPublish("zValue", "range", 0);

  //  sb.addPublish("mouseY", "range", 0);

  // add each thing you subscribe to
  // sb.addSubscribe( "color", "range" );
  //  sb.addSubscribe("buttonPress", "boolean");
  //  sb.addSubscribe("mouseMove", "boolean");
  sb.addSubscribe("x", "range");
  sb.addSubscribe("y", "range");
  sb.addSubscribe("z", "range");

  // connect to spacebrew
  sb.connect(server, name, description );
}

color fore = color(255, 102, 204);
color back = color(0, 0, 0);

/*
 * Just do the work straight into Processing's draw() method.
 */

float amplitude1;
float amplitude2;



void draw() {
  // do whatever you want to do here
  background(255);

//  inputX= mouseX*random(0, 3); 
//  inputY=map(mouseY, 0, height, 10, height-100);
//  inputZ=2;

  modulatorFrequency.setValue(inputY);

  amplitude1=random(0.3, 0.8);
  // amplitude1=map(inputZ,0,1023,.3,.9);
  // println("amplitude1 ="+amplitude1);

  // when the mouse button is pressed,
  // add a 50ms attack segment to the envelope
  // and a 300 ms decay segment to the  envelope
  gainEnvelope.addSegment(amplitude1, 300); // over 50ms rise to 0.8
  gainEnvelope.addSegment(0, 3, 50);
  gainEnvelope.addSegment(random(0.0, 0.1), 450); // in 300ms fall to 0.0
}

void mousePressed() {
  sb.send("buttonPress", true);

  float frequencyModulation3=mouseX* 5.0;
  //  Function frequencyModulation3 = new Function(modulator2)
  //  {
  //    public float calculate() {
  //      // return x[0], scaled into an appropriate
  //      // frequency range
  //      return (x[0] * 100.0 +100);
  //    }
  //  };
  carrier3=new WavePlayer(ac, frequencyModulation3, Buffer.SQUARE);
  synthGain.addInput(carrier3);

  // and a 300 ms decay segment to the envelope
  gainEnvelope.addSegment(0.4, 50);
  gainEnvelope.addSegment(0.0, 20);
}

void keyPressed() {
  if (key=='s') {
    sb.send("mouseX", mouseX);
    // sb.send("mouseY", mouseY);
    //    c=color(200);
  }
}

void mouseDragged() {
  sb.send("mouseX", mouseX);
  // sb.send("mouseY", mouseY);
  c=color(100);
  //  println("mouseX");
}



void mouseReleased() {
  sb.send("buttonPress", false);
}


void onRangeMessage( String name, int value ) {
  println("got range message " + name + " : " + value);
  if (name.equals("x")) {
    inputX=value;
  } 
  else if (name.equals("y")) {
    inputY=value;
  }
  else if (name.equals("z")) {
    inputZ=value;
  }
}






