import org.firmata.*;
import cc.arduino.*;

import processing.serial.*;
import cc.arduino.*;

int W=1680; // width 
int H=1020;  // height 
float Pitch; 
float Bank; 
float Azimuth; 
float ArtificialHoizonMagnificationFactor=0.95; 
float CompassMagnificationFactor=0.85; 
float SpanAngle=120; 
int NumberOfScaleMajorDivisions; 
int NumberOfScaleMinorDivisions; 
PVector v1, v2; 
PImage img;

Serial port;
float Phi;    //Dimensional axis
float Theta;
float Psi;


void setup() { 
  size(1680, 1020); 
  rectMode(CENTER); 
  smooth(); 
  strokeCap(SQUARE);//Optional 
  println(Serial.list()); //Shows your connected serial ports
  port = new Serial(this, Serial.list()[2], 115200); 
  port.bufferUntil('\n'); 
  img = loadImage("Night Sky.png");
}

void draw() { 
  background(0); 
  translate(W/2, H/2.1);  
  MakeAnglesDependentOnMPU6050(); 
  Horizon(); 
  rotate(-Bank); 
  PitchScale(); 
  Axis(); 
  rotate(Bank); 
  Borders(); 
  Plane(); 
  ShowAngles(); 
}

//Reading the datas by Processing.
void serialEvent(Serial port) {
   String input = port.readStringUntil('\n');
  if(input != null){
   input = trim(input);
  String[] values = split(input, " ");
 if(values.length == 3){
  float phi = float(values[0]);
  float theta = float(values[1]); 
  float psi = float(values[2]); 
  print(phi);
  print(theta);
  println(psi);
  Phi = phi;
  Theta = theta;
  Psi = psi;
   }
  }
}

void MakeAnglesDependentOnMPU6050() { 
  Bank =-Phi/5; 
  Pitch=Theta*10; 
  Azimuth=Psi;
}

void Horizon() { 
  scale(ArtificialHoizonMagnificationFactor); 
  noStroke(); 
  image(img,-400,-500);
  //fill(0, 180, 255); 
  //rect(0, -100, 900, 1000); // Blue Sky
  fill(76, 56, 52); 
  rotate(-Bank);
  rect(0, 400+Pitch, 900, 800); // Ground
  rotate(Bank); 
  rotate(-PI-PI/6); 
  SpanAngle=120; 
  NumberOfScaleMajorDivisions=12; 
  NumberOfScaleMinorDivisions=24;  
  CircularScale(); 
  rotate(PI+PI/6); 
  rotate(-PI/6);  
  CircularScale(); 
  rotate(PI/6); 
}


// Determing line of plane horizon level
void Plane() { 
  fill(0); 
  strokeWeight(0.75); 
  stroke(100, 255, 100); 
  triangle(-20, 0, 20, 0, 0, 25); 
  rect(110, 0, 140, 20); 
  rect(-110, 0, 140, 20); 
}

void CircularScale() { 
  float GaugeWidth=800;  
  textSize(GaugeWidth/30); 
  float StrokeWidth=1; 
  float an; 
  float DivxPhasorCloser; 
  float DivxPhasorDistal; 
  float DivyPhasorCloser; 
  float DivyPhasorDistal; 
  strokeWeight(2*StrokeWidth); 
  stroke(255);
  float DivCloserPhasorLenght=GaugeWidth/2-GaugeWidth/9-StrokeWidth; 
  float DivDistalPhasorLenght=GaugeWidth/2-GaugeWidth/7.5-StrokeWidth;
  for (int Division=0;Division<NumberOfScaleMinorDivisions+1;Division++) 
  { 
    an=SpanAngle/2+Division*SpanAngle/NumberOfScaleMinorDivisions;  
    DivxPhasorCloser=DivCloserPhasorLenght*cos(radians(an)); 
    DivxPhasorDistal=DivDistalPhasorLenght*cos(radians(an)); 
    DivyPhasorCloser=DivCloserPhasorLenght*sin(radians(an)); 
    DivyPhasorDistal=DivDistalPhasorLenght*sin(radians(an));   
    line(DivxPhasorCloser, DivyPhasorCloser, DivxPhasorDistal, DivyPhasorDistal); 
  }
  DivCloserPhasorLenght=GaugeWidth/2-GaugeWidth/10-StrokeWidth; 
  DivDistalPhasorLenght=GaugeWidth/2-GaugeWidth/7.4-StrokeWidth;
  for (int Division=0;Division<NumberOfScaleMajorDivisions+1;Division++) 
  { 
    an=SpanAngle/2+Division*SpanAngle/NumberOfScaleMajorDivisions;  
    DivxPhasorCloser=DivCloserPhasorLenght*cos(radians(an)); 
    DivxPhasorDistal=DivDistalPhasorLenght*cos(radians(an)); 
    DivyPhasorCloser=DivCloserPhasorLenght*sin(radians(an)); 
    DivyPhasorDistal=DivDistalPhasorLenght*sin(radians(an)); 
    if (Division==NumberOfScaleMajorDivisions/2|Division==0|Division==NumberOfScaleMajorDivisions) 
    { 
      strokeWeight(15); 
      stroke(0); 
      line(DivxPhasorCloser, DivyPhasorCloser, DivxPhasorDistal, DivyPhasorDistal); 
      strokeWeight(8); 
      stroke(100, 255, 100); 
      line(DivxPhasorCloser, DivyPhasorCloser, DivxPhasorDistal, DivyPhasorDistal); 
    } 
    else 
    { 
      strokeWeight(3); 
      stroke(255); 
      line(DivxPhasorCloser, DivyPhasorCloser, DivxPhasorDistal, DivyPhasorDistal); 
    } 
  } 
}

void Axis() { 
  stroke(255, 0, 0); 
  strokeWeight(3); 
  line(-115, 0, 115, 0); 
  line(0, 280, 0, -280); 
  fill(0, 255, 0); 
  stroke(0); 
  triangle(0, -285, -10, -255, 10, -255); 
  triangle(0, 285, -10, 255, 10, 255); 
}

void ShowAngles() { 
  textSize(28); 
  fill(50); 
  noStroke(); 
  rect(-150, 420, 280, 50); // x-coord,y-coord, width, height
  rect(150, 420, 280, 50); 
  fill(254); 
  Pitch=Pitch/5; 
  int Pitch1=round(Pitch);  
  text("Pitch: "+Pitch1+" Deg", -30, 432, 490, 60); 
  text("Bank: "+Bank*100+" Deg", 270, 432, 490, 60); 
}

void Borders() { 
  noFill(); 
  stroke(0); 
  strokeWeight(400); 
  rect(0, 0, 1150, 1150); 
  strokeWeight(250); 
  ellipse(0, 2, 1000, 1000); 
  fill(0); 
  noStroke(); 
  rect(4*W/5, 0, W, 2*H); 
  rect(-4*W/5, 0, W, 2*H); 
}

// Angular scale dimensions
void PitchScale() {  
  stroke(255); 
  fill(255); 
  strokeWeight(3); 
  textSize(18); 
  textAlign(CENTER); 
  for (int i=-4;i<5;i++) 
  {  
    if ((i==0)==false) 
    { 
      line(110, 50*i, -110, 50*i); 
    }  
    text(""+i*10, 140, 50*i, 100, 30); 
    text(""+i*10, -140, 50*i, 100, 30); 
  } 
  textAlign(CORNER); 
  strokeWeight(2); 
  for (int i=-9;i<10;i++) 
  {  
    if ((i==0)==false) 
    {    
      line(25, 25*i, -25, 25*i); 
    } 
  } 
}