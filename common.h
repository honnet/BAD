#ifndef COMMON_H
# define COMMON_H

#define CPU_PRESCALE(N) (CLKPR = 0x80, CLKPR = (N))

#if F_CPU == 8000000
# define SET_CPU_FREQ CPU_PRESCALE(0x01)
#elif F_CPU == 16000000
# define SET_CPU_FREQ
#else
# error "Unknown CPU frequency"
#endif

#define ABS(a) (((a) < 0) ? -(a) : (a))

#define CE 10
#define CSN 9
#define ADDR "B.A.D"

#define N_PADS 4
#define N_JOYS 1
#define PAYLOAD (N_PADS + 3 * N_JOYS)
#define LED 11

#endif
