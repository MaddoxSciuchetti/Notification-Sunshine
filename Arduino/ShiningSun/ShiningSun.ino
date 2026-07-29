const int greenLEDPin = 9;
const int redLEDPin = 10;
const int blueLEDPin = 11;

const int redSensorPin = A0;
const int greenSensorPin = A1;
const int blueSensorPin = A2;

void setup() {
  Serial.begin(9600);

  pinMode(greenLEDPin, OUTPUT);
  pinMode(redLEDPin, OUTPUT);
  pinMode(blueLEDPin, OUTPUT);
}

void loop() {
  const int redSensorValue = analogRead(redSensorPin);
  delay(5);
  const int greenSensorValue = analogRead(greenSensorPin);
  delay(5);
  const int blueSensorValue = analogRead(blueSensorPin);

  const int redValue = redSensorValue / 4;
  const int greenValue = greenSensorValue / 4;
  const int blueValue = blueSensorValue / 4;

  analogWrite(redLEDPin, redValue);
  analogWrite(greenLEDPin, greenValue);
  analogWrite(blueLEDPin, blueValue);

  // A stable, machine-readable line for the macOS app.
  Serial.print("SUN:");
  Serial.print(redValue);
  Serial.print(",");
  Serial.print(greenValue);
  Serial.print(",");
  Serial.println(blueValue);

  // About four updates per second is responsive without flooding the serial port.
  delay(250);
}
