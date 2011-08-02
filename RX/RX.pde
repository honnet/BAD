#include <SPI.h>
#include "Mirf.h"
#include "nRF24L01.h"
#include "MirfHardwareSpiDriver.h"

#define PAYLOAD sizeof(uint8_t)
#define LED1 7
#define LED2 6

void setup()
{
  Serial.begin(9600);

  Mirf.spi = &MirfHardwareSpi;
  Mirf.cePin = 8;
  Mirf.csnPin = 9;
  Mirf.init();
  Mirf.setRADDR((byte*)"abcde");
  Mirf.payload = PAYLOAD;
  Mirf.config();

  pinMode(LED1, OUTPUT);
  pinMode(LED2, OUTPUT);
}

void loop()
{
  static byte data[PAYLOAD];
  static int state = 0;

  if(Mirf.dataReady())
  {
    Mirf.getData(data);

    if (data[0])
    {
      if (state != 1)
      {
        digitalWrite(LED2, LOW);
        digitalWrite(LED1, HIGH);
        state = 1;
      }
    }
    else
    {
      if (state != 2)
      {
        digitalWrite(LED1, LOW);
        digitalWrite(LED2, HIGH);
        state = 2;
      }
    }

    Mirf.flushRx();
  }
}
