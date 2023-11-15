//
//  Wrapper.m
//  AudioCallBackTemplate
//
//  Created by Mathias Dietrich on 15.11.23.
//

#import <Foundation/Foundation.h>
#import "Wrapper.h"

#include "DSP.hpp"


@interface Wrapper ()

@end

@implementation Wrapper
DSP dsp;

-(void) setVolume:(double) volume{
    dsp.setMicLevel(volume);
}

-(void) render:(float *) bufferL frames:(int) frames{
    dsp.render(bufferL, frames);
}

@end



