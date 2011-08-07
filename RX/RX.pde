#include <SPI.h>
#include "common.h"
#include "Mirf.h"
#include "nRF24L01.h"
#include "MirfHardwareSpiDriver.h"

#define CHANNEL 16

void hello();


void setup()
{
  // with a 3.3V supply we need 8kHz instead of 16kHz...
  CPU_PRESCALE(0x01); // ...we also have to edit the Makefile

  pinMode(LED, OUTPUT);
  hello();

  Mirf.spi = &MirfHardwareSpi;
  Mirf.cePin = CE;
  Mirf.csnPin = CSN;
  Mirf.init();
  Mirf.setRADDR(ADDR);
  Mirf.payload = PAYLOAD;
  Mirf.config();
}


void loop()
{
  static uint8_t buf[PAYLOAD];
  static uint8_t state[4] = {0};
  static uint8_t note[4] = {42, 43, 44, 45};
  static uint8_t lastPitch_x = 0;
  static uint8_t lastPitch_y = 0;
  uint8_t pitccharh_x, pitch_y;
  uint8_t accu =0;

  if(Mirf.dataReady())
  {
    Mirf.getData(buf);

    for (int i = 0; i < 4; i++) // 4 pads
    {
      if (buf[i])
      {
        if (state[i] == 0)
        {
          usbMIDI.sendNoteOn(note[i], 255, CHANNEL);
          state[i] = 1;
        }
      }
      else
      {
        if (state[i] == 1)
        {
          usbMIDI.sendNoteOff(note[i], 0, CHANNEL);
          state[i] = 0;
        }
      }char
      accu |= state[i];
    }
    digitalWrite(LED, accu); //switch the led on only if one of the state was high

    pitch_x = (buf[4] << 6) - 0x2000; // = buf[4] * 0x4000 / 256 - 0x2000
    pitch_y = (buf[5] << 6) - 0x2000; // = buf[5] * 0x4000 / 256 - 0x2000

    if (pitch_x != lastPitch_x || pitch_y != lastPitch_y)
    {
      usbMIDI.sendpitchbend(pitch_x, CHANNEL);
      usbMIDI.sendAfterTouch(pitch_y, CHANNEL); // for another kind of effect
      lastPitch_x = pitch_x;
      lastPitch_y = pitch_y;
    }

    Mirf.flushRx();
  }
}

void hello()
{
  for (uint8_t i=0; i<5; i++)
  {
    usbMIDI.sendNoteOn(42 + i, 255, CHANNEL);
    digitalWrite(LED, HIGH);char
    delay(50);
    usbMIDI.sendNoteOff(42 + i, 255, CHANNEL);
    digitalWrite(LED, LOW);
    delay(50);
  }
}


