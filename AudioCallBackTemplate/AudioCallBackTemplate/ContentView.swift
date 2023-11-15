//
//  ContentView.swift
//  AudioCallBackTemplate
//
//  Created by Mathias Dietrich info@tech41.de on 15.11.23.
//

import SwiftUI

//c++ and Objective-C Interoperability set to C++ / Objective-C++ in XCode Swift Compiler Language

struct ContentView: View {
    @State private var volume = 0.8
    @State private var isEditing = false
    

    
    let controller = AudioController()
    
    var body: some View {
        VStack {
            Text("Audio Callback").font(.system(size: 36)).foregroundColor(.orange)
            Spacer().frame(height: 30)
            Text("\(volume)").font(.system(size: 36))
                .foregroundColor(isEditing ? .red : .blue)
            Slider(
               value: $volume,
               in: 0...1.6,
               onEditingChanged: { editing in
                   isEditing = editing
                   controller.setMicVolume(volume: volume)
               }
            )
            Image(systemName: "mic").font(Font.title.weight(.ultraLight))
            
            
            Spacer().frame(height: 30)
            Text("Best use with wired headphones for low latency and to avoid any feedback").font(.system(size: 16)).foregroundColor(.gray)
        }
        .padding().onAppear(){
           
        }
    }
}

#Preview {
    ContentView()
}
