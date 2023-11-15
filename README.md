# AudioCallBackTemplate
Low Latency Audio Callback Template in Swift and C++

This template can be used to build audio applications on IoS supporting SwiftUI Gui and fast rendering of Audio in C++

- Renders the Mic input with low latency to the ouput using Apple RemoteIO
- Runs in the same process as the host (simplifies the architecture by not using an auv3 Audio Unit. Use sn auv3 Audio Unit if you are building Audio Unit plugins)
- Setting up the RemoteIO Audio Unit is in Swift
- The DSP render code is in C++ over an Objective-C Wrapper
- The template handles reconnecting the AVAudioSession when interrupted (phone call, etc.)

On iPhone 12 we can achieved a Latency of 2.34 ms, which is considered as very good.

Test on hardware, audio does not work on the emulator

You can contact us at: info@tech41.de

