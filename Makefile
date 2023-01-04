# Teensyduino MDA-EPiano
#
#  Tim Braun 22/12/28
#    Support compiling for teensy4, teensy35, and teensy3 targets
#    - only teensy4 has the flash space required for the samples
#
# Copyright (c) 2022 Tim Braun, Obnoxious Music
#
# http://www.pjrc.com/teensy/
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

PLATFORM ?= teensy3

# Use these lines for Teensy 4.0
ifeq ($(PLATFORM),teensy4)
MCU     := IMXRT1062
MCU_DEF := ARDUINO_TEENSY40
CORE    := teensy4
OPTIONS := -DF_CPU=600000000
# for Cortex M7 with single & double precision FPU
CPUOPTIONS = -mfloat-abi=hard -mfpu=fpv5-d16
CPUARCH := cortex-m7
LIBS     += -larm_cortexM7lfsp_math
MCU_LD   = ${COREPATH}/imxrt1062.ld
endif

# Use these lines for Teensy 4.1
#MCU = IMXRT1062
# MCU_LD = imxrt1062_t41.ld
#MCU_DEF = ARDUINO_TEENSY41

ifeq ($(PLATFORM),teensy3)
MCU     := MK20DX256
MCU_DEF := ARDUINO_TEENSY32
CORE    := teensy3
OPTIONS := -DF_CPU=72000000
CPUOPTIONS = -mfloat-abi=hard -mfpu=fpv5-d16
CPUARCH := cortex-m4
LIBS     += -larm_cortexM4l_math
MCU_LD   = ${COREPATH}/mk20dx256.ld
MCULDFLAGS = -Wl,--defsym=__rtc_localtime=0
endif

ifeq ($(PLATFORM),teensyLC)
MCU     := MKL26Z64
MCU_DEF := ARDUINO_TEENSYLC
CORE    := teensy3
OPTIONS := -DF_CPU=48000000
# CPUOPTIONS =  -fsingle-precision-constant
CPUARCH := cortex-m0plus
LIBS     += -larm_cortexM0l_math
# CORE_LIB   = $(LIBDIR)/libteensy-lc.a
# LIBS     = -L../teensykick/lib -lteensy-lc
MCU_LD   = ${COREPATH}/mkl26z64.ld
MCULDFLAGS = -Wl,--defsym=__rtc_localtime=0
SPECS    = --specs=nano.specs
endif

ifeq ($(PLATFORM),teensy35)
MCU     := MK64FX512
MCU_DEF := ARDUINO_TEENSY35
CORE    := teensy3
OPTIONS := -DF_CPU=120000000
CPUOPTIONS = -mfloat-abi=hard -mfpu=fpv5-d16
CPUARCH := cortex-m4
LIBS     = -larm_cortexM4lf_math
MCU_LD   = ${COREPATH}/mk64fx512.ld
MCULDFLAGS = -Wl,--defsym=__rtc_localtime=0
endif

# MCU=MK66FX1M0

# The name of your project (used to name the compiled .hex file)
TARGET = MDA-EP

# configurable options

OPTIONS += -DLAYOUT_US_ENGLISH
# OPTIONS += -DUSING_MAKEFILE

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
OPTIONS += -DUSB_MIDI_SERIAL

# options needed by many Arduino libraries to configure for Teensy model
OPTIONS += -D__$(MCU)__ -DARDUINO=10813 -DTEENSYDUINO=157 -D$(MCU_DEF)

CPUOPTIONS += -mcpu=${CPUARCH} -mthumb


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

HARDWAREROOT := $(abspath $(ARDUINOPATH)/hardware/avr/1.57.2)

# path location for Teensy Loader, teensy_post_compile and teensy_reboot (on Linux)
TOOLSPATH := $(abspath $(ARDUINOPATH)/tools)
TEENSYTOOLSPATH := $(TOOLSPATH)/teensy-tools/1.57.2

# path location for Arduino libraries
LIBRARYPATH := $(abspath $(HARDWAREROOT)/libraries)

MYTEENSYDUINOPATH := ../teensy-duino

COREPATH := $(abspath $(HARDWAREROOT)/cores/${CORE})

# path location for the arm-none-eabi compiler
COMPILERPATH = /usr/bin

else
# Default to the normal GNU/Linux compiler path if NO_ARDUINO
# and ARDUINOPATH was not set.
COMPILERPATH ?= /usr/bin

endif

OBJDIR = obj/${PLATFORM}
LIBDIR = lib/${PLATFORM}
LIBOBJDIR = ${LIBDIR}/obj
BUILDDIR = build/${PLATFORM}

#************************************************************************
# Settings below this point usually do not need to be edited
#************************************************************************

# Generate a version string from git for the C++ code to use
GIT_DIRTY := $(shell test -n "`git diff-index --name-only HEAD`" && echo '-dirty')
GIT_VERSION := $(shell git describe --tags || echo -n 'V0.NO-GIT')$(GIT_DIRTY)

BUILD_DATE := $(shell date '+%y/%m/%d')
CDEFINES += -DVERSION=\"${GIT_VERSION}\" -DBUILD_DATE=\"${BUILD_DATE}\"


# CPPFLAGS = compiler options for C and C++
CPPFLAGS = -Wall -g -Os $(CPUOPTIONS) -MMD \
	-ffunction-sections -fdata-sections -mno-unaligned-access \
	$(OPTIONS) \
	$(CDEFINES)

# compiler options for C++ only
CXXFLAGS = -std=gnu++14 -felide-constructors -fno-exceptions \
	-fno-rtti -Wno-error=narrowing

# compiler options for C only
CFLAGS = -std=gnu11

# linker options
#
LDFLAGS = -Wl,--gc-sections $(SPECS) $(CPUOPTIONS) \
	--sysroot=${TOOLSPATH}/teensy-compile/5.4.1/arm/arm-none-eabi \
	-T$(MCU_LD) -Wl,-Map=$(basename $@).map ${MCULDFLAGS} -Os

# additional libraries to link
# LIBS     := -L${TOOLSPATH}/teensy-compile/5.4.1/arm/arm-none-eabi/lib ${LIBS}
LIBS     += -lm -lstdc++

LIBRARIES = SD/src SdFat/src SerialFlash SPI Wire
USER_LIBRARIES = Synth_MDA_EPiano/src

CORE_LIB   ?= $(LIBDIR)/libCore.a
AUDIO_LIB  := $(LIBDIR)/libAudio.a
SD_LIB     := $(LIBDIR)/libSD.a
SDFAT_LIB  := $(LIBDIR)/libSdFat.a
SERIALFLASH_LIB  := $(LIBDIR)/libSerialFlash.a
SPI_LIB    := $(LIBDIR)/libSPI.a
SYNTHMDAEPIANO_LIB  := $(LIBDIR)/libSynth_MDA_EPiano.a
WIRE_LIB   := $(LIBDIR)/libWire.a
LIB_LIST   = $(AUDIO_LIB) $(SERIALFLASH_LIB) \
			 $(SPI_LIB) $(SYNTHMDAEPIANO_LIB) $(WIRE_LIB) $(CORE_LIB)

LIBS := -L$(LIBDIR) $(subst ${LIBDIR}/lib,-l,$(LIB_LIST:.a=)) $(LIBS)

CPPFLAGS += -I${COREPATH}
CPPFLAGS += -I${MYTEENSYDUINOPATH}/Audio
CPPFLAGS += $(addprefix -I${LIBRARYPATH}/,${LIBRARIES})
CPPFLAGS += $(addprefix -I../../Arduino/libraries/,${USER_LIBRARIES})


# names for the compiler programs
CROSS_COMPILE := arm-none-eabi-
# CROSS_COMPILE=${TOOLSPATH}/teensy-compile/5.4.1/arm/bin/arm-none-eabi-
CC      = $(CROSS_COMPILE)gcc
CXX     = $(CROSS_COMPILE)g++
OBJCOPY = $(CROSS_COMPILE)objcopy
SIZE    = $(CROSS_COMPILE)size
AR      = $(CROSS_COMPILE)gcc-ar
RANLIB  = $(CROSS_COMPILE)ranlib
MKDIR   = mkdir -p

# create lists of the sources and objects
CPP_FILES := MDA-EP.cpp usb_write.cpp
OBJS := $(addprefix ${OBJDIR}/,$(C_FILES:.c=.o) $(CPP_FILES:.cpp=.o))

# the actual makefile rules (all .o files built by GNU make's default implicit rules)

.PHONY: all load upload size clean allclean
all: $(addprefix ${BUILDDIR}/,$(TARGET).hex)

${BUILDDIR}/$(TARGET).elf: $(OBJS) ${LIB_LIST} | ${BUILDDIR} $(MCU_LD)
	@$(LINK.o) ${OBJS} $(LIBS) -o $@
	@echo built $@ ${GIT_VERSION} for ${PLATFORM}

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

allclean:
	@rm -rf *.o *.d $(TARGET).elf $(TARGET).hex
ifneq (./,$(dir ${OBJDIR}))
	@rm -rf $(dir ${OBJDIR})
endif
ifneq (./,$(dir ${LIBDIR}))
	@rm -rf $(dir ${LIBDIR})
endif
ifneq (./,$(dir ${BUILDDIR}))
	@rm -rf $(dir ${BUILDDIR})
endif

clean:
	-rm -rf ${OBJDIR} ${LIBOBJDIR} ${LIBDIR} ${BUILDDIR}

ELFS = $(wildcard ${BUILDDIR}/../*/*.elf)
size : all
	@$(foreach e,${ELFS}, $(SIZE) $(subst $(PWD)/,,$(realpath $e));)


upload load : ${BUILDDIR}/$(TARGET).hex
	teensy_loader_cli.exe --mcu=${MCU} -wv $<

######################################
#
# Library building rules
#
######################################

AUDIO_LIB_CPP_FILES = control_sgtl5000.cpp effect_multiply.cpp filter_biquad.cpp \
	imxrt_hw.cpp mixer.cpp output_i2s.cpp output_pt8211.cpp play_memory.cpp \
	synth_dc.cpp synth_simple_drum.cpp synth_sine.cpp synth_whitenoise.cpp
AUDIO_LIB_C_FILES = data_ulaw.c data_waveforms.c
AUDIO_LIB_S_FILES = memcpy_audio.S
AUDIO_OBJS := $(addprefix $(LIBOBJDIR)/,$(AUDIO_LIB_C_FILES:.c=.o) \
	$(AUDIO_LIB_CPP_FILES:.cpp=.o) $(AUDIO_LIB_S_FILES:.S=.o))
AUDIO_LIB_PATH := ${MYTEENSYDUINOPATH}/Audio
# AUDIO_LIB_PATH := ${LIBRARYPATH}/Audio

$(LIBOBJDIR)/%.o : $(AUDIO_LIB_PATH)/%.c | $(LIBOBJDIR)
	@echo Compiling $@ from $<
	@$(COMPILE.c) $(OUTPUT_OPTION) $<

$(LIBOBJDIR)/%.o : $(AUDIO_LIB_PATH)/%.S | $(LIBOBJDIR)
	@echo Compiling $@ from $<
	@$(COMPILE.S) $(OUTPUT_OPTION) $<

$(LIBOBJDIR)/%.o : $(AUDIO_LIB_PATH)/%.cpp | $(LIBOBJDIR)
	@echo Compiling $@ from $<
	@$(COMPILE.cpp) $(OUTPUT_OPTION) $<

$(LIBOBJDIR)/%.o : $(AUDIO_LIB_PATH)/utility/%.cpp | $(LIBOBJDIR)
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

CORE_SRC_PATH = ${COREPATH}
# CORE_SRC_PATH := ../teensy-duino/src
CORE_SRC_CPP = $(wildcard ${CORE_SRC_PATH}/*.cpp)
CORE_SRC_C = $(wildcard ${CORE_SRC_PATH}/*.c)
CORE_SRC_S = $(wildcard ${CORE_SRC_PATH}/*.S)
CORE_OBJ = $(addprefix $(LIBOBJDIR)/,$(notdir $(CORE_SRC_CPP:.cpp=.o) $(CORE_SRC_C:.c=.o)))

$(LIBOBJDIR)/%.o : ${CORE_SRC_PATH}/%.cpp | $(LIBOBJDIR)
	@echo Compiling $@ from $<
	@$(COMPILE.cpp) $(OUTPUT_OPTION) $<

$(LIBOBJDIR)/%.o : ${CORE_SRC_PATH}/%.c | $(LIBOBJDIR)
	@echo Building $@ from $(notdir $<)
	@$(COMPILE.c) $(OUTPUT_OPTION) $<

$(CORE_LIB): $(CORE_OBJ) | ${LIBDIR}
	@echo Collecting library $@ from ${CORE_SRC_PATH}
	@$(AR) $(ARFLAGS) $@ $^

get_sample_data get_sample_size: \
	CINCLUDES += $(addprefix -I../../Arduino/libraries/,${USER_LIBRARIES}) -Ifake_arduino
get_sample_data get_sample_size: \
	CDEFINES += -DARDUINO_TEENSY40

% : utility/%.cpp
	g++ $(CXXFLAGS) $(CDEFINES) $(CINCLUDES) $(OUTPUT_OPTION) $<


ifeq (1,0)
"/home/tim/.arduino15/packages/teensy/tools/teensy-compile/5.4.1/arm/bin/arm-none-eabi-g++",
   "-c",
   "-Os",
   "--specs=nano.specs",
   "-g",
   "-Wall",
   "-ffunction-sections",
   "-fdata-sections",
   "-nostdlib",
   "-mno-unaligned-access",
   "-MMD",
   "-fno-exceptions",
   "-fpermissive",
   "-felide-constructors",
   "-std=gnu++14",
   "-Wno-error=narrowing",
   "-fno-rtti",
   "-mthumb",
   "-mcpu=cortex-m0plus",
   "-fsingle-precision-constant",
   "-D__MKL26Z64__",
   "-DTEENSYDUINO=157",
   "-DARDUINO=10607",
   "-DARDUINO_TEENSYLC",
   "-DF_CPU=48000000",
   "-DUSB_MIDI_AUDIO_SERIAL",
   "-DLAYOUT_US_ENGLISH",
   "-I/tmp/arduino-sketch-7468DE9DCE90F4D5F54F55FB89CC1C3E/pch",
   "-I/home/tim/.arduino15/packages/teensy/hardware/avr/1.57.2/cores/teensy3",
   "-I/home/tim/.arduino15/packages/teensy/hardware/avr/1.57.2/libraries/Audio",
   "-I/home/tim/.arduino15/packages/teensy/hardware/avr/1.57.2/libraries/SPI",
   "-I/home/tim/.arduino15/packages/teensy/hardware/avr/1.57.2/libraries/SD/src",
   "-I/home/tim/.arduino15/packages/teensy/hardware/avr/1.57.2/libraries/SdFat/src",
   "-I/home/tim/.arduino15/packages/teensy/hardware/avr/1.57.2/libraries/SerialFlash",
   "-I/home/tim/Arduino/libraries/Synth_MDA_EPiano/src",
   "-I/home/tim/.arduino15/packages/teensy/hardware/avr/1.57.2/libraries/Wire",
   "/home/tim/.arduino15/packages/teensy/hardware/avr/1.57.2/libraries/SdFat/src/common/FsStructs.cpp",
   "-o",
   "/tmp/arduino-sketch-7468DE9DCE90F4D5F54F55FB89CC1C3E/libraries/SdFat/common/FsStructs.cpp.o"
endif
