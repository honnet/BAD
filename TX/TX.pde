#include <SPI.h>
#include "common.h"
#include "Mirf.h"
#include "nRF24L01.h"
#include "MirfHardwareSpiDriver.h"

#define LED     11
#define LED_PWM 12

enum {SWITCH1, SWITCH2, SWITCH3, SWITCH4, SWITCH_NUM};
char stateSwitch[SWITCH_NUM] = {0};

#define JOYSTK_X 4
#define JOYSTK_Y 5
char joystkValueX = 0;
char joystkValueY = 0;

void ledfeedback();
void triggerPad();
void readJoystk();

void setup()
{
  Mirf.spi = &MirfHardwareSpi;
  Mirf.cePin = CE;
  Mirf.csnPin = CSN;
  Mirf.init();
  Mirf.setTADDR(ADDR);
  Mirf.payload = PAYLOAD;
  Mirf.config();

  pinMode(LED, OUTPUT);
  pinMode(LED_PWM, OUTPUT);
  for (int i=SWITCH1; i<SWITCH_NUM; i++) // 0 to 3
    pinMode(i, INPUT);
  pinMode(JOYSTK_X, INPUT);
  pinMode(JOYSTK_Y, INPUT);
}

void loop()
{
  static uint8_t buf[PAYLOAD];

  triggerPad();
  readJoystk();

  for (int i=SWITCH1; i<SWITCH_NUM; i++) // 0 to 3
    buf[i] = stateSwitch[i];
  buf[4] = (uint8_t)(joystkValueX >> 2);
  buf[5] = (uint8_t)(joystkValueY >> 2);

  Mirf.send(buf);
  while(Mirf.isSending());
}

void triggerPad()
{
  char accu = 0;
  for (int i=SWITCH1; i<SWITCH_NUM; i++)
  {
    stateSwitch[i] = digitalRead(i);
    accu |= stateSwitch[i]; //switch the led on only if one of the state was high
  }
  digitalWrite(LED, accu);
}

void readJoystk()
{
  joystkValueX = analogRead(JOYSTK_X);
  joystkValueY = analogRead(JOYSTK_Y);

  analogWrite(LED_PWM, (joystkValueX+joystkValueY)>>3); // divide by 2**3
}


