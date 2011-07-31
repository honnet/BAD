#include <SPI.h>
#include "API.h"
#include "nRF24L01.h"

//***************************************************
#define TX_ADR_WIDTH    5   // 5 unsigned chars TX(RX) address width
#define TX_PLOAD_WIDTH  32  // 32 unsigned chars TX payload

unsigned char TX_ADDRESS[TX_ADR_WIDTH]  = 
{
  0x34,0x43,0x10,0x10,0x01
}; // Define a static TX address

unsigned char rx_buf[TX_PLOAD_WIDTH] = {0}; // initialize value
unsigned char tx_buf[TX_PLOAD_WIDTH] = {0};

const int LED= 7; //led visual feedback 
//***************************************************

void setup() 
{
  Serial.begin(9600);
  pinMode(CE,  OUTPUT);
  pinMode(CSN, OUTPUT);
  pinMode(IRQ, INPUT);
  SPI.begin();
  delay(50);
  init_io();                        // Initialize IO port
  unsigned char sstatus=SPI_Read(STATUS);
  Serial.println("*******************RX_Mode Start*************************");
  Serial.print("status = ");    
  // There is read the mode’s status register, the default value should be ‘E’
  Serial.println(sstatus,HEX);
  RX_Mode(); // set RX mode
  pinMode(LED,OUTPUT);
}

void loop() 
{
  // read register STATUS's value
  unsigned char status = SPI_Read(STATUS); 

  Serial.print("status = ");    
  // There is read the mode’s status register, the default value should be ‘E’
  Serial.println(status,HEX);     

  // if receive data ready (TX_DS) interrupt
  if(status & RX_DR)                                                 
  {
    // read playload to rx_buf
    SPI_Read_Buf(RD_RX_PLOAD, rx_buf, TX_PLOAD_WIDTH);             
    // clear RX_FIFO
    SPI_RW_Reg(FLUSH_RX,0);                                        
    for(int i=0; i<32; i++)
    {
      Serial.print(" ");
      // print rx_buf
      Serial.print(rx_buf[i],HEX);                              

      // digitalWrite(LED,HIGH); //receiving data visual feedback ... 
      // digitalWrite(LED,LOW); //receiving data visual feedback ... 
      analogWrite(LED,i*8); //receiving data visual feedback ... 
    }
    Serial.println(" ");
  }
  // clear RX_DR or TX_DS or MAX_RT interrupt flag
  SPI_RW_Reg(WRITE_REG+STATUS,status);                             
}

//**************************************************
// Function: init_io();
// Description:
// flash led one time,chip enable(ready to TX or RX Mode),
// Spi disable,Spi clock line init high
//**************************************************
void init_io(void)
{
  digitalWrite(IRQ, 0);
  digitalWrite(CE, 0);			// chip enable
  digitalWrite(CSN, 1);                 // Spi disable	
}

/************************************************************************
**   * Function: SPI_RW();
 * 
 * Description:
 * Writes one unsigned char to nRF24L01, and return the unsigned char read
 * from nRF24L01 during write, according to SPI protocol
************************************************************************/
unsigned char SPI_RW(unsigned char Byte)
{
  return SPI.transfer(Byte);
}

/**************************************************/

/**************************************************
 * Function: SPI_RW_Reg();
 * 
 * Description:
 * Writes value 'value' to register 'reg'
/**************************************************/
unsigned char SPI_RW_Reg(unsigned char reg, unsigned char value)
{
  unsigned char status;

  digitalWrite(CSN, 0);                // CSN low, init SPI transaction
  SPI_RW(reg);                         // select register
  SPI_RW(value);                       // ..and write value to it..
  digitalWrite(CSN, 1);                // CSN high again

  return(status);                      // return nRF24L01 status unsigned char
}
/**************************************************/

/**************************************************
 * Function: SPI_Read();
 * 
 * Description:
 * Read one unsigned char from nRF24L01 register, 'reg'
/**************************************************/
unsigned char SPI_Read(unsigned char reg)
{
  unsigned char reg_val;

  digitalWrite(CSN, 0);            // CSN low, initialize SPI communication...
  SPI_RW(reg);                     // Select register to read from..
  reg_val = SPI_RW(0);             // ..then read register value
  digitalWrite(CSN, 1);            // CSN high, terminate SPI communication

  return(reg_val);                 // return register value
}
/**************************************************/

/**************************************************
 * Function: SPI_Read_Buf();
 * 
 * Description:
 * Reads 'unsigned chars' #of unsigned chars from register 'reg'
 * Typically used to read RX payload, Rx/Tx address
/**************************************************/
unsigned char SPI_Read_Buf(unsigned char reg,
                           unsigned char *pBuf,
                           unsigned char bytes)
{
  unsigned char sstatus,i;

  digitalWrite(CSN, 0);   // Set CSN low, init SPI tranaction
  sstatus = SPI_RW(reg);  // Select register to write to and read status uchar

  for(i=0;i<bytes;i++)
  {
    // Perform SPI_RW to read unsigned char from nRF24L01
    pBuf[i] = SPI_RW(0);    
  }

  digitalWrite(CSN, 1);   // Set CSN high again

  return(sstatus);        // return nRF24L01 status unsigned char
}
/**************************************************/

/**************************************************
 * Function: SPI_Write_Buf();
 * 
 * Description:
 * Writes contents of buffer '*pBuf' to nRF24L01
 * Typically used to write TX payload, Rx/Tx address
/**************************************************/
unsigned char SPI_Write_Buf(unsigned char reg,
                            unsigned char *pBuf,
                            unsigned char bytes)
{
  unsigned char sstatus,i;

  digitalWrite(CSN, 0);  // Set CSN low, init SPI tranaction
  sstatus = SPI_RW(reg); // Select register to write to and read status uchar
  for(i=0;i<bytes; i++)  // then write all unsigned char in buffer(*pBuf)
  {
    SPI_RW(*pBuf++);
  }
  digitalWrite(CSN, 1);  // Set CSN high again
  return(sstatus);       // return nRF24L01 status unsigned char
}
/**************************************************/

void RX_Mode(void)
{
  digitalWrite(CE, 0);

  // Use the same address on the RX device as the TX device
  SPI_Write_Buf(WRITE_REG + RX_ADDR_P0, TX_ADDRESS, TX_ADR_WIDTH); 
  SPI_RW_Reg(WRITE_REG + EN_AA, 0x01);      // Enable Auto.Ack:Pipe0
  SPI_RW_Reg(WRITE_REG + EN_RXADDR, 0x01);  // Enable Pipe0
  SPI_RW_Reg(WRITE_REG + RF_CH, 40);        // Select RF channel 40
  // Select same RX payload width as TX Payload width
  SPI_RW_Reg(WRITE_REG + RX_PW_P0, TX_PLOAD_WIDTH);
  // TX_PWR:0dBm, Datarate:2Mbps, LNA:HCURR
  SPI_RW_Reg(WRITE_REG + RF_SETUP, 0x07);   
  // Set PWR_UP bit, enable CRC(2 unsigned chars) & Prim:RX. RX_DR enabled..
  SPI_RW_Reg(WRITE_REG + CONFIG, 0x0f);     
  // Set CE pin high to enable RX device
  digitalWrite(CE, 1);                             
  //  This device is now ready to receive one packet of 16 unsigned chars
  // payload from a TX device sending to address
  // '3443101001', with auto acknowledgment, r, transmit count of 10,
  // RF channel 40 and datarate = 2Mbps.
}
