//
//  AudioController.swift
//  AudioCallBackTemplate
//
//  Created by Mathias Dietrich info@tech41.de on 15.11.23.
//
// based on:
//  aurioTouch
//  Translated by OOPer in cooperation with shlab.jp, on 2015/1/31.
//
// output select  - profiling
//
import AudioToolbox
import AVFoundation
import DSP

@objc protocol AURenderCallbackDelegate {
    func performRender(_ ioActionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>,
        inTimeStamp: UnsafePointer<AudioTimeStamp>,
        inBufNumber: UInt32,
        inNumberFrames: UInt32,
        ioData: UnsafeMutablePointer<AudioBufferList>) -> OSStatus
}

private let AudioController_RenderCallback: AURenderCallback = {(inRefCon,
        ioActionFlags/*: UnsafeMutablePointer<AudioUnitRenderActionFlags>*/,
        inTimeStamp/*: UnsafePointer<AudioTimeStamp>*/,
        inBufNumber/*: UInt32*/,
        inNumberFrames/*: UInt32*/,
        ioData/*: UnsafeMutablePointer<AudioBufferList>*/)
    -> OSStatus
in
    let delegate = unsafeBitCast(inRefCon, to: AURenderCallbackDelegate.self)
    let flags = UnsafeMutablePointer<AudioUnitRenderActionFlags>(bitPattern:1) // TODO fix this hack
    let result = delegate.performRender(flags!,
        inTimeStamp: inTimeStamp,
        inBufNumber: inBufNumber,
        inNumberFrames: inNumberFrames,
        ioData: ioData!)
    return result
}

@objc(AudioController)
class AudioController: NSObject, ObservableObject, AURenderCallbackDelegate {

    var dsp = DSP() // DSP receives the render buffer
    
    static let shared = AudioController()
    
    @Published var inputDeviceName : String = ""
    @Published var latency = 0.0
    @Published var inputLatency = 0.0
    @Published var outputLatency = 0.0
    @Published var sampleRate = 48000 // 48000
    @Published var frames = 0
    @Published var preferedFrames = 64
    @Published var preferedSampleRate = 48000
    @Published var isOnSpeaker = false
    @Published var isHeadphonesConnected = false
    
    @Published var inputDeviceId : String = ""
    @Published var outputDeviceName : String = ""
    @Published var outputDeviceId : String = ""
    @Published var inputs : [String] = []
    @Published var outputs : [String] = []
    
    var isSetup = false
    
    // Configure the audio session
    let sessionInstance = AVAudioSession.sharedInstance()
    
    var _rioUnit: AudioUnit? = nil
    private(set) var audioChainIsBeingReconstructed: Bool = false

    override init() {
        super.init()
    }
    
    // Render callback function - here we receive the samples to pass on to our DSP code
    func performRender(
        _ ioActionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>,
        inTimeStamp: UnsafePointer<AudioTimeStamp>,
        inBufNumber: UInt32,
        inNumberFrames: UInt32,
        ioData: UnsafeMutablePointer<AudioBufferList>) -> OSStatus
    {
        var err: OSStatus = noErr
        if audioChainIsBeingReconstructed{
            return err
        }

        let uint32Pointer : UnsafeMutablePointer<UInt32>? = UnsafeMutablePointer<UInt32>.allocate(capacity: 1) // TODO fix this hack
        err = AudioUnitRender(_rioUnit!, uint32Pointer, inTimeStamp, 1, inNumberFrames, ioData)
        let ioPtr = UnsafeMutableAudioBufferListPointer(ioData)
        let mBufferL : AudioBuffer = ioPtr[0]
        let mBufferR : AudioBuffer = ioPtr[1]
        let dataPointerL = UnsafeMutableRawPointer(mBufferL.mData)
        let dataPointerR = UnsafeMutableRawPointer(mBufferR.mData)
        let count = Int(mBufferL.mDataByteSize) / 4
        if let dptr = dataPointerL {
            let dptrR = dataPointerR
            let sampleArrayL = dptr.assumingMemoryBound(to: Float32.self)
            let sampleArrayR = dptrR!.assumingMemoryBound(to: Float32.self)
            dsp.render(sampleArrayL, sampleArrayR, Int32(count))
        }
        return err
    }
    
    func updateView(){
        objectWillChange.send()
    }
    
    // Example of calling DSP code from the UI
    func setMicVolume(volume: Double){
        dsp.setMicLevel(volume)
    }
    
    func setSpeaker(isSpeaker:Bool){
        do{
            if(isSpeaker){
                try sessionInstance.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
            }else{
                try sessionInstance.overrideOutputAudioPort(AVAudioSession.PortOverride.none)
            }
        }catch{
            print(error.localizedDescription)
        }
        updateView()
    }

    func isCurrentOutput(portType: AVAudioSession.Port) -> Bool {
        AVAudioSession.sharedInstance().currentRoute.outputs.contains(where: { $0.portType == portType })
    }
    
    func setOutputDevice(name:String){
        // TODO
    }
    
    func setInputDevice(name:String){
        guard let availableInputs = AVAudioSession.sharedInstance().availableInputs else {
            print("No inputs available ")
            return
        }
        
        for audioPort in availableInputs {
            if(audioPort.portName == name){
                setPreferredInput(port:audioPort)
            }
        }
    }
    
    func setPreferredInput(port: AVAudioSessionPortDescription) {
          do {
              try AVAudioSession.sharedInstance().setPreferredInput(port)
          } catch let error as NSError {
              print("audioSession error change to input: \(port.portName) with error: \(error.localizedDescription)")
          }
    }
    
    // handles interruption of AVAudioSession, for example an incoming phone call. After the call we are restarting the AVAudioSession
    @objc func handleInterruption(_ notification: Notification) {
        let theInterruptionType = (notification as NSNotification).userInfo![AVAudioSessionInterruptionTypeKey] as! UInt
        NSLog("Session interrupted > --- %@ ---\n", theInterruptionType == AVAudioSession.InterruptionType.began.rawValue ? "Begin Interruption" : "End Interruption")
        
        if theInterruptionType == AVAudioSession.InterruptionType.began.rawValue {
            self.stopIOUnit()
        }
        
        if theInterruptionType == AVAudioSession.InterruptionType.ended.rawValue {
            // make sure to activate the session
            do {
                try sessionInstance.setActive(true)
            } catch let error as NSError {
                NSLog("AVAudioSession set active failed with error: %@", error)
            } catch {
                fatalError()
            }
            self.startIOUnit()
        }
    }
    
    // Called when the user changes the Audio device, for example pluging in headphones
    @objc func handleRouteChange(_ notification: Notification) {
        let reasonValue = (notification as NSNotification).userInfo![AVAudioSessionRouteChangeReasonKey] as! UInt
        let routeDescription = (notification as NSNotification).userInfo![AVAudioSessionRouteChangePreviousRouteKey] as! AVAudioSessionRouteDescription?
        
        guard let userInfo = notification.userInfo,
            let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
            let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else {
                return
        }
        
        // logging the change
        NSLog("Route change:")
        if let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) {
            switch reason {
            case .newDeviceAvailable:
                NSLog("     NewDeviceAvailable")
                let session = AVAudioSession.sharedInstance()
                isHeadphonesConnected = hasHeadphones(in: session.currentRoute)
            case .oldDeviceUnavailable:
                NSLog("     OldDeviceUnavailable")
                if let previousRoute =
                    userInfo[AVAudioSessionRouteChangePreviousRouteKey] as? AVAudioSessionRouteDescription {
                    isHeadphonesConnected = hasHeadphones(in: previousRoute)
                }
            case .categoryChange:
                NSLog("     CategoryChange")
                NSLog(" New Category: %@", AVAudioSession.sharedInstance().category.rawValue)
            case .override:
                NSLog("     Override")
            case .wakeFromSleep:
                NSLog("     WakeFromSleep")
            case .noSuitableRouteForCategory:
                NSLog("     NoSuitableRouteForCategory")
            case .routeConfigurationChange:
                NSLog("     RouteConfigurationChange")
            case .unknown:
                NSLog("     Unknown")
            @unknown default:
                NSLog("     UnknownDefault(%zu)", reasonValue)
            }
        } else {
            NSLog("     ReasonUnknown(%zu)", reasonValue)
        }
        
        if let prevRout = routeDescription {
            NSLog("Previous route:\n")
            NSLog("%@", prevRout)
            NSLog("Current route:\n")
            NSLog("%@\n", AVAudioSession.sharedInstance().currentRoute)
        }
        
        DispatchQueue.main.async {
            self.reset()
            self.getDevices()
            self.updateView()
        }
    }
    
    // Under rare circumstances the system terminates and restarts its media services daemon.
    @objc func handleMediaServerReset(_ notification: Notification) {
        NSLog("Media server has reset")
        reset()
    }
    
    func hasHeadphones(in routeDescription: AVAudioSessionRouteDescription) -> Bool {
        // Filter the outputs to only those with a port type of headphones.
        return !routeDescription.outputs.filter({$0.portType == .headphones}).isEmpty
    }
    
    func getDevices(){
        inputs.removeAll()
        guard let availableInputs = AVAudioSession.sharedInstance().availableInputs else {
            print("No inputs available ")
            return
        }
        
        for audioPort in availableInputs {
            inputs.append(audioPort.portName)
        }
        if(sessionInstance.currentRoute.inputs.first != nil){
            inputDeviceName =  AVAudioSession.sharedInstance().currentRoute.inputs.first!.portName
            inputDeviceId =  AVAudioSession.sharedInstance().currentRoute.inputs.first!.uid
        }
        
        outputs.removeAll()
        let availableOutputs =  sessionInstance.currentRoute.outputs
        for audioPort in availableOutputs {
           outputs.append(audioPort.portName)
        }
        if(AVAudioSession.sharedInstance().currentRoute.outputs.first != nil){
            outputDeviceName =  sessionInstance.currentRoute.outputs.first!.portName
            outputDeviceId =  AVAudioSession.sharedInstance().currentRoute.outputs.first!.uid
        }
        updateView()
    }
    
    private func setupAudioSession() {
        do {
            // we are going to play and record so we pick that category
            do {
                if #available(iOS 10.0, *) {
                    try sessionInstance.setCategory(.playAndRecord,mode: .default,  options: [.mixWithOthers, .allowBluetoothA2DP])  //.allowBluetooth
                } else {
                    try sessionInstance.setCategory(.playAndRecord)
                }
            } catch let error as NSError {
                try XExceptionIfError(error, "couldn't set session's audio category")
            } catch {
                fatalError()
            }
            
            let duration = Double(preferedFrames) / Double(sampleRate)
            let bufferDuration: TimeInterval =  duration //1.0/ 1000.0 // Secconds
            do {
                try sessionInstance.setPreferredIOBufferDuration(bufferDuration)
            } catch let error as NSError {
                try XExceptionIfError(error, "couldn't set session's I/O buffer duration")
            } catch {
                fatalError()
            }
            
            do {
                // set the session's sample rate
                try sessionInstance.setPreferredSampleRate(Double(preferedSampleRate)) // Samples per second
            } catch let error as NSError {
                try XExceptionIfError(error, "couldn't set session's preferred sample rate")
            } catch {
                fatalError()
            }
            
            // add interruption handler
            NotificationCenter.default.addObserver(self,
                selector: #selector(self.handleInterruption(_:)),
                name: AVAudioSession.interruptionNotification,
                object: sessionInstance)
            
            // we don't do anything special in the route change notification
            NotificationCenter.default.addObserver(self,
                selector: #selector(self.handleRouteChange(_:)),
                name: AVAudioSession.routeChangeNotification,
                object: sessionInstance)
            
            // if media services are reset, we need to rebuild our audio chain
            NotificationCenter.default.addObserver(self,
                selector: #selector(self.handleMediaServerReset(_:)),
                name: AVAudioSession.mediaServicesWereResetNotification,
                object: sessionInstance)
            
            do {
                // activate the audio session
                try sessionInstance.setActive(true)
                inputLatency = sessionInstance.inputLatency
                outputLatency = sessionInstance.outputLatency
                latency = inputLatency + outputLatency
                sampleRate = Int(sessionInstance.sampleRate)
                frames = Int(sessionInstance.ioBufferDuration * Double(sampleRate))
                dsp.setup(Double(sampleRate), Int32(frames))
            } catch let error as NSError {
                try XExceptionIfError(error, "couldn't set session active")
            } catch {
                fatalError()
            }
        } catch let e as CAXException {
            NSLog("Error returned from setupAudioSession: %d: %@", Int32(e.mError), e.mOperation)
        } catch _ {
            NSLog("Unknown error returned from setupAudioSession")
        }
    }
    
    private func setupIOUnit() {
        do {
            // Create a new instance of AURemoteIO
            var desc = AudioComponentDescription(
                componentType: OSType(kAudioUnitType_Output),
                componentSubType: OSType(kAudioUnitSubType_RemoteIO),
                componentManufacturer: OSType(kAudioUnitManufacturer_Apple),
                componentFlags: 0,
                componentFlagsMask: 0)
            
            let comp = AudioComponentFindNext(nil, &desc)
            try XExceptionIfError(AudioComponentInstanceNew(comp!, &self._rioUnit), "couldn't create AURemoteIO")
            
            //  Enable input and output on AURemoteIO
            //  Input is enabled on the input scope of the input element
            //  Output is enabled on the output scope of the output element
            var two: UInt32 = 2 // Stereo
            try XExceptionIfError(AudioUnitSetProperty(self._rioUnit!, AudioUnitPropertyID(kAudioOutputUnitProperty_EnableIO), AudioUnitScope(kAudioUnitScope_Input), 1, &two, SizeOf32(two)), "could not enable input on AURemoteIO")
            try XExceptionIfError(AudioUnitSetProperty(self._rioUnit!, AudioUnitPropertyID(kAudioOutputUnitProperty_EnableIO), AudioUnitScope(kAudioUnitScope_Output), 0, &two, SizeOf32(two)), "could not enable output on AURemoteIO")
            
            var ioFormat = CAStreamBasicDescription(sampleRate: Double(sampleRate), numChannels: 2, pcmf: .float32, isInterleaved: false)
            
            try XExceptionIfError(AudioUnitSetProperty(self._rioUnit!, AudioUnitPropertyID(kAudioUnitProperty_StreamFormat), AudioUnitScope(kAudioUnitScope_Output), 1, &ioFormat, SizeOf32(ioFormat)), "couldn't set the input client format on AURemoteIO")
            try XExceptionIfError(AudioUnitSetProperty(self._rioUnit!, AudioUnitPropertyID(kAudioUnitProperty_StreamFormat), AudioUnitScope(kAudioUnitScope_Input), 0, &ioFormat, SizeOf32(ioFormat)), "couldn't set the output client format on AURemoteIO")
            
            // Set the MaximumFramesPerSlice property. This property is used to describe to an audio unit the maximum number
            // of samples it will be asked to produce on any single given call to AudioUnitRender
            var maxFramesPerSlice: UInt32 = 4096
            try XExceptionIfError(AudioUnitSetProperty(self._rioUnit!, AudioUnitPropertyID(kAudioUnitProperty_MaximumFramesPerSlice), AudioUnitScope(kAudioUnitScope_Global), 0, &maxFramesPerSlice, SizeOf32(UInt32.self)), "couldn't set max frames per slice on AURemoteIO")
            
            // Get the property value back from AURemoteIO. We are going to use this value to allocate buffers accordingly
            var propSize = SizeOf32(UInt32.self)
            try XExceptionIfError(AudioUnitGetProperty(self._rioUnit!, kAudioUnitProperty_MaximumFramesPerSlice, kAudioUnitScope_Global, 0, &maxFramesPerSlice, &propSize), "couldn't get max frames per slice on AURemoteIO")
            
            // Set the render callback on AURemoteIO
            var renderCallback = AURenderCallbackStruct(
                inputProc: AudioController_RenderCallback,
                inputProcRefCon: Unmanaged.passUnretained(self).toOpaque()
            )
            try XExceptionIfError(AudioUnitSetProperty(self._rioUnit!, kAudioUnitProperty_SetRenderCallback, kAudioUnitScope_Input, 0, &renderCallback, MemoryLayout<AURenderCallbackStruct>.size.ui), "couldn't set render callback on AURemoteIO")
            
            // Initialize the AURemoteIO instance
            try XExceptionIfError(AudioUnitInitialize(self._rioUnit!), "couldn't initialize AURemoteIO instance")
        } catch let e as CAXException {
            NSLog("Error returned from setupIOUnit: %d: %@", e.mError, e.mOperation)
        } catch _ {
            NSLog("Unknown error returned from setupIOUnit")
        }
    }

    @discardableResult
    func startIOUnit() -> Double {
        let err = AudioOutputUnitStart(_rioUnit!)
        if err != 0 {NSLog("couldn't start AURemoteIO: %d", Int32(err))}
        return latency
    }
    
    @discardableResult
    func stopIOUnit() -> OSStatus {
        let err = AudioOutputUnitStop(_rioUnit!)
        if err != 0 {NSLog("couldn't stop AURemoteIO: %d", Int32(err))}
        return err
    }
    
    var sessionSampleRate: Double {
        return sessionInstance.sampleRate
    }
    
    public func setup() {
        if (isSetup){ // allowed to call only once from extern - call reset after that
            return
        }
        isSetup = true
        self.setupAudioSession()
        self.setupIOUnit()
        self.updateView()
    }
    
    public func reset(){
        if audioChainIsBeingReconstructed {
            return
        }
        audioChainIsBeingReconstructed = true
        if(_rioUnit != nil){
            stopIOUnit()
        }
        _rioUnit = nil
        isSetup = false
        self.setup()
        self.startIOUnit()
        audioChainIsBeingReconstructed = false
        self.updateView()
    }
}
