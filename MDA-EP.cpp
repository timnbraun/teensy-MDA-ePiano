
#include <Arduino.h>
#include <Audio.h>
#include <TimedBlink.h>
#define NPROGS 2
#define WAVELEN 11240
#include <synth_mda_epiano.h>

#define dbg(...) \
	Serial.printf( __VA_ARGS__ )

void onNoteOn(byte chan, byte note, byte vel);
void onNoteOff(byte chan, byte note, byte vel);

class AudioSynthSine : public AudioSynthWaveformSine
{
	public:
		void noteOn( uint16_t note, uint16_t vel ) { amplitude(1.0); };
		void noteOff( uint16_t note ) { amplitude(0.0); };
		void setProgram( uint16_t p ) { frequency(440); };
};

#if defined(ARDUINO_TEENSYLC)

#define USE_SINE
#define EP_VOICES 2
#define NUM_AUDIO_BUFFERS 4

#elif defined(ARDUINO_TEENSY32)

#define USE_SINE
#define EP_VOICES 16
#define NUM_AUDIO_BUFFERS 16

#elif defined(ARDUINO_TEENSY40)

#define EP_VOICES 32
#define NUM_AUDIO_BUFFERS 64

#endif

#if defined(USE_SINE)
AudioSynthSine   		ep;
#else
AudioSynthEPiano        ep(EP_VOICES);
#endif
AudioOutputI2S          out;
// #define USE_DAC
#if defined(USE_DAC)
AudioControlSGTL5000    dac;
#endif
AudioConnection         patchCord1(ep, 0, out, 0);
AudioConnection         patchCord2(ep, 0, out, 1);

TimedBlink				heart(LED_BUILTIN);

elapsedMillis			since_blink, since_notes;

void setup()
{
	heart.blink(250, 250);
	Serial.begin(115200);
	digitalWrite(LED_BUILTIN, HIGH);
	delay(3000);
	// while(!Serial);

	dbg("\nMDA-EP " VERSION " " BUILD_DATE "\n\n");

	AudioMemory( NUM_AUDIO_BUFFERS );
	dbg("Audio lib initialized\n");

	// Midi setup
	usbMIDI.setHandleNoteOn(onNoteOn);
	usbMIDI.setHandleNoteOff(onNoteOff);
	digitalWrite(LED_BUILTIN, LOW);
	delay(100);

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
	heart.heartbeat( 200, 2000 - (3*200), 2 );
}

bool notes_are_on = false;

void loop()
{
	if (since_notes > 4000) {
		static uint8_t root_note;
		if (!notes_are_on) {
			int8_t loud = random(40) + 1;
			uint8_t new_program = random(NPROGS);
			root_note = random(12) + 36;

			ep.setProgram( new_program );

			dbg("Key-Down %u %u\n", root_note, loud);
			ep.noteOn(root_note, loud);
			#if !defined(USE_SINE)
			delay(100);
			ep.noteOn(4+root_note, 90+loud);
			delay(100);
			ep.noteOn(7+root_note, 90+loud);
			delay(100);
			ep.noteOn(12+root_note, 90+loud);
			#endif
			notes_are_on = true;
			since_notes = 2000;
		}
		else {

			dbg("Key-Up %u\n", root_note);
			ep.noteOff(root_note);
			#if !defined(USE_SINE)
			ep.noteOff(4+root_note);
			ep.noteOff(7+root_note);
			ep.noteOff(12+root_note);
			#endif
			notes_are_on = false;
			since_notes = 0;
		}
	}

#if 0
	if (since_blink > 2000) {
		digitalToggleFast(LED_BUILTIN);
		since_blink = 0;
	}
#endif
	heart.loop();

	usbMIDI.read();

	switch (Serial.read()) {
	case 'a':
		dbg("AudioMemoryUsage() = %u\n", AudioMemoryUsage() );
	break;
	case 'i':
		dbg("an i for an i\n");
	break;
	default: ;
	}
}

void onNoteOn(byte chan, byte note, byte vel)
{
	dbg("N=%u ( %u ) c=%u\n", note, vel, chan);

	// ep.noteOn( note, vel );
}

void onNoteOff(byte chan, byte note, byte vel)
{
	dbg("N c=%u %u( %u ) off\n", chan, note, vel);
	// ep.noteOff( note );
}
