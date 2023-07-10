


class ScaleConfig{
    var accBase:[Int]=[]
    var accVec:[Chord]=[]
    var gamme:[Int]=[]
    var name:String
    var nbChordsLine:Int
    init(accBase1:[Int],accVec1:[Chord],gamme1:[Int],name1:String){
        accBase=accBase1
        accVec=accVec1
        gamme=gamme1
        name=name1
        nbChordsLine=gamme.count
    }
}

class Chord{
    var v:[Int]=[]
    var name:String=""
    var id:Int=0
    
    func vecToInt(a:[Int])->Int{
        var a2=a
        for i in 0...a.count-1{
            a2[i]=a[i]-a[0]
        }
        var temp:Int=1
        var temp2:Int=0
        var res:Int=0
        for i in 0...11{
            if temp2 >= a2.count {
                return res
            } else if(a2[temp2]==i){
                res += temp
                temp2 += 1
            }
            temp *= 2
        }
        return res
    }
    
    init(v1:[Int],name1:String){
        v=v1
        name=name1
        id=vecToInt(a: v1)
    }
    
    init(v1:[Int], nameOfChords:Dictionary<Int,String>){
        v=v1
        id=vecToInt(a: v1)
        if nameOfChords[id] == nil{
            name = "?"
        } else {
            name = nameOfChords[id]!
        }

    }
}

class GlobalVar {
    
    let instruments=["Acoustic Grand Piano", "Bright Acoustic Piano", "Electric Grand Piano",
                     "Honky-tonk Piano", "Electric Piano 1", "Electric Piano 2", "Harpsichord", "Clavi", "Celesta", "Glockenspiel",
                     "Music Box", "Vibraphone", "Marimba", "Xylophone", "Tubular Bells", "Dulcimer", "Drawbar Organ", "Percussive Organ", "Rock Organ", "Church Organ",
                     "Reed Organ", "Accordion", "Harmonica", "Tango Accordion", "Acoustic Guitar (nylon)", "Acoustic Guitar (steel)",
                     "Electric Guitar (jazz)", "Electric Guitar (clean)", "Electric Guitar (muted)", "Overdriven Guitar",
                     "Distortion Guitar", "Guitar harmonics", "Acoustic Bass", "Electric Bass (finger)",
                     "Electric Bass (pick)", "Fretless Bass", "Slap Bass 1", "Slap Bass 2", "Synth Bass 1", "Synth Bass 2", "Violin",
                     "Viola", "Cello", "Contrabass", "Tremolo Strings", "Pizzicato Strings", "Orchestral Harp", "Timpani", "String Ensemble 1", "String Ensemble 2",
                     "SynthStrings 1", "SynthStrings 2", "Choir Aahs", "Voice Oohs", "Synth Voice", "Orchestra Hit",
                     "Trumpet", "Trombone", "Tuba", "Muted Trumpet", "French Horn", "Brass Section", "SynthBrass 1", "SynthBrass 2",
                     "Soprano Sax", "Alto Sax", "Tenor Sax", "Baritone Sax", "Oboe", "English Horn", "Bassoon", "Clarinet", "Piccolo", "Flute", "Recorder", "Pan Flute",
                     "Blown Bottle", "Shakuhachi", "Whistle", "Ocarina", "Lead 1 (square)", "Lead 2 (sawtooth)",
                     "Lead 3 (calliope)", "Lead 4 (chiff)", "Lead 5 (charang)", "Lead 6 (voice)", "Lead 7 (fifths)", "Lead 8 (bass + lead)", "Pad 1 (new age)", "Pad 2 (warm)",
                     "Pad 3 (polysynth)", "Pad 4 (choir)", "Pad 5 (bowed)", "Pad 6 (metallic)", "Pad 7 (halo)", "Pad 8 (sweep)",
                     "FX 1 (rain)", "FX 2 (soundtrack)", "FX 3 (crystal)", "FX 4 (atmosphere)", "FX 5 (brightness)", "FX 6 (goblins)", "FX 7 (echoes)", "FX 8 (sci-fi)",
                     "Sitar", "Banjo", "Shamisen", "Koto", "Kalimba", "Bag pipe", "Fiddle", "Shanai", "Tinkle Bell", "Agogo", "Steel Drums", "Woodblock", "Taiko Drum",
                     "Melodic Tom", "Synth Drum", "Reverse Cymbal", "Guitar Fret Noise", "Breath Noise", "Seashore", "Bird Tweet", "Telephone Ring", "Helicopter",
                     "Applause", "Gunshot"]
    
    
    var instru1_n:Int
    var instru2_n:Int
    var scale_n:Int
    var volume:Int
    var arpeggio:Bool
    var audioUnit: AudioUnitMIDISynth!
    var sequence: SynthSequence!
    
    //let vAll:Array<Array<Int>>
    //var vCurrent:Array<Int>=[]
    var origine=48
    var origineChords = 48
    var afficherTout:Bool // true
    
    
    let majeur=Chord(v1: [0,4,7],name1: "")
    let mineur=Chord(v1: [0,3,7],name1: "m")
    let majeur7=Chord(v1: [0,4,7,11],name1: "Δ")
    let mineur7=Chord(v1: [0,3,7,10],name1: "m7")
    let dominant=Chord(v1: [0,4,7,10],name1: "7")
    let dim=Chord(v1: [0,3,6],name1: "dim")
    let dim7=Chord(v1: [0,3,6,10],name1: "m7b5")

    var nameOfChords=Dictionary<Int,String>()
    
    
    func remplirNameOfChords(){
        for a in [majeur,mineur,majeur7,mineur7,dominant,dim,dim7]{
            nameOfChords[a.id]=a.name
        }
        for a in [Chord(v1: [0,5,7],name1: "sus"),
                Chord(v1: [0,1,4],name1: "phr+"),
                Chord(v1: [0,1,3],name1: "phr-"),
                Chord(v1: [0,5,8],name1: "min/V"),
                Chord(v1: [0,5,9],name1: "maj/V"),
                Chord(v1: [0,4,9],name1: "min/III"),
                Chord(v1: [0,3,8],name1: "maj/III"),
                Chord(v1: [0,4,8],name1: "aug"),
                Chord(v1: [0,3,6,9],name1: "dim7")
            ]{
                nameOfChords[a.id]=a.name
        }
    }
    
    let notesModulo12=["C","C#","D","Eb","E","F","F#","G","Ab","A","Bb","B"]    
    
    let notes=["C-1","C#-1","D-1","Eb-1","E-1","F-1","F#-1","G-1","Ab-1","A-1","Bb-1","B-1",
               "C0","C#0","D0","Eb0","E0","F0","F#0","G0","Ab0","A0","Bb0","B0",
               "C1","C#1","D1","Eb1","E1","F1","F#1","G1","Ab1","A1","Bb1","B1",
               "C2","C#2","D2","Eb2","E2","F2","F#2","G2","Ab2","A2","Bb2","B2",
               "C3","C#3","D3","Eb3","E3","F3","F#3","G3","Ab3","A3","Bb3","B3",
               "C4","C#4","D4","Eb4","E4","F4","F#4","G4","Ab4","A4","Bb4","B4",
               "C5","C#5","D5","Eb5","E5","F5","F#5","G5","Ab5","A5","Bb5","B5",
               "C6","C#6","D6","Eb6","E6","F6","F#6","G6","Ab6","A6","Bb6","B6",
               "C7","C#7","D7","Eb7","E7","F7","F#7","G7","Ab7","A7","Bb7","B7",
               "C8","C#8","D8","Eb8","E8","F8","F#8","G8","Ab8","A8","Bb8","B8",
               "C9","C#9","D9","Eb9","E9","F9","F#9","G9"]
    
    let scaleConfigList:[ScaleConfig]
    
    init() {
        instru1_n=0
        instru2_n=0
        scale_n=0
        audioUnit =
            AudioUnitMIDISynth(instru1_n: instru1_n,
                               instru2_n: instru2_n)
        sequence = SynthSequence()
        volume=100
        //vAll=[vMaj,vMin,vMinH,vMinD,vMinP,vMajP]
        arpeggio=false
        afficherTout=true
        
        let scaleConfigMajeur=ScaleConfig(
            accBase1: [0,2,4,5,7,9,11,0,2,4,5,7,9,11,2,2,4,4],
            accVec1: [majeur,mineur,mineur,majeur,majeur,mineur,dim,
                 majeur7,mineur7,mineur7,majeur7,dominant,mineur7,dim7,
                 majeur,dominant,majeur,dominant],
            gamme1: [0,2,4,5,7,9,11],
            name1:"Major")
        let scaleConfigMineur=ScaleConfig(
            accBase1: [0,2,3,5,7,8,10,0,2,3,5,7,8,10,5,5,7,7],
            accVec1: [mineur,dim,majeur,mineur,mineur,majeur,majeur,
                 mineur7,dim7,majeur7,mineur7,mineur7,majeur7,dominant,
                 majeur,dominant,majeur,dominant],
            gamme1: [0,2,3,5,7,8,10],
            name1:"Minor")
        let scaleConfigHarmonic=ScaleConfig(
            accBase1: [0,2,3,5,7,8,11,0,2,3,5,7,8,11,5,5,7,7],
            accVec1: [mineur,dim,majeur,mineur,majeur,majeur,dim,
                   mineur7,dim7,majeur7,mineur7,dominant,majeur7,dim7,
                   majeur,dominant,majeur,dominant],
            gamme1: [0,2,3,5,7,8,11],
            name1:"Harmonic")
        let scaleConfigDorian=ScaleConfig(
            accBase1: [0,2,3,5,7,9,10,0,2,3,5,7,9,10,5,5,7,7],
            accVec1: [mineur,dim,majeur,majeur,mineur,majeur,majeur,
                     mineur7,dim7,majeur7,dominant,mineur7,majeur7,dominant,
                     majeur,dominant,majeur,dominant],
            gamme1: [0,2,3,5,7,9,10],
            name1:"Dorian")
        let scaleConfigPhrygian=ScaleConfig(
            accBase1: [0,1,3,5,7,8,10,0,1,3,5,7,8,10,5,5,7,7],
            accVec1: [mineur,majeur,majeur,mineur,dim,majeur,mineur,
                       mineur7,majeur7,dominant,mineur7,dim7,majeur7,mineur7,
                       majeur,dominant,majeur,dominant],
            gamme1: [0,1,3,5,7,8,10],
            name1:"Phrygian")
        let scaleLocrian=ScaleConfig(accBase1: [],accVec1: [],gamme1: [0,1,3,4,6,8,10],
                                     name1:"Locrian")
        let scaleMixolydian=ScaleConfig(accBase1: [],accVec1: [],gamme1: [0,2,4,5,7,9,10],
                                        name1:"Mixolydian")
        let scaleLydian=ScaleConfig(accBase1: [],accVec1: [],gamme1: [0,2,4,6,7,9,11],
                                    name1:"Lydian")
        
        let scaleDim1=ScaleConfig(accBase1: [],accVec1: [],gamme1: [0,2,3,5,6,8,9,11],
                                      name1:"Diminished 1")
        let scaleDim2=ScaleConfig(accBase1: [],accVec1: [],gamme1: [0,1,3,4,6,7,9,10],
                                  name1:"Diminished 2")
        let scaleAltered=ScaleConfig(accBase1: [],accVec1: [],gamme1: [0,1,3,4,6,8,10],
                                     name1:"Altered")
        let scaleAugmented=ScaleConfig(accBase1: [],accVec1: [],gamme1: [0,3,4,7,8,11],
                                     name1:"Augmented")
        let scaleWholeTone=ScaleConfig(accBase1: [],accVec1: [],gamme1: [0,2,4,6,8,10],
                                       name1:"Whole tone")

        let scaleConfigPentaMaj=ScaleConfig(
            accBase1: [0,2,4,5,7,9,11,0,2,4,5,7,9,11,2,2,4,4],
            accVec1: [majeur,mineur,mineur,majeur,majeur,mineur,dim,
                      majeur7,mineur7,mineur7,majeur7,dominant,mineur7,dim7,
                      majeur,dominant,majeur,dominant],
            gamme1: [0,2,4,7,9],
            name1:"Penta major")
        scaleConfigPentaMaj.nbChordsLine=7
        
        let scaleConfigPentaMin=ScaleConfig(
            accBase1: [0,2,3,5,7,9,10,0,2,3,5,7,9,10,5,5,7,7],
            accVec1: [mineur,dim,majeur,majeur,mineur,majeur,majeur,
                      mineur7,dim7,majeur7,dominant,mineur7,majeur7,dominant,
                      majeur,dominant,majeur,dominant],
            gamme1: [0,3,5,7,10],
            name1:"Penta minor")
        scaleConfigPentaMin.nbChordsLine=7
        
        let scaleConfigBlues=ScaleConfig(
            accBase1: [0,2,3,5,7,9,10,0,2,3,5,7,9,10,5,5,7,7],
            accVec1: [majeur,dim,majeur,majeur,majeur,majeur,majeur,
                      dominant,dim7,majeur7,dominant,dominant,majeur7,dominant,
                      majeur,dominant,majeur,dominant],
            gamme1: [0,3,5,6,7,10],
            name1:"Blues")
        scaleConfigBlues.nbChordsLine=7

        let scaleBebopDominant=ScaleConfig(accBase1: [],accVec1: [],gamme1: [0,2,4,5,7,9,10,11],
                                           name1:"Bebop Dominant")
        let scaleBebopMin=ScaleConfig(accBase1: [],accVec1: [],gamme1: [0,2,3,4,5,7,9,10],
                                      name1:"Bebop minor")
        let scaleBebopMaj=ScaleConfig(accBase1: [],accVec1: [],gamme1: [0,2,4,5,7,8,9,11],
                                      name1:"Bebop major")
        
        let scaleInsen=ScaleConfig(accBase1: [],accVec1: [],gamme1: [0,1,5,7,10],
                                      name1:"Insen")
        let scaleHirojoshi=ScaleConfig(accBase1: [],accVec1: [],gamme1: [0,4,6,7,11],
                                   name1:"Hirojoshi")
        
        let scaleLydianDominant=ScaleConfig(accBase1: [],accVec1: [],gamme1: [0,2,4,6,7,9,10],
                                            name1:"Lydian dominant")

        
        let scaleDorianb5=ScaleConfig(accBase1: [],accVec1: [],gamme1: [0,2,3,5,6,9,10],
                                      name1:"Dorian b5")
        let scaleHungarianMin=ScaleConfig(accBase1: [],accVec1: [],gamme1: [0,2,3,6,7,8,10],
                                      name1:"Hungarian Minor")
        let scaleAlgerian=ScaleConfig(accBase1: [],accVec1: [],gamme1: [0,2,3,6,7,8,11],
                                      name1:"Algerian")
        let scaleAeolianb5=ScaleConfig(accBase1: [],accVec1: [],gamme1: [0,2,3,5,6,8,10],
                                       name1:"Aeolian b5")

        let scaleLocrianbb7=ScaleConfig(accBase1: [],accVec1: [],gamme1: [0,1,3,5,6,8,9],
                                       name1:"Locrian bb7")
        let scaleNapolitanMinor=ScaleConfig(accBase1: [],accVec1: [],gamme1: [0,1,3,5,7,8,11],
                                        name1:"Napolitan minor")
        let scaleNapolitanMajor=ScaleConfig(accBase1: [],accVec1: [],gamme1: [0,1,3,5,7,9,11],
                                            name1:"Napolitan major")
        
        let scaleDoubleHarmonic=ScaleConfig(accBase1: [],accVec1: [],gamme1: [0,1,4,5,7,8,11],
                                            name1:"Double Harmonic")
        let scaleEnigmatic=ScaleConfig(accBase1: [],accVec1: [],gamme1: [0,1,4,6,8,10,11],
                                            name1:"Enigmatic")
        let scalePersian=ScaleConfig(accBase1: [],accVec1: [],gamme1: [0,1,4,5,6,8,11],
                                     name1:"Persian")
        let scaleFlamenco=ScaleConfig(accBase1: [],accVec1: [],gamme1: [0,1,4,5,7,8,11],
                                      name1:"Flamenco")
        let scaleConfigPhrygianMajor=ScaleConfig(
            accBase1: [0,1,3,5,7,8,10,0,1,3,5,7,8,10,5,5,7,7],
            accVec1: [majeur,majeur,majeur,mineur,dim,majeur,mineur,
                      dominant,majeur7,dominant,mineur7,dim7,majeur7,mineur7,
                      majeur,dominant,majeur,dominant],
            gamme1: [0,1,4,5,7,8,10],
            name1:"Phrygian major")

        scaleConfigList=[scaleConfigMajeur,
            scaleConfigMineur,
            scaleConfigHarmonic,
            scaleConfigDorian,
            scaleConfigPhrygian,
            scaleLocrian,
            scaleMixolydian,
            scaleLydian,
            scaleDim1,
            scaleDim2,
            scaleAltered,
            scaleAugmented,
            scaleWholeTone,
            scaleConfigPentaMaj,
            scaleConfigPentaMin,
            scaleConfigBlues,
            scaleBebopDominant,
            scaleBebopMin,
            scaleBebopMaj,
            scaleInsen,
            scaleHirojoshi,
            scaleLydianDominant,
            scaleDorianb5,
            scaleHungarianMin,
            scaleAlgerian,
            scaleAeolianb5,
            scaleLocrianbb7,
            scaleNapolitanMinor,
            scaleNapolitanMajor,
            scaleDoubleHarmonic,
            scaleEnigmatic,
            scalePersian,
            scaleFlamenco,
            scaleConfigPhrygianMajor]
        
        remplirNameOfChords()

        var l:[Chord]
        var l2:[Chord]
        for s in scaleConfigList{
            let size=s.gamme.count
            l=[]
            l2=[]
            if s.accBase == []{
                for a in 0...size-1{
                    let b=(a+2) % size
                    let c=(a+4) % size
                    let d=(a+6) % size
                    var bb=s.gamme[b]-s.gamme[a]
                    var cc=s.gamme[c]-s.gamme[a]
                    var dd=s.gamme[d]-s.gamme[a]
                    if(bb<0){bb+=12}
                    if(cc<0){cc+=12}
                    if(dd<0){dd+=12}
                    l += [Chord(v1: [0,bb,cc],name1: "?")]
                    l2 += [Chord(v1: [0,bb,cc,dd],name1: "?")]
                }
                s.accVec = l + l2
                s.accBase = s.gamme + s.gamme
                
                for a in 0...s.accVec.count-1{
                    if nameOfChords[s.accVec[a].id] == nil{
                        s.accVec[a].name = "?"
                    } else {
                        s.accVec[a].name = nameOfChords[s.accVec[a].id]!
                    }
                }
            }
        }
    }
}

var globalVar = GlobalVar()



