import processing.serial.*; // imports library for serial communication
import java.awt.event.KeyEvent; 
import java.io.IOException;

Serial myPort; 

String angle="";
String distance="";
String data="";
String noObject;
float pixsDistance;
int iAngle, iDistance;
int index1=0;
int index2=0;
PFont orcFont;

void setup() {
  size(1920, 1080); 
  smooth();
  myPort = new Serial(this, "COM6", 9600); // Using your working COM6 port
  myPort.bufferUntil('.'); 
  orcFont = loadFont("OCRAExtended-30.vlw");
}

void draw() {
  fill(98,245,31);
  textFont(orcFont);
  
  // Simulating motion blur
  noStroke();
  fill(0,4); 
  rect(0, 0, width, height); 
  
  fill(98,245,31); 
  
  // Draw the 360 radar components
  drawRadar(); 
  drawLine();
  drawObject();
  drawText();
}

void serialEvent (Serial myPort) { 
  try {
    data = myPort.readStringUntil('.');
    if (data != null) {
      data = data.substring(0, data.length()-1);
      index1 = data.indexOf(","); 
      if (index1 > -1) {
        angle = data.substring(0, index1); 
        distance = data.substring(index1+1, data.length()); 
        iAngle = int(angle);
        iDistance = int(distance);
      }
    }
  } catch(Exception e) {
    // Prevents crashes if serial data glitches
  }
}

void drawRadar() {
  pushMatrix();
  translate(960, 540); // Moves the center of the radar to the middle of the screen
  noFill();
  strokeWeight(2);
  stroke(98, 245, 31);
  
  // Draws full concentric circles instead of half arcs (Max radius is 450px to fit screen height)
  ellipse(0, 0, 900, 900);
  ellipse(0, 0, 700, 700);
  ellipse(0, 0, 500, 500);
  ellipse(0, 0, 300, 300);
  
  // Draws the spoke lines across the full 360 degrees
  for (int i = 0; i < 180; i += 30) {
    pushMatrix();
    rotate(radians(i));
    line(-450, 0, 450, 0);
    popMatrix();
  }
  popMatrix();
}

void drawLine() {
  pushMatrix();
  strokeWeight(9);
  stroke(30, 250, 60);
  translate(960, 540); // Center of the screen
  
  // Sweeps the line around the full circle
  line(0, 0, 450 * cos(radians(iAngle)), -450 * sin(radians(iAngle))); 
  popMatrix();
}

void drawObject() {
  pushMatrix();
  translate(960, 540); // Center of the screen
  strokeWeight(9);
  stroke(255, 10, 10); // Red color for objects
  
  // Re-scaled distance mapping (450px max radius / 40cm max distance = 11.25 pixels per cm)
  pixsDistance = iDistance * 11.25; 
  
  if(iDistance < 40) {
    // Draws the red object line blip
    line(pixsDistance * cos(radians(iAngle)), -pixsDistance * sin(radians(iAngle)), 450 * cos(radians(iAngle)), -450 * sin(radians(iAngle)));
  }
  popMatrix();
}

void drawText() { 
  pushMatrix();
  if(iDistance > 40) {
    noObject = "Out of Range";
  } else {
    noObject = "In Range";
  }
  
  // Bottom data dashboard block
  fill(0);
  noStroke();
  rect(0, 980, width, 100);
  
  fill(98, 245, 31);
  textSize(30);
  text("Object: " + noObject, 100, 1030);
  text("Angle: " + iAngle + " °", 850, 1030);
  text("Distance: " + (iDistance < 40 ? iDistance + " cm" : "---"), 1400, 1030);
  
  // Static grid distance labels placed near the center elements
  textSize(18);
  text("10cm", 965, 380);
  text("20cm", 965, 280);
  text("30cm", 965, 180);
  text("40cm", 965, 80);
  popMatrix();
}
