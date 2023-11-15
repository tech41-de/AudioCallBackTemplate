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
    
    void render(float * bufferL, int frames){
        for (int i=0; i<frames; ++i) {
            bufferL[i] = bufferL[i] * micLevel;
        }
    }
    
private:
    double sr = 0.0;
    double micLevel = 0.8;
    
};

#endif /* DSP_hpp */
