#ifndef COMMON_H
# define COMMON_H

#define CE 10
#define CSN 9
#define ADDR ((byte*)"mangu")

#define PAYLOAD 6
#define LED     11

#define CPU_PRESCALE(n) (CLKPR = 0x80, CLKPR = (n))

#endif
