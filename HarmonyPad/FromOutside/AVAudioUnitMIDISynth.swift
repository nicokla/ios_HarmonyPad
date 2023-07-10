import Foundation
import AVFoundation

class AVAudioUnitMIDISynth: AVAudioUnitMIDIInstrument {
    
    override init() {
        var description = AudioComponentDescription()
        description.componentType         = kAudioUnitType_MusicDevice
        description.componentSubType      = kAudioUnitSubType_MIDISynth
        description.componentManufacturer = kAudioUnitManufacturer_Apple
        description.componentFlags        = 0
        description.componentFlagsMask    = 0
        
        super.init(audioComponentDescription: description)

    }
    
    
    let soundFontFileName = "gs_instruments"
    let soundFontFileExt = "dls"
    
    func loadMIDISynthSoundFont() {
        guard let bankURL = Bundle.main.url(forResource: soundFontFileName, withExtension: soundFontFileExt)   else {
            fatalError("Get the default sound font URL correct!")
        }
        
        loadMIDISynthSoundFont(bankURL)
    }
    
    func loadMIDISynthSoundFont(_ bankURL: URL) {
        var bankURL = bankURL
        
        let status = AudioUnitSetProperty(
            self.audioUnit,
            AudioUnitPropertyID(kMusicDeviceProperty_SoundBankURL),
            AudioUnitScope(kAudioUnitScope_Global),
            0,
            &bankURL,
            UInt32(MemoryLayout<URL>.size))
        
        if status != OSStatus(noErr) {
            print("error \(status)")
        }
        
        print("loaded sound font")
    }
    
    func loadPatches(_ patches: [UInt32]) throws {
        
        if let e = engine {
            if !e.isRunning {
                print("audio engine needs to be running")
                throw AVAudioUnitMIDISynthError.engineNotStarted
            }
        }
        
        let channel = UInt32(0)
        var enabled = UInt32(1)
        
        var status = AudioUnitSetProperty(
            self.audioUnit,
            AudioUnitPropertyID(kAUMIDISynthProperty_EnablePreload),
            AudioUnitScope(kAudioUnitScope_Global),
            0,
            &enabled,
            UInt32(MemoryLayout<UInt32>.size))
        if status != noErr {
            print("error \(status)")
        }
        
        let pcCommand = UInt32(0xC0 | channel)
        for patch in patches {
            print("preloading patch \(patch)")
            status = MusicDeviceMIDIEvent(self.audioUnit, pcCommand, patch, 0, 0)
            if status != noErr {
                print("error \(status)")
                AudioUtils.CheckError(status)
            }
        }
        
        enabled = UInt32(0)
        status = AudioUnitSetProperty(
            self.audioUnit,
            AudioUnitPropertyID(kAUMIDISynthProperty_EnablePreload),
            AudioUnitScope(kAudioUnitScope_Global),
            0,
            &enabled,
            UInt32(MemoryLayout<UInt32>.size))
        if status != noErr {
            print("error \(status)")
        }
    }
}


enum AVAudioUnitMIDISynthError: Error {
    /// The AVAudioEngine needs to be started and it's not.
    case engineNotStarted
    /// The specified sound font is no good.
    case badSoundFont
}
