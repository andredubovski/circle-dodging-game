PImage bg;
float angle = 0;
float targetAngle = 0;
int lastTime = 0;
PVector circlePosition;
PVector answerPosition;
color bgc;

import processing.serial.*;

import websockets.*;

WebsocketClient wsc;
int now;
boolean newEllipse;

Serial myPort;  // The serial port
String command = "pulse 0 0 250";  // The command you want to send

void webSocketEvent(String msg){
  println(msg);
}

void setup() {
  fullScreen();
  bg = loadImage("denim.jpg");
  circlePosition = new PVector();
  answerPosition = new PVector();
  lastTime = millis();
  bgc = color(180, 150, 200);
  
  println(Serial.list());

  // Change the 0 to the correct index of your serial port in the list
  String portName = Serial.list()[3];

  // Open the serial port at 9600 baud rate
  myPort = new Serial(this, portName, 9600);
  
  wsc= new WebsocketClient(this, "ws://localhost:8025/john");
  now=millis();
  
  updateCirclePosition();
}



int testStep = 0;
void draw() {
  background(bgc);
  strokeWeight(0);
  fill(220, 190, 240);
  ellipse(width / 2, height / 2, height * 0.8, height * 0.8);
  
  textSize(16);
  fill(255);
  text("Steps: " + str(totalSteps), 30, 46);
  text("Pulse: " + str(pulseLength), 30, 66);
  text("Pause: " + str(pauseLength), 30, 86);

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

  if(testMode) {
    if (millis() - lastTime > 1260) {
      lastTime = millis();
      updateCirclePosition(testStep);
      bgc = color(180, 150, 200);
      testStep += 1;
      testStep = testStep % totalSteps;
    }
  } else {
    // Check if 3 seconds have passed to update the circle's position
    if (millis() - lastTime > 4500) {
      lastTime = millis();
      updateCirclePosition();
      bgc = color(180, 150, 200);
    }
    
    if (millis() - lastTime < 2700) {
      circleRadius = 0.4*height;
    } else {
      circleRadius = (1.2-1440/(1800-((float) millis() - lastTime-2700)))*height;
    }
    circlePosition.set(circleRadius*cos(circleAngle), circleRadius*sin(circleAngle));
    
    float offsetAngle = abs(degrees(circleAngle - targetAngle) - 90);
    while (offsetAngle > 150) {
      offsetAngle -= 180;
    }
    
    if(circleRadius < 50) {
      fill(255, 255, 0, 0.5);
      ellipse(answerPosition.x, answerPosition.y, 35, 35);  
      if(abs(offsetAngle) > 30) {
        bgc = color(200, 0, 20);
      } else {
        bgc = color(100, 200, 100);
      }
    }
  }
}

boolean isBallInvisible = false;
boolean isHapticsOn = false;
boolean testMode = false;
int totalSteps = 16;
int pulseLength = 85;
int pauseLength = 230;
void keyPressed() {
  if ((key == CODED && keyCode == LEFT)) {
    targetAngle -= radians(360.0/(float) totalSteps);
  } else if ((key == CODED && keyCode == RIGHT)) {
    targetAngle += radians(360.0/(float) totalSteps);
  } else if (key == 'w') {
    pulseLength += 5;
    command = "pulse " + str(int(circleStep + (16-totalSteps))) + " " + pulseLength + " " + pauseLength + "\n";
    myPort.write(command);
  } else if (key == 's') {
    pulseLength -= 5;
    command = "pulse " + str(int(circleStep + (16-totalSteps))) + " " + pulseLength + " " + pauseLength + "\n";
    myPort.write(command);
  } else if (key == 'd') {
    pauseLength += 5;
    command = "pulse " + str(int(circleStep + (16-totalSteps))) + " " + pulseLength + " " + pauseLength + "\n";
    myPort.write(command);
  } else if (key == 'a') {
    pauseLength -= 5;
    command = "pulse " + str(int(circleStep + (16-totalSteps))) + " " + pulseLength + " " + pauseLength + "\n";
    myPort.write(command);
  } else if (key == 'b') {
    isBallInvisible = !isBallInvisible;
  } else if (key == 'h') {
    isHapticsOn = !isHapticsOn;
    if(isHapticsOn) {
      command = "pulse " + str(int(circleStep + (16-totalSteps))) + " " + pulseLength + " " + pauseLength + "\n";
      myPort.write(command);
      myPort.bufferUntil('\n');
    } else {
      command = "pulse 0 0 315\n";
      myPort.write(command);
    }
  } else if (key == '6') {
    circleAngle = 11;
    angle = 0;
    targetAngle = 0;
    testStep = 0;
    totalSteps = 16;
  } else if (key == '5') {
    circleAngle = 11;
    angle = 0;
    targetAngle = 0;
    testStep = 0;
    totalSteps = 15;
  } else if (key == '4') {
    circleAngle = 11;
    angle = 0;
    targetAngle = 0;
    testStep = 0;
    totalSteps = 14;
  } else if (key == '3') {
    circleAngle = 11;
    angle = 0;
    targetAngle = 0;
    testStep = 0;
    totalSteps = 1;
  } else if (key == 't') {
    testMode = !testMode;
    testStep = 0;
  }
}

float circleAngle;
float circleRadius;
float circleStep;

void updateCirclePosition() {
  int steps = totalSteps; // Number of steps around the circumference
  int step = int(random(steps)); // Random step
  updateCirclePosition(step);
}

void updateCirclePosition(int step) {
  circleRadius = height * 0.4; // Radius of the main ellipse
  println(step);
  circleStep = (step + 1) % totalSteps;
  if (testMode) {
    circleAngle = TWO_PI / totalSteps * circleStep + radians(180);
  } else {
    circleAngle = TWO_PI / totalSteps * circleStep + radians(90); // Calculate the angle for the random step
  }
  if (circleAngle > TWO_PI) {
    circleAngle -= TWO_PI;    
  }
  circlePosition.set(circleRadius*cos(circleAngle), circleRadius*sin(circleAngle)); // Set the position of the circle
  answerPosition.set(circlePosition); // Set the position of the circle
  
  if(isHapticsOn) {
    command = "pulse " + str(int(circleStep + (16-totalSteps))) + " " + pulseLength + " " + pauseLength + "\n";
    myPort.write(command);
    myPort.bufferUntil('\n');
  } else {
    command = "pulse 0 0 315\n";
    myPort.write(command);
  }
}
