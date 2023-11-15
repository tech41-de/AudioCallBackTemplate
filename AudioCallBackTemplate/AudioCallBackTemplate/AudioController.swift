//
//  AudioController.swift
//  AudioCallBackTemplate
//
//  Created by Mathias Dietrich on 15.11.23.
//

import Foundation
import DspModule

class AudioController{
    
    var dsp = DSP()
    
    func setup(){
        //dsp.setup(sampleRate)
    }
    
    func setMicVolume(volume:Double){
        dsp.setMicLevel(volume)
    }
}
