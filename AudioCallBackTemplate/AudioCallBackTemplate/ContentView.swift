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
    
    let controller = AudioController()
    @State private var volume = 0.8
    @State private var isEditing = false
    @State private var latency = 0.0
    @State private var sampleRate = 0
    
    var body: some View {
        VStack {
            Text("Audio Callback").font(.system(size: 36)).foregroundColor(.orange)
            Spacer().frame(height: 30)
            Text("\(volume)").font(.system(size: 36))
                .foregroundColor(isEditing ? .red : .blue)
            Slider(
               value: $volume,
               in: 0...3.0) // this one can go to eleven, one louder ;-) use careful!
            Image(systemName: "mic").font(Font.title.weight(.ultraLight))
            Spacer().frame(height: 20)
            Text("Latency: \(latency * 1000) ms")
            Text("Sample Rate:" + String(sampleRate))
            Spacer().frame(height: 30)
            Text(text).font(.system(size: 16)).foregroundColor(.gray)
        }.onChange(of: volume) {
            controller.setMicVolume(volume: volume)
        }
        .padding().onAppear(){
            latency = controller.startIOUnit()
            sampleRate = controller.sampleRate
        }.frame(maxWidth:.infinity, maxHeight:.infinity).background(.black)
    }
}

#Preview {
    ContentView()
}
