//
//  Wrapper.h
//  AudioCallBackTemplate
//
//  Created by Mathias Dietrich on 15.11.23.
//

#ifndef Wrapper_h
#define Wrapper_h

#import <UIKit/UIKit.h>


@interface Wrapper : NSObject{
    
}
-(void) setVolume:(double) volume;
-(void) setVolume:(double) volume;

-(void) render:(float *) bufferL right: (float *) bufferR size:(int) size;

@end

#endif /* Wrapper_h */
