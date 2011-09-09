#include <SPI.h>
#include <Wire.h>
#include "common.h"
#include "Mirf.h"
#include "nRF24L01.h"
#include "MirfHardwareSpiDriver.h"
#include "vector.h"

#define DEBUG_LED
#define JOY_X 16
#define JOY_Y 17
#define N_PADS 4

#define MMA7660addr   0x4c
#define MMA7660_X     0x00
#define MMA7660_Y     0x01
#define MMA7660_Z     0x02
#define MMA7660_TILT  0x03
#define MMA7660_SRST  0x04
#define MMA7660_SPCNT 0x05
#define MMA7660_INTSU 0x06
#define MMA7660_MODE  0x07
#define MMA7660_SR    0x08
#define MMA7660_PDET  0x09
#define MMA7660_PD    0x0A

typedef enum {
  PAD1 = 18,
  PAD2 = 19,
  PAD3 = 20,
  PAD4 = 21,
} pads_t;

bool padsPressed = false;
bool padsStates[N_PADS] = {false};
bool joyPressed = true;
uint16_t joyValX = 0;
uint16_t joyValY = 0;

void hello();
void readPads();
void readJoy();
float readAccelero();

void mma7660_init(void)
{
  Wire.begin();
  Wire.beginTransmission( MMA7660addr);
  Wire.send(MMA7660_MODE);
  Wire.send(0x00);
  Wire.endTransmission();

  Wire.beginTransmission( MMA7660addr);
  Wire.send(MMA7660_SR);
  Wire.send(0x07);  //   Samples/Second Active and Auto-Sleep Mode
  Wire.endTransmission();

  Wire.beginTransmission( MMA7660addr);
  Wire.send(MMA7660_MODE);
  Wire.send(0x01);//active mode
  Wire.endTransmission();

}

void setup()
{
  // with a 3.3V supply we need 8MHz instead of 16MHz
  SET_CPU_FREQ;

  Serial.begin(115200);

  pinMode(LED, OUTPUT);
  hello();

  mma7660_init();        // join i2c bus (address optional for master)

  Mirf.spi = &MirfHardwareSpi;
  Mirf.cePin = CE;
  Mirf.csnPin = CSN;
  Mirf.init();
  Mirf.setTADDR((byte*)ADDR);
  Mirf.payload = PAYLOAD;
  Mirf.config();
}

void loop()
{
  static uint8_t buf[PAYLOAD];

  const uint8_t a = (readAccelero() + 1.0f) * (1 << 7) / 2 - 1;

  readPads();
  for (int i = 0; i < N_PADS; i++)
    buf[i] = padsStates[i] ? 1 : 0;

  readJoy();
  buf[N_PADS + 0] = (uint8_t)(joyValX >> 0);
  buf[N_PADS + 1] = (uint8_t)(joyValX >> 8);
  buf[N_PADS + 2] = (uint8_t)joyValY;
  buf[N_PADS + 3] = a;

#ifdef DEBUG_LED
  if (padsPressed || joyPressed)
    digitalWrite(LED, HIGH);
  else
    digitalWrite(LED, LOW);
#endif

  Mirf.send(buf);
  while(Mirf.isSending());
}

void readPads()
{
  padsPressed = false;
  for (int i = 0; i < N_PADS; i++)
  {
    if(digitalRead(PAD1 + i) == HIGH)
    {
      padsStates[i] = true;
      padsPressed = true;
    }
    else
      padsStates[i] = false;
  }
}

void readJoy()
{
  uint16_t newJoyValX = 16383 - analogRead(JOY_X) * (16384 / 1023);
  uint16_t newJoyValY = ABS(((analogRead(JOY_Y) >> 2) - 127));
  newJoyValY = newJoyValY > 127 ? 127 : newJoyValY;

  joyPressed = false;

  if (ABS(joyValX - newJoyValX) > (1 << 5))
  {
    joyValX = newJoyValX;
    joyPressed = true;
  }

  if (ABS(joyValY - newJoyValY) > (1 << 3))
  {
    joyValY = newJoyValY;
    joyPressed = true;
  }
}

float readAccelero()
{
  static float oldVal = 0.0f;
  unsigned char val[3];
  int count = 0;
  float newVal;
  val[0] = val[1] = val[2] = 64;
  Wire.requestFrom(0x4c, 3);

  while(Wire.available())
  {
    if(count < 3)
      while ( val[count] > 63 )  // reload the damn thing it is bad
        val[count] = Wire.receive();
    count++;
  }

  Vector ret;
  ret.x = ((char)(val[0] << 2)) / 4;
  ret.y = ((char)(val[1] << 2)) / 4;
  ret.z = ((char)(val[2] << 2)) / 4;
  ret.normalize();

  newVal = ret.y;

  //FIXME: Here the '+= oldVal' seems to set newVal to zero
  //       which is annoying... To be fixed...
  //       Values have to be filtered as they fluctuate a lot.
  //newVal += oldVal;
  //Serial.print("old:");
  //Serial.println(oldVal);
  //Serial.print("ret:");
  //Serial.println(ret.y);
  //Serial.print("new:");
  //Serial.println(newVal);

  oldVal = newVal;

  return newVal;
}

void hello()
{
  for (int i = 0; i < 6; i++)
  {
    digitalWrite(LED, HIGH);
    delay(50);
    digitalWrite(LED, LOW);
    delay(100);
  }
}

