# Teensyduino Core Library
# http://www.pjrc.com/teensy/
# Copyright (c) 2019 PJRC.COM, LLC.
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# 1. The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# 2. If the Software is incorporated into a build system that allows
# selection among a list of target devices, then similar target
# devices manufactured by PJRC.COM must be included in the list of
# target devices and selectable in the same manner.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
# BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
# ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.


# Use these lines for Teensy 4.0
MCU = IMXRT1062
MCU_LD = ${COREPATH}/imxrt1062.ld
MCU_DEF = ARDUINO_TEENSY40
PLATFORM := teensy4

# Use these lines for Teensy 4.1
#MCU = IMXRT1062
#MCU_LD = imxrt1062_t41.ld
#MCU_DEF = ARDUINO_TEENSY41

# The name of your project (used to name the compiled .hex file)
TARGET = MDA-EP

# configurable options
OPTIONS = -DF_CPU=600000000 -DLAYOUT_US_ENGLISH -DUSING_MAKEFILE
#
# USB Type configuration:
#   -DUSB_SERIAL
#   -DUSB_DUAL_SERIAL
#   -DUSB_TRIPLE_SERIAL
#   -DUSB_KEYBOARDONLY
#   -DUSB_TOUCHSCREEN
#   -DUSB_HID_TOUCHSCREEN
#   -DUSB_HID
#   -DUSB_SERIAL_HID
#   -DUSB_MIDI
#   -DUSB_MIDI4
#   -DUSB_MIDI16
#   -DUSB_MIDI_SERIAL
#   -DUSB_MIDI4_SERIAL
#   -DUSB_MIDI16_SERIAL
#   -DUSB_AUDIO
#   -DUSB_MIDI_AUDIO_SERIAL
#   -DUSB_MIDI16_AUDIO_SERIAL
#   -DUSB_MTPDISK
#   -DUSB_RAWHID
#   -DUSB_FLIGHTSIM
#   -DUSB_FLIGHTSIM_JOYSTICK
OPTIONS += -DUSB_MIDI_AUDIO_SERIAL

# options needed by many Arduino libraries to configure for Teensy model
OPTIONS += -D__$(MCU)__ -DARDUINO=10813 -DTEENSYDUINO=157 -D$(MCU_DEF)

# for Cortex M7 with single & double precision FPU
CPUOPTIONS = -mcpu=cortex-m7 -mfloat-abi=hard -mfpu=fpv5-d16 -mthumb

# use this for a smaller, no-float printf
#SPECS = --specs=nano.specs

# Other Makefiles and project templates for Teensy
#
# https://forum.pjrc.com/threads/57251?p=213332&viewfull=1#post213332
# https://github.com/apmorton/teensy-template
# https://github.com/xxxajk/Arduino_Makefile_master
# https://github.com/JonHylands/uCee


#************************************************************************
# Location of Teensyduino utilities, Toolchain, and Arduino Libraries.
# To use this makefile without Arduino, copy the resources from these
# locations and edit the pathnames.  The rest of Arduino is not needed.
#************************************************************************

# Those that specify a NO_ARDUINO environment variable will
# be able to use this Makefile with no Arduino dependency.
# Please note that if ARDUINOPATH was set, it will override
# the NO_ARDUINO behaviour.
ifndef NO_ARDUINO
# Path to your arduino installation
ARDUINOPATH ?= ../../.arduino15/packages/teensy
endif


ifdef ARDUINOPATH

HARDWAREROOT = $(abspath $(ARDUINOPATH)/hardware/avr/1.57.1)

# path location for Teensy Loader, teensy_post_compile and teensy_reboot (on Linux)
TOOLSPATH = $(abspath $(ARDUINOPATH)/tools)
TEENSYTOOLSPATH = $(TOOLSPATH)/teensy-tools/1.57.1

# path location for Arduino libraries (currently not used)
LIBRARYPATH = $(abspath $(HARDWAREROOT)/libraries)

COREPATH = $(abspath $(HARDWAREROOT)/cores/${PLATFORM})

# path location for the arm-none-eabi compiler
COMPILERPATH = /usr/bin

else
# Default to the normal GNU/Linux compiler path if NO_ARDUINO
# and ARDUINOPATH was not set.
COMPILERPATH ?= /usr/bin

endif

OBJDIR = obj
LIBDIR = lib
LIBOBJDIR = ${LIBDIR}/obj
BUILDDIR = build

#************************************************************************
# Settings below this point usually do not need to be edited
#************************************************************************

# Generate a version string from git for the C++ code to use
GIT_DIRTY := $(shell test -n "`git diff-index --name-only HEAD`" && echo '-dirty')
GIT_VERSION := $(shell git describe --tags || echo -n 'V0.NO-GIT')$(GIT_DIRTY)

BUILD_DATE := $(shell date '+%y/%m/%d')
CDEFINES += -DMDA_EP_VERSION=\"${GIT_VERSION}\" -DBUILD_DATE=\"${BUILD_DATE}\"


# CPPFLAGS = compiler options for C and C++
CPPFLAGS = -Wall -g -O2 $(CPUOPTIONS) -MMD $(OPTIONS) \
	-I${COREPATH} -I. \
	-ffunction-sections -fdata-sections

# compiler options for C++ only
CXXFLAGS = -std=gnu++14 -felide-constructors -fno-exceptions -fpermissive \
	-fno-rtti -Wno-error=narrowing

# compiler options for C only
CFLAGS =

# linker options
LDFLAGS = -Os -Wl,--gc-sections,--relax $(SPECS) $(CPUOPTIONS) -T$(MCU_LD)

# additional libraries to link
LIBS = -L${TOOLSPATH}/teensy-compile/5.4.1/arm/arm-none-eabi/lib \
	-larm_cortexM7lfsp_math -lm -lstdc++ -lc

LIBRARIES = Audio SD/src SdFat/src SerialFlash SPI Wire
USER_LIBRARIES = Synth_MDA_EPiano/src

CORE_LIB   := $(LIBDIR)/libCore.a
AUDIO_LIB  := $(LIBDIR)/libAudio.a
SD_LIB     := $(LIBDIR)/libSD.a
SDFAT_LIB  := $(LIBDIR)/libSdFat.a
SERIALFLASH_LIB  := $(LIBDIR)/libSerialFlash.a
SPI_LIB    := $(LIBDIR)/libSPI.a
SYNTHMDAEPIANO_LIB  := $(LIBDIR)/libSynth_MDA_EPiano.a
WIRE_LIB   := $(LIBDIR)/libWire.a
LIB_LIST   = $(AUDIO_LIB) $(SD_LIB) $(SDFAT_LIB) $(SERIALFLASH_LIB) \
			 $(SPI_LIB) $(SYNTHMDAEPIANO_LIB) $(WIRE_LIB) $(CORE_LIB)

CPPFLAGS += $(addprefix -I${LIBRARYPATH}/,${LIBRARIES})
CPPFLAGS += $(addprefix -I../../Arduino/libraries/,${USER_LIBRARIES})


# names for the compiler programs
CROSS_COMPILE := ${COMPILERPATH}/arm-none-eabi-
CC      = $(CROSS_COMPILE)gcc
CXX     = $(CROSS_COMPILE)g++
OBJCOPY = $(CROSS_COMPILE)objcopy
SIZE    = $(CROSS_COMPILE)size
AR      = $(CROSS_COMPILE)ar
RANLIB  = $(CROSS_COMPILE)ranlib
MKDIR   = mkdir -p

# automatically create lists of the sources and objects
# TODO: this does not handle Arduino libraries yet...
C_FILES := $(wildcard *.c)
CPP_FILES := MDA-EP.cpp
OBJS := $(addprefix ${OBJDIR}/,$(C_FILES:.c=.o) $(CPP_FILES:.cpp=.o))

LIBS := -L$(LIBDIR) $(subst lib/lib,-l,$(LIB_LIST:.a=)) $(LIBS)

# the actual makefile rules (all .o files built by GNU make's default implicit rules)

.PHONY: all load clean upload
all: $(addprefix ${BUILDDIR}/,$(TARGET).hex)

${BUILDDIR}/$(TARGET).elf: $(OBJS) | ${LIB_LIST} ${BUILDDIR} $(MCU_LD)
	@$(LINK.o) -o $@ $^ $(LIBS)
	@echo built $@ ${GIT_VERSION}

${BUILDDIR}/%.hex: ${BUILDDIR}/%.elf
	@echo
	@$(SIZE) $<
	@echo
	@echo Converting $@ from $<
	@$(OBJCOPY) -O ihex -R .eeprom $< $@
	@echo
ifneq (,$(wildcard $(TEENSYTOOLSPATH)/__FALSE__))
	# I don't know what this is trying to do
	$(TEENSYTOOLSPATH)/teensy_post_compile -file=$(basename $@) -path=${BUILDDIR} \
		-tools=$(TEENSYTOOLSPATH)
	-$(TEENSYTOOLSPATH)/teensy_reboot
endif

$(OBJDIR)/%.o : %.c | ${OBJDIR}
	@echo Building $@ from $<
	@$(COMPILE.c) $(OUTPUT_OPTION) $<

$(OBJDIR)/%.o : %.cpp | ${OBJDIR}
	@echo Building $@ from $<
	@$(COMPILE.cpp) $(OUTPUT_OPTION) $<

# compiler generated dependency info
-include $(OBJS:.o=.d)
# -include $(wildcard $(OBJDIR)/*.d)
-include $(wildcard $(LIBOBJDIR)/*.d)

$(OBJDIR) $(LIBDIR) $(LIBOBJDIR) $(BUILDDIR) : ; $(MKDIR) $@
$(LIB_LIST) : | $(LIBDIR)

clean:
	@rm -f *.o *.d $(TARGET).elf $(TARGET).hex
	-rm -rf $(OBJDIR) ${LIBOBJDIR} $(LIBDIR) ${BUILDDIR}

AUDIO_LIB_CPP_FILES = control_sgtl5000.cpp effect_multiply.cpp filter_biquad.cpp \
	imxrt_hw.cpp mixer.cpp output_i2s.cpp output_pt8211.cpp play_memory.cpp \
	synth_dc.cpp synth_simple_drum.cpp synth_sine.cpp synth_whitenoise.cpp
AUDIO_LIB_C_FILES = data_ulaw.c data_waveforms.c
AUDIO_LIB_S_FILES = memcpy_audio.S
AUDIO_OBJS := $(addprefix $(LIBOBJDIR)/,$(AUDIO_LIB_C_FILES:.c=.o) \
	$(AUDIO_LIB_CPP_FILES:.cpp=.o) $(AUDIO_LIB_S_FILES:.S=.o))
AUDIO_LIB_PATH := ${LIBRARYPATH}/Audio

$(LIBOBJDIR)/%.o : $(LIBRARYPATH)/Audio/%.c | $(LIBOBJDIR)
	@echo Compiling $@ from $<
	@$(COMPILE.c) $(OUTPUT_OPTION) $<

$(LIBOBJDIR)/%.o : $(LIBRARYPATH)/Audio/%.S | $(LIBOBJDIR)
	@echo Compiling $@ from $<
	@$(COMPILE.S) $(OUTPUT_OPTION) $<

$(LIBOBJDIR)/%.o : $(LIBRARYPATH)/Audio/%.cpp | $(LIBOBJDIR)
	@echo Compiling $@ from $<
	@$(COMPILE.cpp) $(OUTPUT_OPTION) $<

$(LIBOBJDIR)/%.o : $(LIBRARYPATH)/Audio/utility/%.cpp | $(LIBOBJDIR)
	@echo Compiling $@ from $<
	@$(COMPILE.cpp) $(OUTPUT_OPTION) $<

$(AUDIO_LIB): $(AUDIO_OBJS) | ${LIBDIR}
	@echo Collecting library $@ from ${AUDIO_LIB_PATH}
	@$(AR) $(ARFLAGS) $@ $^

SD_LIB_CPP_FILES := SD.cpp
SD_OBJS := $(addprefix $(LIBOBJDIR)/,$(SD_LIB_CPP_FILES:.cpp=.o))
SD_LIB_PATH := ${LIBRARYPATH}/SD/src
${SD_OBJS}: CPPFLAGS += -I${HARDWAREROOT}/libraries/SdFat/src \
	-I${SD_LIB_PATH}/utility

$(LIBOBJDIR)/%.o : ${SD_LIB_PATH}/%.cpp
	@echo Compiling $@ from $<
	@$(COMPILE.cpp) $(OUTPUT_OPTION) $<

$(LIBOBJDIR)/%.o : ${SD_LIB_PATH}/utility/%.cpp
	@echo Compiling $@ from $<
	@$(COMPILE.cpp) $(OUTPUT_OPTION) $<

$(SD_LIB): $(SD_OBJS) | ${LIBDIR}
	@echo Collecting library $@ from ${SD_LIB_PATH}
	@$(AR) $(ARFLAGS) $@ $^

SDFAT_LIB_CPP_FILES := FreeStack.cpp
SDFAT_OBJS := $(addprefix $(LIBOBJDIR)/,$(SD_LIB_CPP_FILES:.cpp=.o))
SDFAT_LIB_PATH := ${LIBRARYPATH}/SdFat/src

$(LIBOBJDIR)/%.o : ${SDFAT_LIB_PATH}/%.cpp
	@echo Compiling $@ from $<
	@$(COMPILE.cpp) $(OUTPUT_OPTION) $<

$(SDFAT_LIB): $(SDFAT_OBJS) | ${LIBDIR}
	@echo Collecting library $@ from ${SDFAT_LIB_PATH}
	@$(AR) $(ARFLAGS) $@ $^

SERIALFLASH_LIB_CPP_FILES := SerialFlashChip.cpp SerialFlashDirectory.cpp
SERIALFLASH_OBJS := $(addprefix $(LIBOBJDIR)/,$(SERIALFLASH_LIB_CPP_FILES:.cpp=.o))
SERIALFLASH_LIB_PATH := ${LIBRARYPATH}/SerialFlash

$(LIBOBJDIR)/%.o : ${SERIALFLASH_LIB_PATH}/%.cpp
	@echo Compiling $@ from $<
	@$(COMPILE.cpp) $(OUTPUT_OPTION) $<

$(SERIALFLASH_LIB): $(SERIALFLASH_OBJS) | ${LIBDIR}
	@echo Collecting library $@ from ${SERIALFLASH_LIB_PATH}
	@$(AR) $(ARFLAGS) $@ $^

SPI_LIB_CPP_FILES := SPI.cpp
SPI_OBJS := $(addprefix $(LIBOBJDIR)/,$(SPI_LIB_CPP_FILES:.cpp=.o))
SPI_LIB_PATH := ${LIBRARYPATH}/SPI

$(LIBOBJDIR)/%.o : ${SPI_LIB_PATH}/%.cpp
	@echo Compiling $@ from $<
	@$(COMPILE.cpp) $(OUTPUT_OPTION) $<

$(SPI_LIB): $(SPI_OBJS) | ${LIBDIR}
	@echo Collecting library $@ from ${SPI_LIB_PATH}
	@$(AR) $(ARFLAGS) $@ $^

SYNTHMDA_LIB_CPP_FILES := mdaEPiano.cpp
SYNTHMDA_OBJS := $(addprefix $(LIBOBJDIR)/,$(SYNTHMDA_LIB_CPP_FILES:.cpp=.o))
SYNTHMDA_LIB_PATH := ../../Arduino/libraries/Synth_MDA_EPiano/src

$(LIBOBJDIR)/%.o : ${SYNTHMDA_LIB_PATH}/%.cpp
	@echo Compiling $@ from $<
	@$(COMPILE.cpp) $(OUTPUT_OPTION) $<

$(SYNTHMDAEPIANO_LIB): $(SYNTHMDA_OBJS) | ${LIBDIR}
	@echo Collecting library $@ from ${SYNTHMDA_LIB_PATH}
	@$(AR) $(ARFLAGS) $@ $^

WIRE_LIB_CPP_FILES := Wire.cpp WireIMXRT.cpp WireKinetis.cpp
WIRE_OBJS := $(addprefix $(LIBOBJDIR)/,$(WIRE_LIB_CPP_FILES:.cpp=.o))
WIRE_LIB_PATH := ${LIBRARYPATH}/Wire

$(LIBOBJDIR)/%.o : ${WIRE_LIB_PATH}/%.cpp
	@echo Compiling $@ from $<
	@$(COMPILE.cpp) $(OUTPUT_OPTION) $<

$(WIRE_LIB): $(WIRE_OBJS) | ${LIBDIR}
	@echo Collecting library $@ from ${WIRE_LIB_PATH}
	@$(AR) $(ARFLAGS) $@ $^

CORE_SRC_CPP = $(wildcard ${HARDWAREROOT}/cores/${PLATFORM}/*.cpp)
CORE_SRC_C = $(wildcard ${HARDWAREROOT}/cores/${PLATFORM}/*.c)
CORE_OBJ = $(addprefix $(LIBOBJDIR)/,$(notdir $(CORE_SRC_CPP:.cpp=.o) $(CORE_SRC_C:.c=.o)))

$(LIBOBJDIR)/%.o : $(HARDWAREROOT)/cores/${PLATFORM}/%.cpp | $(LIBOBJDIR)
	@echo Compiling $@ from $<
	@$(COMPILE.cpp) $(OUTPUT_OPTION) $<

$(LIBOBJDIR)/%.o : $(HARDWAREROOT)/cores/${PLATFORM}/%.c | $(LIBOBJDIR)
	@echo Building $@ from $(notdir $<)
	@$(COMPILE.c) $(OUTPUT_OPTION) $<

$(CORE_LIB): $(CORE_OBJ) | ${LIBDIR}
	@echo Collecting library $@ from ${HARDWAREROOT}/cores/${PLATFORM}
	@$(AR) $(ARFLAGS) $@ $^
