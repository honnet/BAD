#include <SPI.h>
#include "common.h"
#include "Mirf.h"
#include "MIDI.h"
#include "nRF24L01.h"
#include "MirfHardwareSpiDriver.h"

#define LED 11

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

  pinMode(LED, OUTPUT);
}

void loop()
{
  static uint8_t buf[PAYLOAD];
  static int state[4] = {0};
  static int note[4] = {41, 42, 43, 44}; // 43 et 44 = OK ??? (1 note par pad ???)
  static int lastPitch = 0;
  int pitch_x, pitch_y;
  char accu =0;

  if(Mirf.dataReady())
  {
    Mirf.getData(buf);

    for (int i = 0; i < 3; i++) // 4 pads
    {
      if (buf[i])
      {
        if (state[i] == 0)
        {
          MIDI.sendNoteOn(note[i], 255, 1);
          state[i] = 1;
        }
      }
      else
      {
        if (state[i] == 1)
        {
          MIDI.sendNoteOff(note[i], 0, 1);
          state[i] = 0;
        }
      }
      accu |= state[i];
      digitalWrite(LED, accu); //switch the led on only if one of the state was high
    }

    pitch_x = buf[4] * 0x4000 / 256 - 0x2000; // VERIFIER PROTOCOLE !!!
    pitch_y = buf[5] * 0x4000 / 256 - 0x2000;

    //if (pitch != lastPitch)
    //{
    MIDI.sendPitchBend(pitch_x, 1);
    MIDI.sendPitchBend(pitch_y, 1);
    //}

    //lastPitch = pitch;

    Mirf.flushRx();
  }
}

