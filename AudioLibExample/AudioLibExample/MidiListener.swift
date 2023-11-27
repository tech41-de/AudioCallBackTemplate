//
//  MidiListener.swift
//  AudioLibExample
//
//  Created by Mathias Dietrich on 17.11.23.
//

import Foundation
import AudioKit

class MidiListener: MIDIListener{
    func receivedMIDINoteOff(noteNumber: AudioKit.MIDINoteNumber, velocity: AudioKit.MIDIVelocity, channel: AudioKit.MIDIChannel, portID: MIDIUniqueID?, timeStamp: MIDITimeStamp?) {
        
    }
    
    func receivedMIDIController(_ controller: AudioKit.MIDIByte, value: AudioKit.MIDIByte, channel: AudioKit.MIDIChannel, portID: MIDIUniqueID?, timeStamp: MIDITimeStamp?) {
        
    }
    
    func receivedMIDIAftertouch(noteNumber: AudioKit.MIDINoteNumber, pressure: AudioKit.MIDIByte, channel: AudioKit.MIDIChannel, portID: MIDIUniqueID?, timeStamp: MIDITimeStamp?) {
        
    }
    
    func receivedMIDIAftertouch(_ pressure: AudioKit.MIDIByte, channel: AudioKit.MIDIChannel, portID: MIDIUniqueID?, timeStamp: MIDITimeStamp?) {
        
    }
    
    func receivedMIDIPitchWheel(_ pitchWheelValue: AudioKit.MIDIWord, channel: AudioKit.MIDIChannel, portID: MIDIUniqueID?, timeStamp: MIDITimeStamp?) {
        
    }
    
    func receivedMIDIProgramChange(_ program: AudioKit.MIDIByte, channel: AudioKit.MIDIChannel, portID: MIDIUniqueID?, timeStamp: MIDITimeStamp?) {
        
    }
    
    func receivedMIDISystemCommand(_ data: [AudioKit.MIDIByte], portID: MIDIUniqueID?, timeStamp: MIDITimeStamp?) {
        
    }
    
    func receivedMIDISetupChange() {
        
    }
    
    func receivedMIDIPropertyChange(propertyChangeInfo: MIDIObjectPropertyChangeNotification) {
        
    }
    
    func receivedMIDINotification(notification: MIDINotification) {
        
    }
    
   func start(){
        let midi = MIDI.sharedInstance
       midi.addListener(self)
        midi.openInput()

    }
    
    func receivedMIDINoteOn(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel, portID: MIDIUniqueID?, timeStamp: MIDITimeStamp?) {
        print(noteNumber)
        //sampler.play(noteNumber: noteNumber, velocity: velocity, channel: channel)
    }
}
