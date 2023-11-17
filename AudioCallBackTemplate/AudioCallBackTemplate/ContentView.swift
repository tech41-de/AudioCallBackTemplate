//
//  ContentView.swift
//  AudioCallBackTemplate
//
//  Created by Mathias Dietrich info@tech41.de on 15.11.23.
//

import SwiftUI

struct ContentView: View {
    
    let text = """
Use wired headphones:
- Low latency (Bluetooth causes latency)
- Avoid feedback
"""
    
    @ObservedObject private var controller = AudioController.shared
    @State private var volume = 0.5
    @State private var isEditing = false
    
    func setSpeaker(isSpeaker:Bool){
        controller.setSpeaker(isSpeaker: isSpeaker)
    }
    
    var body: some View {
        ScrollView{
            VStack {
                Text("Audio Callback").font(.system(size: 36)).foregroundColor(.orange)
                Spacer().frame(height: 30)
                
                Image(systemName: "mic").font(Font.title.weight(.ultraLight))
                Text("\(volume)").font(.system(size: 36)).foregroundColor(isEditing ? .red : .blue)
                Slider(value: $volume, in: 0...1.0) // this one can go to eleven, one louder ;-) use careful!
                
                Spacer().frame(height: 20)
                Text("Latency: \(controller.latency * 1000) ms")
                Text("Frames: \(controller.frames)")
                Text("Sample Rate: " + String(controller.sampleRate))
                
                Divider()
                Text("Input Devices").foregroundColor(.blue).font(.system(size: 16))
                Picker("Mic", selection: $controller.inputDeviceName) {
                    if(controller.inputs.count > 0){
                        ForEach(controller.inputs, id: \.self) { status in
                            Text(status).foregroundColor(.white).font(.system(size: 16))
                        }.onChange(of: controller.inputDeviceName) { _old, _name in
                            controller.setInputDevice(name:_name)
                        }
                    }else{
                        Text("No MIC - plug in Earbuds or USB AudioInterface").foregroundColor(.white).font(.system(size: 16))
                    }
                }
                .pickerStyle(.segmented).foregroundColor(.white).font(.system(size: 16))
                
                Text("Output Device").foregroundColor(.blue).font(.system(size: 16))
                Picker("Output Device", selection: $controller.outputDeviceName) {
                    if(controller.outputs.count > 0){
                        ForEach(controller.outputs, id: \.self) { status in
                            Text(status).foregroundColor(.white).font(.system(size: 16))
                        }.onChange(of: controller.outputDeviceName) { _old, _name in
                            controller.setOutputDevice(name:_name)
                        }
                    }else{
                        Text("No Output Device?").foregroundColor(.white).font(.system(size: 16))
                    }
                }.pickerStyle(.segmented).foregroundColor(.white).font(.system(size: 16))
               // Text("\(controller.outputDeviceName)").font(.system(size: 26)).foregroundColor(.blue)
    
                Toggle("Speaker", isOn: $controller.isOnSpeaker).padding(.trailing, 5).onChange(of: controller.isOnSpeaker) {old,  _isOn in
                    setSpeaker(isSpeaker:controller.isOnSpeaker)
                    controller.getDevices()
                }
                
                Spacer().frame(height: 30)
                Text("Are headphones connected: \(controller.isHeadphonesConnected.description)").font(.system(size: 16)).foregroundColor(.blue)

                Spacer().frame(height: 30)
                Text(text).font(.system(size: 16)).foregroundColor(.gray)
                    
            }.onChange(of: volume) {
                controller.setMicVolume(volume: volume)
            }
            .padding().onAppear(){
                controller.preferedFrames = 64
                controller.preferedSampleRate = 48000 // this starts AVSession
                controller.setup()
            }
        }.frame(maxWidth:.infinity, maxHeight:.infinity).background(.black)
    }
    
    func go(){
        controller.preferedFrames = 128
    }
}

