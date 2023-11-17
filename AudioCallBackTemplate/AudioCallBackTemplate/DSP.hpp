//
//  DSP.hpp
//  AudioCallBackTemplate
//
//  Created by Mathias Dietrich on 15.11.23.
//

#ifndef DSP_hpp
#define DSP_hpp

#include <stdio.h>

class DSP{
    
public:
    
    /*
     Setup can be called again  in case sample rate or expected blocksize changes when the user changes device
     */
    void setup(double sampleRate, int expectedBlocksize){
        sr = sampleRate;
        blocksize = expectedBlocksize;
    }
    
    void setMicLevel(double volume){
        micLevel = volume;
    }
    
    /*
     Add your DSP code here (no heap allocation, no locks, no file io, no socket calls, no Swift or Objective-C calls.
     You have only a few milliseconds time depending on buffersize and sample rate.
     Calculate: seconds = frames / samplerate
     For example 64 frames at 48000 sample rate gives 0.9583 msec to deliver all samples in this callback
     Blocksize can vary on a render call and can be different to expected block size
     */
    void render(float * bufferL, float * bufferR, int blocksize){
        for (int i=0; i<blocksize; ++i) {
            float sample = bufferL[i] * micLevel; //
            if(bufferL[i] <= 1.0 || bufferL[i] >= -1.0){ // render guard - not absolutely necxcesary if the DSP is correct staying in bounds -1.0 to 1.0
                bufferL[i] = sample;
                bufferR[i] = sample; // Mic comes in mono on left channel, we copy to right channel as well
            }else{
                // we receive Samples outside the correct range, hard limiting to -1.0 and 1.0
                if (sample > 0){
                    bufferL[i] = 1.0;
                    bufferR[i] = 1.0;
                }else{
                    bufferL[i] = -1.0;
                    bufferR[i] = -1.0;
                }
            }
        }
    }
    
private:
    double sr = 0.0;
    int blocksize = 0;
    double micLevel = 0.5;
};

#endif /* DSP_hpp */
