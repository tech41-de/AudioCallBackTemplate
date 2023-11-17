# AudioCallBackTemplate
Low Latency Audio Callback Xcode Template in Swift and C++ for IoS.

This template can be used to build standalone audio applications on IoS supporting SwiftUI and fast rendering of Audio DSP code in C++.
The Audio Unit runs in the same process as the host App, which speeds up development.

In contrast an auv3 Audio Unit runs in a separate process. Build an auv3 Audio Unit Extension if you are creating shared Audio Unit plugins, for example for Logic Audio.

Our template makes creating an Audio App as simple as possible:

- Renders Mic input with low latency to the ouput using Apple RemoteIO 
- AVAudioSession: Input -> RemoteIO -> Ouput
- Uses RemoteIO Audio Unit created in Swift to provide a Render Callback
- Manages all aspects of AVAudioSession

On iPhone 12 we typically achieve round trip latencies under 4 ms using wired headphones and only 2.5 ms using an Audio Interface like Scarlet USB Interface!
The microphone sound is loud and clear.

Please test always on hardware, audio is not working on the emulator.
Use wired headphones like Apple EarPods or a USB audio interface
Bluetooth causes latency above 160 ms which makes it impossible to monitor yourself in-ear.
If you don't need in-ear monitoring you can change:  .allowBluetoothA2DP to .allowBluetooth to enable selecting a bluetooth microphone

AudioController.swift takes care of abstracting the AVAudioSession and managing the audio devices

DSP.h is where you implement the DSP logic of your app modifying or generating samples

<img src="https://raw.githubusercontent.com/tech41-de/AudioCallBackTemplate/master/AVAudioSession.png" alt="AVAudioSession Diagram" width="300" height="auto">

Test GUI in iPhone:

<img src="https://raw.githubusercontent.com/tech41-de/AudioCallBackTemplate/master/AudioCallbackTemplate.png" alt="Audio Callback Template Screenshot" width="300" height="auto">


To use in your project:
- Add the file AudioController.swift to your project
- In Xcode enable C++ in the Swift Compiler (Targets, Build Settings, Swift Compiler - Language, C++ and Objective-C Interoperability)
- Add a Bridging Header to your project (or rename AudioCallBackTemplate-Bridging-Header.h to fit your project) and make sure there is a referencde to it in Xcode Targets, Build Settings, Swift Compiler - General, Objective-C Bridging Header)
- Add the DSP.h file to your project and implement the render callback

Drop me a line at: mathias.dietrich@tech41.de

Visit our company TECH41 GmbH: https://www.tech41.de

Find the repository (Apache License): https://github.com/tech41-de/AudioCallBackTemplate

Enjoy -:)

