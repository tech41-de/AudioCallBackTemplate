//
//  ContentView.swift
//  AudioCallBackTemplate
//
//  Created by Mathias Dietrich info@tech41.de on 15.11.23.
//

import SwiftUI

struct ContentView: View {
    @State private var volume = 0.8
    @State private var isEditing = false
    
    var body: some View {
        VStack {
            Text("Audio Callback").font(.system(size: 36))
            Spacer().frame(height: 30)
            Text("\(volume)").font(.system(size: 36))
                .foregroundColor(isEditing ? .red : .blue)
            Slider(
               value: $volume,
               in: 0...1.6,
               onEditingChanged: { editing in
                   isEditing = editing
               }
            )
            Image(systemName: "mic").font(Font.title.weight(.ultraLight))
            
            
            Spacer().frame(height: 30)
            Text("Best use with wired headphones for low latency and to avoid any feedback").font(.system(size: 16)).foregroundColor(.gray)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
