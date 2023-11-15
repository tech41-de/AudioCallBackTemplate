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
    void setup(double sampleRate){
        sr = sampleRate;
    }
    
    void setMicLevel(double volume){
        micLevel = volume;
    }
    
    /*
     Add your DSP code here (no heap allocation, no locks, no file io, no socket calls, no Swift or Objective-C calls.
     You have only a few milliseconds time depending on buffersize and sample rate.
     Calculate: seconds = frames / samplerate
     For example 64 frames at 48000 sample rate gives 0.9583 msec to deliver all samples in this callback
     */
    void render(float * bufferL, float * bufferR, int frames){
        for (int i=0; i<frames; ++i) {
            bufferL[i] = bufferL[i] * micLevel; //
            bufferR[i] = bufferL[i];  // Mic comes in mono on left channel, we copy to right channel as well
        }
    }
    
private:
    double sr = 0.0;
    double micLevel = 0.8;
};

#endif /* DSP_hpp */
