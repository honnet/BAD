#include <SPI.h>
#include "Mirf.h"
#include "nRF24L01.h"
#include "MirfHardwareSpiDriver.h"

#define PAYLOAD 1
#define LED1 11

void setup()
{
  Mirf.spi = &MirfHardwareSpi;
  Mirf.cePin = 10;
  Mirf.csnPin = 9;
  Mirf.init();
  Mirf.setTADDR((byte*)"abcde");
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
  static uint8_t buf[PAYLOAD];

  buf[0] = 1;
  digitalWrite(LED1, HIGH);
  Mirf.send((byte*)buf);
  delay(200);
  while(Mirf.isSending());

  buf[0] = 0;
  digitalWrite(LED1, LOW);
  Mirf.send((byte*)buf);
  delay(200);
  while(Mirf.isSending());
}




