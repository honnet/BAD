#include <SPI.h>
#include "common.h"
#include "Mirf.h"
#include "MIDI.h"
#include "nRF24L01.h"
#include "MirfHardwareSpiDriver.h"

#define PAYLOAD 6
#define LED1 7
#define LED2 6

void noteOn(int cmd, int pitch, int velocity);
void pitchBend(int channel, int pitch);

void setup()
{
  // Set MIDI baud rate:
  MIDI.begin();

  Mirf.spi = &MirfHardwareSpi;
  Mirf.cePin = CE;
  Mirf.csnPin = CSN;
  Mirf.init();
  Mirf.setRADDR(ADDR);
  Mirf.payload = PAYLOAD;
  Mirf.config();

  pinMode(LED1, OUTPUT);
  pinMode(LED2, OUTPUT);
}

void loop()
{
  static uint8_t buf[PAYLOAD];
  static int state[2] = {0};
  static int note[2] = {41, 42};
  static int led[2] = {LED1, LED2};
  static int lastPitch = 0;
  int pitch_x, pitch_y;

  if(Mirf.dataReady())
  {
    Mirf.getData(buf);

    for (int i = 0; i < 2; i++)
    {
      if (buf[i])
      {
        if (state[i] == 0)
        {
          MIDI.sendNoteOn(note[i], 255, 1);
          state[i] = 1;
          digitalWrite(led[i], HIGH);
        }
      }
      else
      {
        if (state[i] == 1)
        {
          MIDI.sendNoteOff(note[i], 0, 1);
          state[i] = 0;
          digitalWrite(led[i], LOW);
        }
      }
    }

    pitch_x = (buf[2] | (buf[3] << 8)) * 0x4000 / 1024 - 0x2000;
    pitch_y = (buf[4] | (buf[5] << 8)) * 0x4000 / 1024 - 0x2000;

    //if (pitch != lastPitch)
    //{
    MIDI.sendPitchBend(pitch_x, 1);
    //MIDI.sendPitchBend(pitch_y, 1);
      //}

      //lastPitch = pitch;

    Mirf.flushRx();
  }
}
