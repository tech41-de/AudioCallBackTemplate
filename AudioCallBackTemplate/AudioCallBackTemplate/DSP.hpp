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
    
    void render(float * bufferL, float * bufferR, int frames){
        for (int i=0; i<frames; ++i) {
            bufferL[i] = bufferL[i] * micLevel;
            bufferR[i] = bufferL[i];  // Mic is mono on left channel, we send to right channel as well
        }
    }
    
private:
    double sr = 0.0;
    double micLevel = 0.8;
    
};

#endif /* DSP_hpp */
