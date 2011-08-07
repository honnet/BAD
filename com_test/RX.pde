#include <SPI.h>
#include "Mirf.h"
#include "nRF24L01.h"
#include "MirfHardwareSpiDriver.h"

#define LED1 11
#define PAYLOAD 1
byte data[PAYLOAD];


void setup()
{
  data[0] = 0;

  Mirf.spi = &MirfHardwareSpi;
  Mirf.cePin = 10;
  Mirf.csnPin = 9;
  Mirf.init();
  Mirf.setRADDR((byte*)"abcde");
  Mirf.payload = PAYLOAD;
  Mirf.config();

  pinMode(LED1, OUTPUT);
  digitalWrite(LED1, HIGH);
  delay(100);
  digitalWrite(LED1, LOW);
  delay(100);
  digitalWrite(LED1, HIGH);
  delay(100);
  digitalWrite(LED1, LOW);
  delay(100);
  digitalWrite(LED1, HIGH);
}

void loop()
{
  if(Mirf.dataReady())
  {
    Mirf.getData(data);

    Serial.print(data[0]);

    if (data[0] != 0)
    {
      digitalWrite(LED1, HIGH);
    }
    else
    {
      digitalWrite(LED1, LOW);
    }

    Mirf.flushRx();
  }
  delay(5);
}

