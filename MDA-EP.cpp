
#include <Arduino.h>
#include <usb_dev.h>
#include <Audio.h>
#define NPROGS 2
#define WAVELEN 11240
#include <synth_mda_epiano.h>

#define dbg(...) \
	fiprintf(stderr, __VA_ARGS__)

void onNoteOn(byte chan, byte note, byte vel);
void onNoteOff(byte chan, byte note, byte vel);

class AudioSynthSine : public AudioSynthWaveformSine
{
	public:
		void noteOn( uint16_t note, uint16_t vel ) { amplitude(1.0); };
		void noteOff( uint16_t note ) { amplitude(0.0); };
		void setProgram( uint16_t p ) { frequency(440); };
};

usb_serial_class		 Serial;

#if defined(ARDUINO_TEENSYLC)
#define USE_SINE
#define EP_VOICES 2
#define AUDIO_BUFFERS 4
#else

#if defined(ARDUINO_TEENSY32)
#define USE_SINE
#endif

#define EP_VOICES 16
#define AUDIO_BUFFERS 16

#endif
#if defined(USE_SINE)
AudioSynthSine   		 ep;
#else
AudioSynthEPiano         ep(EP_VOICES);
#endif
AudioOutputI2S           out;
#define USE_DAC
#if defined(USE_DAC)
AudioControlSGTL5000     dac;
#endif
AudioConnection          patchCord1(ep, 0, out, 0);
AudioConnection          patchCord2(ep, 0, out, 1);

elapsedMillis		since_blink, since_notes;

void setup()
{
	pinMode(LED_BUILTIN, OUTPUT);
	usb_init();
	delay(3000);
	Serial.begin(115200);
	while(!Serial);

	dbg("\nMDA-EP " VERSION " " BUILD_DATE "\n\n");

	// Midi setup
	usbMIDI.setHandleNoteOn(onNoteOn);
	usbMIDI.setHandleNoteOff(onNoteOff);
	delay(100);

	AudioMemory(AUDIO_BUFFERS);
	dbg("Audio lib initialized\n");

#if defined(USE_DAC)
	dac.enable();
	dac.lineOutLevel(29);
	// dac.dacVolumeRamp();
	// dac.dacVolume(1.0);
	// dac.unmuteHeadphone();
	// dac.unmuteLineout();
	// dac.volume(0.8, 0.8); // Headphone volume
#endif
	delay(100);
	dbg("dac initialized\n");

	dbg("voice data is %u samples\n", WAVELEN );
	// dbg("voice data is %u samples\n", sizeof(epianoDataXfade) / sizeof(epianoDataXfade[0]) );
}

bool notes_are_on = false;

void loop()
{
	if (since_notes > 4000) {
		uint8_t x=random(3) + 36;
		if (!notes_are_on) {
			int8_t d=random(40) + 1;
			uint8_t p=random(NPROGS);

			ep.setProgram(p);

			dbg("Key-Down %u %u\n", x, d);
			ep.noteOn(x, d);
			// delay(100);
			// ep.noteOn(4+x, 90+d);
			// delay(100);
			// ep.noteOn(7+x, 90+d);
			// delay(100);
			// ep.noteOn(12+x, 90+d);
			notes_are_on = true;
			since_notes = 2000;
		}
		else {

			dbg("Key-Up\n");
			ep.noteOff(x);
			// ep.noteOff(4+x);
			// ep.noteOff(7+x);
			// ep.noteOff(12+x);
			notes_are_on = false;
			since_notes = 0;
		}
	}

	if (since_blink > 5000) {
		digitalToggleFast(LED_BUILTIN);
		since_blink = 0;
	}

	usbMIDI.read();
}

void onNoteOn(byte chan, byte note, byte vel)
{
	dbg("N=%u ( %u ) c=%u\n", note, vel, chan);

	ep.noteOn( note, vel );
}

void onNoteOff(byte chan, byte note, byte vel)
{
	dbg("N c=%u %u( %u ) off\n", chan, note, vel);
	ep.noteOff( note );
}
