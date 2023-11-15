# AudioCallBackTemplate
Low Latency Audio Callback Xcode Template in Swift and C++

This template can be used to build audio applications on IoS supporting SwiftUI Gui and fast rendering of Audio DSP code in C++.
The Audio Unit runs in the same process as the host App, which simplifies development.
An auv3 Audio Unit runs in a separate process.Use an auv3 Audio Unit Extension if you are building shared Audio Unit plugins.

- Renders Mic input with low latency to the ouput using Apple RemoteIO
- Setup of the RemoteIO Audio Unit in Swift
- The DSP render code in C++ using an Objective-C Wrapper
- The template handles reconnecting the AVAudioSession when interrupted (phone call, etc.)

On iPhone 12 we typically achieve round trip latencies under 4 ms, which is considered very good.

Test on hardware, audio does not work on the emulator
Best with wired headphones like Apple EarPods, Bluetooth causes latency

Drop me a line at: info@tech41.de and https://www.tech41.de

https://github.com/tech41-de/AudioCallBackTemplate

