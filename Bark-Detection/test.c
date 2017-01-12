#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include <portaudio.h>
// #include <sndfile.h>
#define SAMPLE_RATE  (44100)
#define SAMPLE_TYPE  paFloat32
#define FRAMES_PER_BUFFER (1024)
#define SAMPLE_SIZE (1)
#define NUM_CHANNELS (1)



/*  Default Values  */
#define ORDER 12
#define WLNG 256
#define EPS 1.0
#define CHANNEL 20
#define USEHAMMING FA
#define DFTMODE FA
#define CZERO FA
#define ENERGY  FA
#define SAMPLEFREQ 16.0
#define ALPHA 0.97
#define LIFT 22
#define WTYPE 0
char *BOOL[] = { "FALSE", "TRUE" };


float avg(float *data)
{
    // int elems = sizeof(data) / sizeof(data[0]);

    float sum = 0;
    for (int i = 0; i < FRAMES_PER_BUFFER; i++)
    {
        sum += fabs(*(data + i));
    }
    return (float) sum / FRAMES_PER_BUFFER;
}

void display(float *data)
{
	for (int i = 0; i < FRAMES_PER_BUFFER; i++)
    {
        printf("%f ", *(data + i));
    }
    printf("\n\n");
}

int main(void)
{
    PaStream *stream = NULL;
    PaError err = paNoError;
    int size = FRAMES_PER_BUFFER * NUM_CHANNELS * SAMPLE_SIZE;
    printf("%d\n", size);
    float *sampleBlock = (float *) malloc(size);
    float *recordedSamples = NULL;


    char *data = (char *) malloc( FRAMES_PER_BUFFER * NUM_CHANNELS * SAMPLE_SIZE  );;


    if((err = Pa_Initialize())) goto done;
    PaStreamParameters inputParameters =
    {
        .device = Pa_GetDefaultInputDevice(),
        .channelCount = NUM_CHANNELS,
        .sampleFormat = SAMPLE_TYPE,
        .suggestedLatency = Pa_GetDeviceInfo(Pa_GetDefaultInputDevice())->defaultHighInputLatency,
        .hostApiSpecificStreamInfo = NULL
    };
    if((err = Pa_OpenStream(&stream, &inputParameters, NULL, SAMPLE_RATE, FRAMES_PER_BUFFER, paClipOff, NULL, NULL))) goto done;
    if((err = Pa_StartStream(stream))) goto done;


    for(int i = 0;;i++) //basically a while 1
    {

        err = Pa_ReadStream(stream, sampleBlock, FRAMES_PER_BUFFER);
        if(avg(sampleBlock) > 0.000550) // high avg amplitude
        {
            printf("%d\tEvent Detected\n", i);
        }
        else 
        {

        	printf("%d\n", i);
        }
    }

done:
	free( data );
    free(sampleBlock);
    Pa_Terminate();
    return err;
}