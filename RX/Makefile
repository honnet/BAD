#Project Settings
# Configuration Settings
DEFINES = -DSERIAL_DEBUG -DMAX_RS485PIN=2 -DSER_DEVICE_TYPE=SLAVE -DDEVICE_ID=1 -DDEBUG_BAUD_RATE=57600
# available macro variables:
# - BIG_ENDIAN

BINDIR = ../bin

#Generic settings!
# The arduino directories
ARDUINO_DIR=/usr/share/arduino
ARDUINO_LIB_PATH  = $(ARDUINO_DIR)/libraries
ARDUINO_CORE_PATH = $(ARDUINO_DIR)/hardware/arduino/cores/arduino
ARDUINO_TOOLS_PATH = $(ARDUINO_DIR)/hardware/tools

# The chip type:
# atmega328p > Uno
# atmega2560 > Mega
# atmega168 / atmega328 > Pro
MCU=atmega168

# Project name
TARGET=RX

# Used libraries. BUG: Now only one is allowed (more will make compile errors)
ARDUINO_LIBS=SPI

# Arduino CPU Speed
F_CPU=16000000

# Port where we can find the arduino (Normaly ttyACM* or ttyUSB*)
ARDUINO_PORT=/dev/ttyUSB1

#Flash Settings
# What programmer to use:
# - mega, uno = stk500v2
AVRDUDE_ARD_PROGRAMMER = stk500v1

# This can be a bitch.. newer devices have faster baudrate
# DON'T SET ANY BITRATE FOR THE NEW MEGA'S OR UNO'S
# - pro mini = 57600
# more to follow
AVRDUDE_ARD_BAUDRATE   = 19200

OBJDIR = .obj

# The actual make file
include ../Arduino.mk
