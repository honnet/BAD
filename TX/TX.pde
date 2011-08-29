#include <SPI.h>
#include "common.h"
#include "Mirf.h"
#include "nRF24L01.h"
#include "MirfHardwareSpiDriver.h"

#define ABS(a) (((a) < 0) ? -(a) : (a))

enum {
  PAD1 = 18,
  PAD2 = 19,
  PAD3 = 20,
  PAD4 = 21,
  PAD_N = 4
};
int8_t stateSwitch[PAD_N] = {0};

#define JOYSTK_X 16
#define JOYSTK_Y 17
int16_t joystkValueX = 0;
int16_t joystkValueY = 0;

void hello();
void readPad();
void readJoystk();


void setup()
{
  // with a 3.3V supply we need 8kHz instead of 16kHz
  CPU_PRESCALE(0x01); // ...we also have to edit the Makefile

  pinMode(LED, OUTPUT);
  hello();

  Mirf.spi = &MirfHardwareSpi;
  Mirf.cePin = CE;
  Mirf.csnPin = CSN;
  Mirf.init();
  Mirf.setTADDR(ADDR);
  Mirf.payload = PAYLOAD;
  Mirf.config();
}


void loop()
{
  static uint8_t buf[PAYLOAD];

  readPad();
  for (int8_t i=0; i<PAD_N; i++)
    buf[i] = stateSwitch[i];

  readJoystk();
  buf[PAYLOAD-2] = (uint8_t)joystkValueX;
  buf[PAYLOAD-1] = (uint8_t)joystkValueY;

  Mirf.send(buf);
  while(Mirf.isSending());
}


void readPad()
{
  uint8_t accu = 0;
  for (uint8_t i=0; i<PAD_N; i++)
  {
    stateSwitch[i] = digitalRead(i+PAD1);
    accu |= stateSwitch[i]; //switch the led on only if one of the state was high
  }
  digitalWrite(LED, accu);
}

void readJoystk()
{
  int8_t newJoystkValueX = analogRead(JOYSTK_X)>>2;
  int8_t newJoystkValueY = analogRead(JOYSTK_Y)>>2;
  const uint8_t THRESHOLD = 1<<3; //neglect up to the 3th LSB

  if ( ABS(joystkValueX - newJoystkValueX) > THRESHOLD ||
       ABS(joystkValueY - newJoystkValueY) > THRESHOLD )
  {
    joystkValueX = newJoystkValueX; // keep only 8 significant bits...
    joystkValueY = newJoystkValueY; // ...out of the 10 obtained.
  }
}

void hello()
{
  for (uint8_t i=0; i<6; i++)
  {
    digitalWrite(LED, HIGH);
    delay(50);
    digitalWrite(LED, LOW);
    delay(100);
  }
}

