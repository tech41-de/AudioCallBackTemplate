//
//  ContentView.swift
//  AudioCallBackTemplate
//
//  Created by Mathias Dietrich info@tech41.de on 15.11.23.
//

import SwiftUI

struct ContentView: View {
    
    let text = """
Best use with wired headphones:
- Low latency (Bluetooth causes latency)
- Avoid any feedback
"""
    
    @State var controller = AudioController()
    @State private var volume = 0.8
    @State private var isEditing = false
  
    func setSpeaker(isSpeaker:Bool){
        do{

        }catch{
            
        }
    }
    
    var body: some View {
        VStack {
            Text("Audio Callback").font(.system(size: 36)).foregroundColor(.orange)
            Spacer().frame(height: 30)
            
            Image(systemName: "mic").font(Font.title.weight(.ultraLight))
            Text("\(volume)").font(.system(size: 36)).foregroundColor(isEditing ? .red : .blue)
            Slider(value: $volume, in: 0...3.0) // this one can go to eleven, one louder ;-) use careful!
            
            Spacer().frame(height: 20)
            Text("Latency: \(controller.latency * 1000) ms")
            Text("Sample Rate: " + String(controller.sampleRate))
            
            Divider()
            Text("Input Devices").foregroundColor(.blue).font(.system(size: 16))
            Picker("Mic", selection: $controller.inputDeviceName) {
                if(controller.inputs.count > 0){
                    ForEach(controller.inputs, id: \.self) { status in
                        Text(status).foregroundColor(.white).font(.system(size: 16))
                    }.onChange(of: controller.inputDeviceName) { _name in
                        controller.inputDeviceName = _name
                    }
                }else{
                    Text("No MIC - plug in Earbuds or USB AudioInterface").foregroundColor(.white).font(.system(size: 16))
                }
            }
            .pickerStyle(.segmented).foregroundColor(.white).font(.system(size: 16))
            Toggle("Speaker", isOn: $controller.isOnSpeaker).padding(.trailing, 5).onChange(of: controller.isOnSpeaker) { _isOn in
                controller.isOnSpeaker = _isOn
            }
            
            Spacer().frame(height: 30)
            Text("isOnSpeaker \(controller.isOnSpeaker.description)").font(.system(size: 16)).foregroundColor(.blue)
            Text("isHeadphonesConnected \(controller.isHeadphonesConnected.description)").font(.system(size: 16)).foregroundColor(.blue)
            Text("inputDeviceName \(controller.inputDeviceName)").font(.system(size: 16)).foregroundColor(.blue)
            Text("inputDeviceId \(controller.inputDeviceId)").font(.system(size: 16)).foregroundColor(.blue)
            Text("outputDeviceName \(controller.outputDeviceName)").font(.system(size: 16)).foregroundColor(.blue)
            Text("outputDeviceId \(controller.outputDeviceId)").font(.system(size: 16)).foregroundColor(.blue)
            
            Spacer().frame(height: 30)
            Text(text).font(.system(size: 16)).foregroundColor(.gray)
        }.onChange(of: volume) {
            controller.setMicVolume(volume: volume)
        }
        .padding().onAppear(){

        }.frame(maxWidth:.infinity, maxHeight:.infinity).background(.black)
    }
}

#Preview {
    ContentView()
}
