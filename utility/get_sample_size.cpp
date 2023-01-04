
#include <cstdint>
#include <cstdio>
#include <cstdlib>

#define PROGMEM

#include <mdaEPianoData.h>
#undef MDAEPIANODATA_H_INCLUDED
#define USE_XFADE_DATA
#include <mdaEPianoDataXfade.h>

/*
 * The PianoData array is 844836 bytes, the DataXfade array is 844836 bytes
 */
int main()
{
	printf("The PianoData array is %lu bytes, the DataXfade array is %lu bytes\n",
		sizeof(epianoData), 
		sizeof(epianoDataXfade) ); 
	return 0;
}
