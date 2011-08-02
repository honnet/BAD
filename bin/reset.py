#! /usr/bin/env python
# Reset an Arduino board by toggling DTR.
# Usage: reset-arduino PORT

import sys, serial, time

br = 57600
if len(sys.argv) == 3:
    br = int(sys.argv[2])

ser = serial.Serial(sys.argv[1], br)

ser.setDTR(0)
time.sleep(0.1)
ser.setDTR(1)

ser.close()
