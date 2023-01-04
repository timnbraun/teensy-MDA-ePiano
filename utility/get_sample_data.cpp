
#include <cstdint>
#include <cstdio>
#include <cstdlib>

#define PROGMEM

#include <mdaEPianoData.h>
#undef MDAEPIANODATA_H_INCLUDED
#define USE_XFADE_DATA
#include <mdaEPianoDataXfade.h>

void write( const char *name, const void *data, 
	const size_t el, const size_t count )
{
	FILE *file = fopen( name, "wb");

	fwrite( data, el, count, file );

	fclose( file );
}

/*
 * The PianoData array is 844836 bytes, the DataXfade array is 844836 bytes
 */
int main()
{
	printf("The PianoData array is %lu bytes, the DataXfade array is %lu bytes\n",
		sizeof(epianoData), 
		sizeof(epianoDataXfade) ); 

	write("piano.dat", epianoData, sizeof(epianoData[0]), 
		sizeof(epianoData)/sizeof(epianoData[0]) );

	write("piano-xfade.dat", epianoDataXfade, sizeof(epianoDataXfade[0]), 
		sizeof(epianoDataXfade)/sizeof(epianoDataXfade[0]) );

	return 0;
}
