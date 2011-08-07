#include <SPI.h>
#include "common.h"
#include "Mirf.h"
#include "nRF24L01.h"
#include "MirfHardwareSpiDriver.h"

enum {
  PAD1 = 16,
  PAD2 = 17,
  PAD3 = 18,
  PAD4 = 19,
  PAD_N = 4
};
char stateSwitch[PAD_N] = {0};

#define JOYSTK_X 14
#define JOYSTK_Y 13
char joystkValueX = 0;
char joystkValueY = 0;

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
  for (int i=0; i<PAD_N; i++)
    buf[i] = stateSwitch[i];

  readJoystk();
  buf[PAYLOAD-2] = joystkValueX;
  buf[PAYLOAD-1] = joystkValueY;

  Mirf.send(buf);
  while(Mirf.isSending());
}


void readPad()
{
  char accu = 0;
  for (int i=0; i<PAD_N; i++)
  {
    stateSwitch[i] = digitalRead(i+PAD1);
    accu |= stateSwitch[i]; //switch the led on only if one of the state was high
  }
  digitalWrite(LED, accu);
}

void readJoystk()
{
  joystkValueX = analogRead(JOYSTK_X) >> 2; // keep only 8 significant bits...
  joystkValueY = analogRead(JOYSTK_Y) >> 2; // ...out of the 10 obtained.
}

void hello()
{
  for (int i=0; i<6; i++)
  {
    digitalWrite(LED, HIGH);
    delay(50);
    digitalWrite(LED, LOW);
    delay(50);
  }
}
