import UIKit

class Settings: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    var myLabel = UILabel()
    @IBOutlet  var instru1: UIPickerView!
    @IBOutlet  var instru2: UIPickerView!
    @IBOutlet  var scale: UIPickerView!
    
    @IBOutlet var volume: UISlider!
    
    @IBOutlet weak var allNotes: UISwitch!
    @IBOutlet weak var arpeggio: UISwitch!
    
    @IBAction func arpeggioIsChanged(_ sender: Any) {
        globalVar.arpeggio=Bool((sender as AnyObject).isOn)
    }
    
    @IBAction func allNotesIsChanged(_ sender: Any) {
        globalVar.afficherTout=Bool((sender as AnyObject).isOn)
    }
    
    @IBAction func volumeChanged(_ sender: UISlider) {
        globalVar.volume=Int(sender.value)
    }
    
    public var screenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }
    
    // Screen height.
    public var screenHeight: CGFloat {
        return UIScreen.main.bounds.height
    }
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
   
    
    //MARK: Properties
    override func viewDidLoad() {
        super.viewDidLoad()
        
        instru1.dataSource = self
        instru1.delegate = self
        instru2.dataSource = self
        instru2.delegate = self
        scale.dataSource = self
        scale.delegate = self
        
        instru1.selectRow(globalVar.instru1_n, inComponent:0, animated:true)
        instru2.selectRow(globalVar.instru2_n, inComponent:0, animated:true)
        scale.selectRow(globalVar.scale_n, inComponent:0, animated:true)
        volume.setValue(Float(globalVar.volume), animated: true)
        arpeggio.setOn(globalVar.arpeggio, animated: true)
        allNotes.setOn(globalVar.afficherTout, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if pickerView == instru1 {
            return globalVar.instruments.count
        } else if pickerView == instru2{
            return globalVar.instruments.count
        }else if pickerView == scale{
            return globalVar.scaleConfigList.count
        }
        
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == instru1 {
            return globalVar.instruments[row]
        } else if pickerView == instru2{
            return globalVar.instruments[row]
        } else if pickerView == scale{
            return globalVar.scaleConfigList[row].name
        }
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == instru1 {
            globalVar.instru1_n=row
            globalVar.audioUnit.patch1=UInt32(row)
            globalVar.audioUnit =
                AudioUnitMIDISynth(instru1_n: globalVar.instru1_n,
                                   instru2_n: globalVar.instru2_n)
            print("\(globalVar.audioUnit.patch1)")
            self.view.endEditing(false)
        } else if pickerView == instru2{
            globalVar.instru2_n=row
            globalVar.audioUnit =
                AudioUnitMIDISynth(instru1_n: globalVar.instru1_n,
                                   instru2_n: globalVar.instru2_n)
            print("\(globalVar.audioUnit.patch2)")
            self.view.endEditing(false)
        } else if pickerView == scale{
            globalVar.scale_n=row
            //globalVar.vCurrent=globalVar.scaleConfigList[row].gamme
            self.view.endEditing(false)
        }
    }

    
}

