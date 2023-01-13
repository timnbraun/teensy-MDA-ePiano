
#include <Arduino.h>

#define dbg_putc(c) \
	fputc((c), stderr)


#define dbg( ... ) \
	Serial.printf( __VA_ARGS__ )


elapsedMillis 			since_LED_switch, since_hello;

void setup() 
{
	pinMode(LED_BUILTIN, OUTPUT);

	Serial.begin(115200);

	dbg("\nhello-teensy4 " VERSION " " BUILD_DATE "\n\n");
}

void loop() 
{
	if (since_LED_switch > 1500) {
		digitalToggleFast(LED_BUILTIN);
		since_LED_switch = 0;
	}
	if (since_hello > 5000) {
		static unsigned int loop = 0;

		dbg("hello-teensy4 " VERSION " " BUILD_DATE "%4u\n", loop);
		loop++;
		since_hello = 0;
	}

	Serial.read();
	usbMIDI.read();
}
