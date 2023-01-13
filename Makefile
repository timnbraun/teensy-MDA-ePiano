# Teensyduino mda-ePiano
#
#  Tim Braun 22/12/28
#    Support compiling for teensy4, teensy35, teensy3, and teensyLC platforms
#
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

PLATFORM ?= teensy4

# Use these lines for Teensy 4.0
ifeq ($(PLATFORM),teensy4)
MCU     := IMXRT1062
MCU_DEF := ARDUINO_TEENSY40
CORE    := teensy4
OPTIONS := -DF_CPU=600000000
# for Cortex M7 with single & double precision FPU
CPUOPTIONS = -mfloat-abi=hard -mfpu=fpv5-d16
CPUARCH := cortex-m7
LIBS     += -L${TOOLSPATH}/teensy-compile/5.4.1/arm/arm-none-eabi/lib -larm_cortexM7lfsp_math
MCU_LD   = ${COREPATH}/imxrt1062.ld
AUDIO_LIB_PATH = ${LIBRARYPATH}/Audio
LIBRARIES = Audio
endif

# Use these lines for Teensy 4.1
ifeq ($(PLATFORM),teensy41)
MCU      := IMXRT1062
MCU_DEF  := ARDUINO_TEENSY41
CORE     := teensy4
OPTIONS  := -DF_CPU=600000000
CPUOPTIONS = -mfloat-abi=hard -mfpu=fpv5-d16
LIBS     += -larm_cortexM7lfsp_math
MCU_LD    = ${COREPATH}/imxrt1062_t41.ld
LIBRARIES = Audio
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
LIBRARIES = Audio
endif

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
LIBRARIES = Audio
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
LOCALTEENSY_LIBRARIES = Audio
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
OPTIONS += -DUSB_MIDI_AUDIO_SERIAL

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
# Path to your arduino installation
ARDUINOPATH  := $(HOME)/.arduino15/packages/teensy
HARDWAREROOT := $(abspath $(ARDUINOPATH)/hardware/avr/1.57.2)

# path location for Arduino libraries
LIBRARYPATH  := $(HARDWAREROOT)/libraries
COREPATH     := $(HARDWAREROOT)/cores/${CORE}

# path location for Teensy Loader, teensy_post_compile and teensy_reboot (on Linux)
TOOLSPATH    := $(abspath $(ARDUINOPATH)/tools)
TEENSYTOOLSPATH := $(TOOLSPATH)/teensy-tools/1.57.2

MYTEENSYDUINOPATH := ../teensy-duino

OBJDIR    := obj/${PLATFORM}
LIBDIR    := lib/${PLATFORM}
LIBOBJDIR := ${LIBDIR}/obj
BUILDDIR  := build/${PLATFORM}

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
	-T$(MCU_LD) -Wl,-Map=$(basename $@).map ${MCULDFLAGS} -Os \
	--sysroot=${TOOLSPATH}/teensy-compile/5.4.1/arm
#	--sysroot=${TOOLSPATH}/teensy-compile/5.4.1/arm/arm-none-eabi/lib/armv7e-m/fpu/fpv5-d16

# additional libraries to link
# LIBS     := -L${TOOLSPATH}/teensy-compile/5.4.1/arm/arm-none-eabi/lib ${LIBS}
LIBS     += -lm -lstdc++

# $(shell echo $@ ${PLATFORM} ${LIBRARIES})
LIBRARIES += SD/src SdFat/src SerialFlash SPI Wire
# $(shell echo $@ ${PLATFORM} ${LIBRARIES})
USER_LIBRARIES = Synth_MDA_EPiano/src

CORE_LIB   := $(LIBDIR)/libCore.a
AUDIO_LIB  := $(LIBDIR)/libAudio.a
SD_LIB     := $(LIBDIR)/libSD.a
SDFAT_LIB  := $(LIBDIR)/libSdFat.a
SERIALFLASH_LIB  := $(LIBDIR)/libSerialFlash.a
SPI_LIB    := $(LIBDIR)/libSPI.a
SYNTHMDAEPIANO_LIB  := $(LIBDIR)/libSynth_MDA_EPiano.a
WIRE_LIB   := $(LIBDIR)/libWire.a
LIB_LIST   := $(AUDIO_LIB) $(SERIALFLASH_LIB) \
			 $(SPI_LIB) $(SYNTHMDAEPIANO_LIB) $(WIRE_LIB) $(CORE_LIB)

LIBS := -L$(LIBDIR) $(subst ${LIBDIR}/lib,-l,$(LIB_LIST:.a=)) $(LIBS)

CPPFLAGS += -I${COREPATH}
ifneq (${LOCALTEENSY_LIBRARIES},)
CPPFLAGS += $(addprefix -I${MYTEENSYDUINOPATH}/,${LOCALTEENSY_LIBRARIES})
endif
CPPFLAGS += $(addprefix -I${LIBRARYPATH}/,${LIBRARIES})
CPPFLAGS += $(addprefix -I../../Arduino/libraries/,${USER_LIBRARIES})


# names for the compiler programs
# CROSS_COMPILE := arm-none-eabi-
CROSS_COMPILE=${TOOLSPATH}/teensy-compile/5.4.1/arm/bin/arm-none-eabi-
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

# OBJS := crti.o crtbegin.o crt0.o $(OBJS)
# crti.o crtbegin.o crt0.o libm.a libstdc++.a libgcc.a libg.a libc.a
SYSROOT := ${TOOLSPATH}/teensy-compile/5.4.1/arm/arm-none-eabi/lib/armv7e-m/fpu/fpv5-d16
SYSLIBROOT := ${TOOLSPATH}/teensy-compile/5.4.1/arm/lib/gcc/arm-none-eabi/5.4.1/armv7e-m/fpu/fpv5-d16
# CRT_OBJS := -nostdlib -L$(SYSLIBROOT) $(addprefix ${SYSLIBROOT}/,crti.o crtbegin.o) \
	$(SYSROOT)/crt0.o
# LIBS += -lm -lstdc++ -lgcc -lg -lc

.PHONY: all load upload size clean allclean
all: $(addprefix ${BUILDDIR}/,$(TARGET).hex)

# the actual makefile rules (all .o files built by rules using standard COMPILE.x macros)

${BUILDDIR}/$(TARGET).elf: $(OBJS) ${LIB_LIST} | ${BUILDDIR} $(MCU_LD)
	@$(LINK.o) ${CPPFLAGS} ${CRT_OBJS} ${OBJS} $(LIBS) -o $@
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
	# it seems to want to use teensy_loader_cli but that ain't gonna work
	# since we don't have access to the serial port
	$(TEENSYTOOLSPATH)/teensy_post_compile -file=$(basename $@) -path=${BUILDDIR} \
		-tools=$(TEENSYTOOLSPATH)
	-$(TEENSYTOOLSPATH)/teensy_reboot
endif

$(OBJDIR)/%.o : %.c | ${OBJDIR}
	@echo Compiling $@ from $<
	@$(COMPILE.c) $(OUTPUT_OPTION) $<

$(OBJDIR)/%.o : %.cpp | ${OBJDIR}
	@echo Compiling $@ from $<
	@echo $@ ${PLATFORM} ${LIBRARIES}
	$(COMPILE.cpp) $(OUTPUT_OPTION) $<

# compiler generated dependency info
# -include $(OBJS:.o=.d)
-include $(wildcard $(OBJDIR)/*.d)
-include $(wildcard $(LIBOBJDIR)/*.d)

$(OBJDIR) $(LIBDIR) $(LIBOBJDIR) $(BUILDDIR) : ; @$(MKDIR) $@
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

G := "\033[0;32m"
CLR := "\033[0m"

AUDIO_LIB_PATH ?= ${MYTEENSYDUINOPATH}/Audio
# AUDIO_LIB_PATH := ${LIBRARYPATH}/Audio
ifeq (${PLATFORM},teensy4)
AUDIO_LIB_CPP_FILES = $(wildcard ${AUDIO_LIB_PATH}/*.cpp ${AUDIO_LIB_PATH}/utility/*.cpp)
AUDIO_LIB_C_FILES = $(wildcard ${AUDIO_LIB_PATH}/*.c ${AUDIO_LIB_PATH}/utility/*.c)
AUDIO_LIB_S_FILES = $(wildcard ${AUDIO_LIB_PATH}/*.S)
else
AUDIO_LIB_CPP_FILES = control_sgtl5000.cpp effect_multiply.cpp \
	filter_biquad.cpp imxrt_hw.cpp mixer.cpp output_i2s.cpp \
	output_pt8211.cpp play_memory.cpp synth_dc.cpp \
	synth_simple_drum.cpp synth_sine.cpp synth_whitenoise.cpp
AUDIO_LIB_C_FILES = data_ulaw.c data_waveforms.c
AUDIO_LIB_S_FILES = memcpy_audio.S
endif
AUDIO_OBJS := $(addprefix $(LIBOBJDIR)/,$(notdir $(AUDIO_LIB_C_FILES:.c=.o) \
	$(AUDIO_LIB_CPP_FILES:.cpp=.o) $(AUDIO_LIB_S_FILES:.S=.o)))

$(LIBOBJDIR)/%.o : $(AUDIO_LIB_PATH)/%.c | $(LIBOBJDIR)
	@echo Compiling $@ from $<
	@$(COMPILE.c) -I${AUDIO_LIB_PATH}/utility $(OUTPUT_OPTION) $<

$(LIBOBJDIR)/%.o : $(AUDIO_LIB_PATH)/%.S | $(LIBOBJDIR)
	@echo Compiling $@ from $<
	@$(COMPILE.S) $(OUTPUT_OPTION) $<

$(LIBOBJDIR)/%.o : $(AUDIO_LIB_PATH)/%.cpp | $(LIBOBJDIR)
	@echo Compiling $@ from $<
	@$(COMPILE.cpp) -I${AUDIO_LIB_PATH}/utility $(OUTPUT_OPTION) $<

$(LIBOBJDIR)/%.o : $(AUDIO_LIB_PATH)/utility/%.cpp | $(LIBOBJDIR)
	@echo Compiling $@ from $<
	@$(COMPILE.cpp) $(OUTPUT_OPTION) $<

$(LIBOBJDIR)/%.o : $(AUDIO_LIB_PATH)/utility/%.c | $(LIBOBJDIR)
	@echo Compiling $@ from $<
	@$(COMPILE.c) -I${AUDIO_LIB_PATH}/utility $(OUTPUT_OPTION) $<

$(AUDIO_LIB): $(AUDIO_OBJS) | ${LIBDIR}
	@echo ${G}"\n"Collecting library $@ from ${AUDIO_LIB_PATH}${CLR}"\n"
	@$(AR) $(ARFLAGS) $@ $^

SD_LIB_CPP_FILES := SD.cpp
SD_OBJS := $(addprefix $(LIBOBJDIR)/,$(SD_LIB_CPP_FILES:.cpp=.o))
SD_LIB_PATH := ${LIBRARYPATH}/SD/src
${SD_OBJS}: CPPFLAGS += \
	-I${SD_LIB_PATH}/utility

$(LIBOBJDIR)/%.o : ${SD_LIB_PATH}/%.cpp
	@echo Compiling $@ from $(subst ${HARDWAREROOT}/,,$<)
	@$(COMPILE.cpp) $(OUTPUT_OPTION) $<

$(LIBOBJDIR)/%.o : ${SD_LIB_PATH}/utility/%.cpp
	@echo Compiling $@ from $(subst ${HARDWAREROOT}/,,$<)
	@$(COMPILE.cpp) $(OUTPUT_OPTION) $<

$(SD_LIB): $(SD_OBJS) | ${LIBDIR}
	@echo ${G}"\n"Collecting library $@ from \
		$(subst ${HARDWAREROOT}/,,${SD_LIB_PATH})${CLR}"\n"
	@$(AR) $(ARFLAGS) $@ $^

SDFAT_LIB_CPP_FILES := FreeStack.cpp
SDFAT_OBJS := $(addprefix $(LIBOBJDIR)/,$(SD_LIB_CPP_FILES:.cpp=.o))
SDFAT_LIB_PATH := ${LIBRARYPATH}/SdFat/src

$(LIBOBJDIR)/%.o : ${SDFAT_LIB_PATH}/%.cpp
	@echo Compiling $@ from $(subst ${HARDWAREROOT}/,,$<)
	@$(COMPILE.cpp) $(OUTPUT_OPTION) $<

$(SDFAT_LIB): $(SDFAT_OBJS) | ${LIBDIR}
	@echo ${G}"\n"Collecting library $@ from \
		$(subst ${HARDWAREROOT}/,,${SDFAT_LIB_PATH})${CLR}"\n"
	@$(AR) $(ARFLAGS) $@ $^

SERIALFLASH_LIB_CPP_FILES := SerialFlashChip.cpp SerialFlashDirectory.cpp
SERIALFLASH_OBJS := $(addprefix $(LIBOBJDIR)/,$(SERIALFLASH_LIB_CPP_FILES:.cpp=.o))
SERIALFLASH_LIB_PATH := ${LIBRARYPATH}/SerialFlash

$(LIBOBJDIR)/%.o : ${SERIALFLASH_LIB_PATH}/%.cpp
	@echo Compiling $@ from $(subst ${HARDWAREROOT}/,,$<)
	@$(COMPILE.cpp) $(OUTPUT_OPTION) $<

$(SERIALFLASH_LIB): $(SERIALFLASH_OBJS) | ${LIBDIR}
	@echo ${G}"\n"Collecting library $@ from \
		$(subst ${HARDWAREROOT}/,,${SERIALFLASH_LIB_PATH})${CLR}"\n"
	@$(AR) $(ARFLAGS) $@ $^

SPI_LIB_CPP_FILES := SPI.cpp
SPI_OBJS := $(addprefix $(LIBOBJDIR)/,$(SPI_LIB_CPP_FILES:.cpp=.o))
SPI_LIB_PATH := ${LIBRARYPATH}/SPI

$(LIBOBJDIR)/%.o : ${SPI_LIB_PATH}/%.cpp
	@echo Compiling $@ from $(subst ${HARDWAREROOT}/,,$<)
	@$(COMPILE.cpp) $(OUTPUT_OPTION) $<

$(SPI_LIB): $(SPI_OBJS) | ${LIBDIR}
	@echo ${G}"\n"Collecting library $@ from \
		$(subst ${HARDWAREROOT}/,,${SPI_LIB_PATH})${CLR}"\n"
	@$(AR) $(ARFLAGS) $@ $^

WIRE_LIB_CPP_FILES := Wire.cpp WireIMXRT.cpp WireKinetis.cpp
WIRE_OBJS := $(addprefix $(LIBOBJDIR)/,$(WIRE_LIB_CPP_FILES:.cpp=.o))
WIRE_LIB_PATH := ${LIBRARYPATH}/Wire

$(LIBOBJDIR)/%.o : ${WIRE_LIB_PATH}/%.cpp
	@echo Compiling $@ from $(subst ${HARDWAREROOT}/,,$<)
	@$(COMPILE.cpp) $(OUTPUT_OPTION) $<

$(WIRE_LIB): $(WIRE_OBJS) | ${LIBDIR}
	@echo ${G}"\n"Collecting library $@ from \
		$(subst ${HARDWAREROOT}/,,${WIRE_LIB_PATH})${CLR}"\n"
	@$(AR) $(ARFLAGS) $@ $^


SYNTHMDA_LIB_CPP_FILES := mdaEPiano.cpp
SYNTHMDA_OBJS := $(addprefix $(LIBOBJDIR)/,$(SYNTHMDA_LIB_CPP_FILES:.cpp=.o))
SYNTHMDA_LIB_PATH := ../../Arduino/libraries/Synth_MDA_EPiano/src

$(LIBOBJDIR)/%.o : ${SYNTHMDA_LIB_PATH}/%.cpp
	@echo Compiling $@ from $<
	@$(COMPILE.cpp) $(OUTPUT_OPTION) $<

$(SYNTHMDAEPIANO_LIB): $(SYNTHMDA_OBJS) | ${LIBDIR}
	@echo ${G}"\n"Collecting library $@ from ${SYNTHMDA_LIB_PATH}${CLR}"\n"
	@$(AR) $(ARFLAGS) $@ $^

CORE_SRC_PATH = ${COREPATH}
# CORE_SRC_PATH := ${MYTEENSYDUINOPATH}/src
CORE_SRC_CPP = $(wildcard ${CORE_SRC_PATH}/*.cpp)
CORE_SRC_C = $(wildcard ${CORE_SRC_PATH}/*.c)
CORE_SRC_S = $(wildcard ${CORE_SRC_PATH}/*.S)
CORE_OBJ = $(addprefix $(LIBOBJDIR)/,$(notdir $(CORE_SRC_CPP:.cpp=.o) $(CORE_SRC_C:.c=.o)))

$(LIBOBJDIR)/%.o : ${CORE_SRC_PATH}/%.cpp | $(LIBOBJDIR)
	@echo Compiling $@ from $(subst ${HARDWAREROOT}/,,$<)
	@$(COMPILE.cpp) $(OUTPUT_OPTION) $<

$(LIBOBJDIR)/%.o : ${CORE_SRC_PATH}/%.c | $(LIBOBJDIR)
	@echo Compiling $@ from $(subst ${HARDWAREROOT}/,,$<)
	@$(COMPILE.c) $(OUTPUT_OPTION) $<

$(CORE_LIB): $(CORE_OBJ) | ${LIBDIR}
	@echo ${G}"\n"Collecting library $@ from \
		$(subst ${HARDWAREROOT}/,,${CORE_SRC_PATH})${CLR}"\n"
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
