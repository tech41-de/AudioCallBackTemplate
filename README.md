# AudioCallBackTemplate
Low Latency Audio Callback Xcode Template in Swift and C++

This template can be used to build audio applications on IoS supporting SwiftUI and fast rendering of Audio DSP code in C++.
The Audio Unit runs in the same process as the host App, which simplifies development.
An auv3 Audio Unit runs in a separate process. Use an auv3 Audio Unit Extension if you are building shared Audio Unit plugins.

Our template is as simple as possible:

- Renders Mic input with low latency to the ouput using Apple RemoteIO 
- AVAudioSession: Input -> RemoteIO -> Ouput
- Setup of the RemoteIO Audio Unit in Swift
- Manages the AVAudioSession when interrupted (phone call, etc.)

On iPhone 12 we typically achieve round trip latencies under 4 ms using wired headphones and only 2.5 ms using a Scarlet USB Interface!
The microphone sound is loud and clear.

Please test always on hardware, audio is not working on the emulator.
Best with wired headphones like Apple EarPods.
Bluetooth causes latency.

![Audio CallBack Template](https://github.com/tech41-de/AudioCallBackTemplate/AudioCallBackTemplate.png)

Drop me a line at: 
mathias.dietrich@tech41.de

Visit our company TECH41 at:
https://www.tech41.de

Find the repository (Apache License) at:
https://github.com/tech41-de/AudioCallBackTemplate

