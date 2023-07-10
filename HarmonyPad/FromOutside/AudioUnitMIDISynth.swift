import Foundation
import AudioToolbox
import CoreAudio

class AudioUnitMIDISynth: NSObject {
    
    var processingGraph: AUGraph?
    var midisynthNode   = AUNode()
    var ioNode          = AUNode()
    var midisynthUnit: AudioUnit?
    var ioUnit: AudioUnit?
    var musicSequence: MusicSequence!
    var musicPlayer: MusicPlayer!
    public var patch1 = UInt32(5)
    public var patch2 = UInt32(0)
    /// random pitch
    /// - seealso:  generateRandomPitch()
    var pitch           = UInt32(60)
    
    init(instru1_n:Int,instru2_n:Int) {
        super.init()
        
        patch1=UInt32(instru1_n)
        patch2=UInt32(instru2_n)
        
        augraphSetup()
        loadMIDISynthSoundFont()
        initializeGraph()
        self.musicSequence = createMusicSequence()
        musicPlayer = createPlayer(musicSequence)
        loadPatches()
        startGraph()
    }
    
    func augraphSetup() {
        var status = OSStatus(noErr)
        
        status = NewAUGraph(&processingGraph)
        AudioUtils.CheckError(status)
        
        createIONode()
        
        createSynthNode()
        
        status = AUGraphOpen(self.processingGraph!)
        AudioUtils.CheckError(status)
        
        status = AUGraphNodeInfo(self.processingGraph!, self.midisynthNode, nil, &midisynthUnit)
        AudioUtils.CheckError(status)
        
        status = AUGraphNodeInfo(self.processingGraph!, self.ioNode, nil, &ioUnit)
        AudioUtils.CheckError(status)
        
        
        let synthOutputElement: AudioUnitElement = 0
        let ioUnitInputElement: AudioUnitElement = 0
        
        status = AUGraphConnectNodeInput(self.processingGraph!,
                                         self.midisynthNode, synthOutputElement, // srcnode, SourceOutputNumber
            self.ioNode, ioUnitInputElement) // destnode, DestInputNumber
        
        AudioUtils.CheckError(status)
    }
    
    /// Create the Output Node and add it to the `AUGraph`.
    func createIONode() {
        var cd = AudioComponentDescription(
            componentType: OSType(kAudioUnitType_Output),
            componentSubType: OSType(kAudioUnitSubType_RemoteIO),
            componentManufacturer: OSType(kAudioUnitManufacturer_Apple),
            componentFlags: 0, componentFlagsMask: 0)
        let status = AUGraphAddNode(self.processingGraph!, &cd, &ioNode)
        AudioUtils.CheckError(status)
    }
    
    /// Create the Synth Node and add it to the `AUGraph`.
    func createSynthNode() {
        var cd = AudioComponentDescription(
            componentType: OSType(kAudioUnitType_MusicDevice),
            componentSubType: OSType(kAudioUnitSubType_MIDISynth),
            componentManufacturer: OSType(kAudioUnitManufacturer_Apple),
            componentFlags: 0, componentFlagsMask: 0)
        let status = AUGraphAddNode(self.processingGraph!, &cd, &midisynthNode)
        AudioUtils.CheckError(status)
    }
    
    
    let soundFontFileName =  "gs_instruments"//"gs_instruments",
    let soundFontFileExt = "dls"//"dls")

    func loadMIDISynthSoundFont() {
        
        if var bankURL = Bundle.main.url(forResource: soundFontFileName, withExtension: soundFontFileExt) {
            
            let status = AudioUnitSetProperty(
                self.midisynthUnit!,
                AudioUnitPropertyID(kMusicDeviceProperty_SoundBankURL),
                AudioUnitScope(kAudioUnitScope_Global),
                0,
                &bankURL,
                UInt32(MemoryLayout<URL>.size))
            
            AudioUtils.CheckError(status)
        } else {
            print("Could not load sound font")
        }
        print("loaded sound font")
    }
    
    
    func loadPatches() {
        
        if !isGraphInitialized() {
            fatalError("initialize graph first")
        }
        
        let channel = UInt32(0)
        var enabled = UInt32(1)
        
        var status = AudioUnitSetProperty(
            self.midisynthUnit!,
            AudioUnitPropertyID(kAUMIDISynthProperty_EnablePreload),
            AudioUnitScope(kAudioUnitScope_Global),
            0,
            &enabled,
            UInt32(MemoryLayout<UInt32>.size))
        AudioUtils.CheckError(status)
        
        let pcCommand = UInt32(0xC0 | channel)
        status = MusicDeviceMIDIEvent(self.midisynthUnit!, pcCommand, patch1, 0, 0)
        AudioUtils.CheckError(status)
        status = MusicDeviceMIDIEvent(self.midisynthUnit!, pcCommand, patch2, 0, 0)
        AudioUtils.CheckError(status)
        
        enabled = UInt32(0)
        status = AudioUnitSetProperty(
            self.midisynthUnit!,
            AudioUnitPropertyID(kAUMIDISynthProperty_EnablePreload),
            AudioUnitScope(kAudioUnitScope_Global),
            0,
            &enabled,
            UInt32(MemoryLayout<UInt32>.size))
        AudioUtils.CheckError(status)
    }
    
    func isGraphInitialized() -> Bool {
        var outIsInitialized = DarwinBoolean(false)
        let status = AUGraphIsInitialized(self.processingGraph!, &outIsInitialized)
        AudioUtils.CheckError(status)
        return outIsInitialized.boolValue
    }
    
    func initializeGraph() {
        let status = AUGraphInitialize(self.processingGraph!)
        AudioUtils.CheckError(status)
    }
    
    func startGraph() {
        let status = AUGraphStart(self.processingGraph!)
        AudioUtils.CheckError(status)
    }
    
    func isGraphRunning() -> Bool {
        var isRunning = DarwinBoolean(false)
        let status = AUGraphIsRunning(self.processingGraph!, &isRunning)
        AudioUtils.CheckError(status)
        return isRunning.boolValue
    }
    
    func generateRandomPitch() {
        pitch = arc4random_uniform(64) + 36 // 36 - 100
    }
    
    func playPatch1On_old() {
        
        let channel = UInt32(0)
        let noteCommand = UInt32(0x90 | channel)
        let pcCommand = UInt32(0xC0 | channel)
        var status = OSStatus(noErr)
        
        generateRandomPitch()
        print(pitch)
        status = MusicDeviceMIDIEvent(self.midisynthUnit!, pcCommand, patch1, 0, 0)
        AudioUtils.CheckError(status)
        status = MusicDeviceMIDIEvent(self.midisynthUnit!, noteCommand, pitch, 64, 0)
        AudioUtils.CheckError(status)
    }
    
    func playPatch1On(n:UInt32 , vol:Int) {
        let channel = UInt32(0)
        let noteCommand = UInt32(0x90 | channel)
        let pcCommand = UInt32(0xC0 | channel)
        var status = OSStatus(noErr)
        
        //generateRandomPitch()
        //pitch=n
        //print(pitch)
        status = MusicDeviceMIDIEvent(self.midisynthUnit!, pcCommand, patch1, 0, 0)
        AudioUtils.CheckError(status)
        status = MusicDeviceMIDIEvent(self.midisynthUnit!, noteCommand, n, UInt32(vol), 0)
        AudioUtils.CheckError(status)
    }
    
    func playPatch1Off(n:UInt32) {
        let channel = UInt32(0)
        let noteCommand = UInt32(0x80 | channel)
        var status = OSStatus(noErr)
        status = MusicDeviceMIDIEvent(self.midisynthUnit!, noteCommand, n, 0, 0)
        AudioUtils.CheckError(status)
        
        //pitch=n
        //print(pitch)
    }

    func playChord(n:UInt32, v:Array<Int>, vol:Int){
        let channel = UInt32(0)
        let noteCommand = UInt32(0x90 | channel)
        let pcCommand = UInt32(0xC0 | channel)
        var status = OSStatus(noErr)
        
        //generateRandomPitch()
        //pitch=n
        //print(pitch)
        status = MusicDeviceMIDIEvent(self.midisynthUnit!, pcCommand, patch2, 0, 0)
        AudioUtils.CheckError(status)
        if( !globalVar.arpeggio ){
            for a in v{
                status = MusicDeviceMIDIEvent(self.midisynthUnit!, noteCommand, n+UInt32(a), UInt32(vol), 0)
            }
        } else {
            for a in v{
                status = MusicDeviceMIDIEvent(self.midisynthUnit!, noteCommand, n+UInt32(a), UInt32(vol), 0)
                usleep(50000)
            }
        }
        AudioUtils.CheckError(status)
    }
    
    func stopChord(n:UInt32, v:Array<Int>) {
        let channel = UInt32(0)
        let noteCommand = UInt32(0x80 | channel)
        var status = OSStatus(noErr)
        for a in v{
            status = MusicDeviceMIDIEvent(self.midisynthUnit!, noteCommand, n+UInt32(a), 0, 0)
        }
        AudioUtils.CheckError(status)
    }

    func playPatch2On() {
        
        let channel = UInt32(0)
        let noteCommand = UInt32(0x90 | channel)
        let pcCommand = UInt32(0xC0 | channel)
        var status = OSStatus(noErr)
        
        generateRandomPitch()
        print(pitch)
        status = MusicDeviceMIDIEvent(self.midisynthUnit!, pcCommand, patch2, 0, 0)
        AudioUtils.CheckError(status)
        status = MusicDeviceMIDIEvent(self.midisynthUnit!, noteCommand, pitch, 64, 0)
        AudioUtils.CheckError(status)
    }
    
    func playPatch2Off() {
        let channel = UInt32(0)
        let noteCommand = UInt32(0x80 | channel)
        var status = OSStatus(noErr)
        status = MusicDeviceMIDIEvent(self.midisynthUnit!, noteCommand, pitch, 0, 0)
        AudioUtils.CheckError(status)
    }
    
    
    func createMusicSequence() -> MusicSequence {
        
        var musicSequence: MusicSequence?
        var status = NewMusicSequence(&musicSequence)
        if status != noErr {
            print("\(#line) bad status \(status) creating sequence")
        }
        
        setInstru( musicSequence:&musicSequence, n:46, channel0:0)
        setInstru( musicSequence:&musicSequence, n:0, channel0:1)
        
        // associate the AUGraph with the sequence.
        status = MusicSequenceSetAUGraph(musicSequence!, self.processingGraph)
        
        // Let's see it
        CAShow(UnsafeMutablePointer<MusicSequence>(musicSequence!))
        
        return musicSequence!
    }
    
    
    func setInstru( musicSequence:inout MusicSequence?, n:Int, channel0:Int){
        var status = NewMusicSequence(&musicSequence)
        if status != noErr {
            print("\(#line) bad status \(status) creating sequence")
        }

        // add a track
        var track: MusicTrack?
        status = MusicSequenceNewTrack(musicSequence!, &track)
        if status != noErr {
            print("error creating track \(status)")
        }
        
        let channel = UInt8(channel0)
        // bank select msb
        var chanmess = MIDIChannelMessage(status: 0xB0 | channel, data1: 0, data2: 0, reserved: 0)
        status = MusicTrackNewMIDIChannelEvent(track!, 0, &chanmess)
        if status != noErr {
            print("creating bank select event \(status)")
        }
        // bank select lsb
        chanmess = MIDIChannelMessage(status: 0xB0 | channel, data1: 32, data2: 0, reserved: 0)
        status = MusicTrackNewMIDIChannelEvent(track!, 0, &chanmess)
        if status != noErr {
            print("creating bank select event \(status)")
        }
        
        // program change. first data byte is the patch, the second data byte is unused for program change messages.
        chanmess = MIDIChannelMessage(status: 0xC0 | channel, data1: UInt8(n), data2: 0, reserved: 0)
        status = MusicTrackNewMIDIChannelEvent(track!, 0, &chanmess)
        if status != noErr {
            print("creating program change event \(status)")
        }
        
        // now make some notes and put them on the track
        /*var beat = MusicTimeStamp(0.0)
        for i: UInt8 in 60...72 {
            var mess = MIDINoteMessage(channel: channel,
                                       note: i,
                                       velocity: 64,
                                       releaseVelocity: 0,
                                       duration: 1.0 )
            status = MusicTrackNewMIDINoteEvent(track!, beat, &mess)
            if status != noErr {
                print("creating new midi note event \(status)")
            }
            beat += 1
        }*/
    }
    
    
    func createPlayer(_ musicSequence: MusicSequence) -> MusicPlayer {
        var musicPlayer: MusicPlayer?
        
        var status = NewMusicPlayer(&musicPlayer)
        if status != OSStatus(noErr) {
            print("bad status \(status) creating player")
            AudioUtils.CheckError(status)
        }
        
        status = MusicPlayerSetSequence(musicPlayer!, musicSequence)
        if status != OSStatus(noErr) {
            print("setting sequence \(status)")
            AudioUtils.CheckError(status)
        }
        status = MusicPlayerPreroll(musicPlayer!)
        if status != OSStatus(noErr) {
            print("prerolling player \(status)")
            AudioUtils.CheckError(status)
        }
        return musicPlayer!
    }
    
    func musicPlayerPlay() {
        var status = noErr
        var playing: DarwinBoolean = false
        status = MusicPlayerIsPlaying(musicPlayer, &playing)
        if playing != false {
            status = MusicPlayerStop(musicPlayer)
            if status != noErr {
                print("Error stopping \(status)")
                AudioUtils.CheckError(status)
                return
            }
        }
        
        status = MusicPlayerSetTime(musicPlayer, 0)
        if status != noErr {
            print("setting time \(status)")
            AudioUtils.CheckError(status)
            return
        }
        
        status = MusicPlayerStart(musicPlayer)
        if status != noErr {
            print("Error starting \(status)")
            AudioUtils.CheckError(status)
            return
        }
    }
    
}
