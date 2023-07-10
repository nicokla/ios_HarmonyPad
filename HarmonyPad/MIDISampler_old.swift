import Foundation
import AVFoundation

class MIDISampler {
    var engine = AVAudioEngine()
    var sampler = AVAudioUnitSampler()
    let melodicBank = UInt8(kAUSampler_DefaultMelodicBankMSB)
    let defaultBankLSB = UInt8(kAUSampler_DefaultBankLSB)
    let instrument = UInt8(4)
    
    init() {
        engine.attach(sampler)
        engine.connect(
            sampler,
            to: engine.outputNode,
            format: nil)
        sampler.sendController(7, withValue: 20, onChannel: 0)
        do {try engine.start()}
        catch {print("error1")}
        
        guard let soundbank = Bundle.main.url(
            forResource: "gs_instruments",
            withExtension: "dls")
        else {print("error2")
              return}
        
        do{try sampler.loadSoundBankInstrument(
            at: soundbank,
            program: instrument,
            bankMSB: melodicBank,
            bankLSB: defaultBankLSB)}
        catch {print("error3")}
        
        sampler.sendProgramChange(
            instrument,
            bankMSB: melodicBank,
            bankLSB: defaultBankLSB,
            onChannel: 0)
        
        sampler.startNote(
            65,
            withVelocity: 99,
            onChannel: 0)
    }
}

