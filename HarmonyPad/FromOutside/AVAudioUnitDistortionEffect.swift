import Foundation
import AVFoundation

class AVAudioUnitDistortionEffect: AVAudioUnitEffect {
    
    override init() {
        var description                   = AudioComponentDescription()
        description.componentType         = kAudioUnitType_Effect
        description.componentSubType      = kAudioUnitSubType_Distortion
        description.componentManufacturer = kAudioUnitManufacturer_Apple
        description.componentFlags        = 0
        description.componentFlagsMask    = 0
        super.init(audioComponentDescription: description)
    }
    
    func setFinalMix(_ finalMix: Float) {
        
        let status = AudioUnitSetParameter(
            self.audioUnit,
            AudioUnitPropertyID(kDistortionParam_FinalMix),
            AudioUnitScope(kAudioUnitScope_Global),
            0,
            finalMix,
            0)
        
        if status != noErr {
            print("error \(status)")
        }
    }
    
    func setDelay(_ value: Float) {
        setAudioUnitParameterValue(audioUnit, parameterType: kDistortionParam_Delay, value: 0.0)
    }
    // etc for the rest
    
    
    func getAudioUnitParameterValue(_ audioUnit: AudioUnit, parameterType: AudioUnitParameterID ) -> Float {
        
        var value = AudioUnitParameterValue(0.0)
        let status = AudioUnitGetParameter(audioUnit,
                                           parameterType,
                                           kAudioUnitScope_Global,
                                           0,
                                           &value)
        if status == noErr {
            return value
        } else {
            return 0.0
        }
    }
    
    func setAudioUnitParameterValue(_ audioUnit: AudioUnit, parameterType: AudioUnitParameterID, value: Float) {
        
        let status = AudioUnitSetParameter(audioUnit,
                                           parameterType,
                                           kAudioUnitScope_Global,
                                           0,
                                           value,
                                           0)
        if status != noErr {
            print("error \(status)")
        }
    }
}
