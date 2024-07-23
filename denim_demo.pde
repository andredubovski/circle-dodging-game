PImage bg;
float angle = 0;
float targetAngle = 0;
int lastTime = 0;
PVector circlePosition;
color bgc;

import processing.serial.*;

Serial myPort;  // The serial port
String command = "pulse 0 0 250";  // The command you want to send

void setup() {
  size(1280, 800);
  //fullScreen();
  bg = loadImage("denim.jpg");
  circlePosition = new PVector();
  lastTime = millis();
  updateCirclePosition();
  bgc = color(180, 150, 200);
  
  println(Serial.list());

  // Change the 0 to the correct index of your serial port in the list
  String portName = Serial.list()[3];

  // Open the serial port at 9600 baud rate
  myPort = new Serial(this, portName, 9600);
}

void draw() {
  background(bgc);
  strokeWeight(0);
  fill(220, 190, 240);
  ellipse(width / 2, height / 2, height * 0.8, height * 0.8);

  // Smoothly interpolate the angle towards the target angle
  angle = lerp(angle, targetAngle, 0.1);

  translate(width / 2, height / 2);
  rotate(angle);

  strokeWeight(2);
  fill(255);
  rectMode(CENTER);
  rect(-60, 0, 30, 100, 30, 0, 0, 30);
  rect(60, 0, 30, 100, 0, 30, 30, 0);
  
  rotate(-angle);
  // Draw the red circle at the calculated position
  fill(255, 0, 0);
  ellipseMode(CENTER);
  if (!isBallInvisible) {
    ellipse(circlePosition.x, circlePosition.y, 35, 35);
  }

  // Check if 3 seconds have passed to update the circle's position
  if (millis() - lastTime > 3000) {
    lastTime = millis();
    updateCirclePosition();
    myPort.write("pulse " + str(circleStep) + "60 190");
    bgc = color(180, 150, 200);
  }
  
  if (millis() - lastTime < 1200) {
    circleRadius = 0.4*height;
  } else {
    circleRadius = (1.2-1440/(1800-((float) millis() - lastTime-1200)))*height;
  }
  circlePosition.set(circleRadius*cos(circleAngle), circleRadius*sin(circleAngle));
  
  float offsetAngle = abs(degrees(circleAngle - targetAngle) - 90);
  while (offsetAngle > 150) {
    offsetAngle -= 180;
  }
  
  if(circleRadius < 50) {
    if(abs(offsetAngle) > 30) {
      bgc = color(200, 0, 20);
    } else {
      bgc = color(100, 200, 100);
    }
  }
}

boolean isBallInvisible = false;
boolean isHapticsOn = false;
void keyPressed() {
  if (key == 'a' || (key == CODED && keyCode == LEFT)) {
    targetAngle -= radians(22.5);
  } else if (key == 'd' || (key == CODED && keyCode == RIGHT)) {
    targetAngle += radians(22.5);
  } else if (key == 'b') {
    isBallInvisible = !isBallInvisible;
  } else if (key == 'h') {
    isHapticsOn = !isHapticsOn;
  }
}

float circleAngle;
float circleRadius;
float circleStep;

void updateCirclePosition() {
  circleRadius = height * 0.4; // Radius of the main ellipse
  int steps = 16; // Number of steps around the circumference
  int step = int(random(steps)); // Random step
  circleStep = step;
  circleAngle = TWO_PI / steps * step; // Calculate the angle for the random step
  circlePosition.set(circleRadius * cos(circleAngle), circleRadius * sin(circleAngle)); // Set the position of the circle
}
