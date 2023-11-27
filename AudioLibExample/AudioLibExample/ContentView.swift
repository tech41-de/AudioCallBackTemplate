//
//  ContentView.swift
//  AudioLibExample
//
//  Created by Mathias Dietrich on 17.11.23.
//

import SwiftUI

struct ContentView: View {
    
    @State var midiListener = MidiListener()
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("MidiListener")
        }
        .padding().onAppear(){

        }.onAppear(){
            midiListener.start()
        }
    }
}

#Preview {
    ContentView()
}
