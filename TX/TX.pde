#include <SPI.h>
#include "Mirf.h"
#include "nRF24L01.h"
#include "MirfHardwareSpiDriver.h"

#define PAYLOAD sizeof(uint8_t)
#define LED1 5
#define LED2 6
#define LED3 3

#define SWITCH 2
int stateSwitch = 0;

#define POTAR 0
int potarValue = 0;

void setup()
{
  Serial.begin(9600);

  Mirf.spi = &MirfHardwareSpi;
  Mirf.cePin = 8;
  Mirf.csnPin = 9;
  Mirf.init();
  Mirf.setTADDR((byte*)"abcde");
  Mirf.payload = PAYLOAD;
  Mirf.config();

  pinMode(LED1, OUTPUT);
  pinMode(LED2, OUTPUT);
  pinMode(LED3, OUTPUT);
  pinMode(SWITCH, INPUT);
  pinMode(POTAR, INPUT);
}

void loop()
{
  static uint8_t buf[PAYLOAD];

  triggerPad();
  readPotar();

  if (stateSwitch == HIGH)
    buf[0] = 1;
  else
    buf[0] = 0;

  Mirf.send((byte*)buf);

  while(Mirf.isSending());
}

void ledfeedback()
{
  digitalWrite(LED3, LOW);
  delay(10);
  digitalWrite(LED3, HIGH);
  delay(10);
  digitalWrite(LED3, LOW);
}

void triggerPad(){
  stateSwitch = digitalRead(SWITCH);  // read input value
  if (stateSwitch == HIGH) { // check if the input is HIGH (button released)
    analogWrite(LED1, 255);  // turn LED OFF
  }
  else {
    analogWrite(LED1, 0);  // turn LED ON
  }
}

void readPotar(){
  //potarValue = analogRead(POTAR);  // read input value
  //analogWrite(LED2, potarValue/4);  // 10bits to 8 bits
}


