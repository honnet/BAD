#include <SPI.h>
#include "Mirf.h"
#include "nRF24L01.h"
#include "MirfHardwareSpiDriver.h"

#define PAYLOAD 6
#define LED1 5
#define LED2 6
#define LED3 3

#define SWITCH 2
int stateSwitch = LOW;

#define POTAR_X 0
#define POTAR_Y 1
int potarValueX = 0;
int potarValueY = 0;
#define POTAR_SWITCH 4
int potarSwitch = LOW;

void ledfeedback();
void triggerPad();
void readPotar();

void setup()
{
  Serial.begin(9600);

  Mirf.spi = &MirfHardwareSpi;
  Mirf.cePin = 8;
  Mirf.csnPin = 9;
  Mirf.init();
  Mirf.setTADDR((byte*)"mangu");
  Mirf.payload = PAYLOAD;
  Mirf.config();

  pinMode(LED1, OUTPUT);
  pinMode(LED2, OUTPUT);
  pinMode(LED3, OUTPUT);
  pinMode(SWITCH, INPUT);
  pinMode(POTAR_X, INPUT);
  pinMode(POTAR_Y, INPUT);
  pinMode(POTAR_SWITCH, INPUT);
}

void loop()
{
  static uint8_t buf[PAYLOAD];
  static uint8_t previousState = 0;
  uint8_t currentState = stateSwitch;

  triggerPad();
  readPotar();

  buf[0] = stateSwitch == HIGH ? 1 : 0;
  buf[1] = potarSwitch == LOW ? 1 : 0;
  buf[2] = (uint8_t)potarValueX;
  buf[3] = (uint8_t)(potarValueX >> 8);
  buf[4] = (uint8_t)potarValueY;
  buf[5] = (uint8_t)(potarValueY >> 8);

  Mirf.send(buf);
  while(Mirf.isSending());
}

void triggerPad()
{
  stateSwitch = digitalRead(SWITCH);

  if (stateSwitch == HIGH)
    analogWrite(LED1, 255);
  else
    analogWrite(LED1, 0);
}

void readPotar()
{
  potarValueX = analogRead(POTAR_X);
  potarValueY = analogRead(POTAR_Y);
  potarSwitch = digitalRead(POTAR_SWITCH);

  if (potarSwitch == LOW)
    analogWrite(LED1, 255);
  else
    analogWrite(LED1, 0);

  analogWrite(LED2, potarValueX / 4);
  analogWrite(LED3, potarValueY / 4);
}
