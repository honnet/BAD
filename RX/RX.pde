#include <SPI.h>
#include "common.h"
#include "Mirf.h"
#include "nRF24L01.h"
#include "MirfHardwareSpiDriver.h"

#define CHANNEL 16

void hello();

void setup()
{
  // with a 3.3V supply we need 8MHz instead of 16MHz...
  SET_CPU_FREQ;

  pinMode(LED, OUTPUT);
  hello();

  Mirf.spi = &MirfHardwareSpi;
  Mirf.cePin = CE;
  Mirf.csnPin = CSN;
  Mirf.init();
  Mirf.setRADDR((byte*)ADDR);
  Mirf.payload = PAYLOAD;
  Mirf.config();
}

void loop()
{
  static uint8_t buf[PAYLOAD];

  static int padsNotes[N_PADS] = {42, 43, 44, 45};
  static bool padsStates[N_PADS] = {0};
  bool padsPressed = false;

  static int joyCtrls[2] = {14, 15};
  static uint8_t joyLastVals[2] = {0};
  uint8_t joyVals[2] = {0};
  bool pitchChanged = false;

  if(Mirf.dataReady())
  {
    Mirf.getData(buf);

    padsPressed = false;
    for (int pad = 0; pad < N_PADS; pad++)
    {
      if (buf[pad] && !padsStates[pad])
      {
        usbMIDI.sendNoteOn(padsNotes[pad], 255, CHANNEL);
        padsStates[pad] = true;
        padsPressed = true;
      }
      else if (padsStates[pad])
      {
        usbMIDI.sendNoteOff(padsNotes[pad], 0, CHANNEL);
        padsStates[pad] = false;
      }
    }

    joyVals[0] = (buf[N_PADS + 0] << 6) - 0x2000;
    joyVals[1] = (buf[N_PADS + 1] << 6) - 0x2000;
    // [ val * 0x4000 / 256 - 0x2000 ]

    if (joyVals[0] != joyLastVals[0] || joyVals[1] != joyLastVals[1])
    {
      usbMIDI.sendControlChange(joyCtrls[0], joyVals[0], CHANNEL);
      usbMIDI.sendControlChange(joyCtrls[1], joyVals[1], CHANNEL);
      joyLastVals[0] = joyVals[0];
      joyLastVals[1] = joyVals[1];
      pitchChanged = true;
    }

    usbMIDI.send_now();

    if (padsPressed || pitchChanged)
      digitalWrite(LED, HIGH);
    else
      digitalWrite(LED, LOW);

    Mirf.flushRx();
  }
}

void hello()
{
  for (uint8_t i=0; i<5; i++)
  {
    usbMIDI.sendNoteOn(42 + i, 255, CHANNEL);
    digitalWrite(LED, HIGH);
    delay(100);
    usbMIDI.sendNoteOff(42 + i, 255, CHANNEL);
    digitalWrite(LED, LOW);
    delay(50);
  }
}

