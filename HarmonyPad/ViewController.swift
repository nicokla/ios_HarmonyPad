import UIKit

class ViewController: UIViewController {
    //var config:ScaleConfig
    var myLabel = UILabel()
    var subviews:Array<UIView>=[]
    let vertClair:UIColor = UIColor(red:207.0/255.0,green:1.0,blue:162.0/255.0,alpha:1.0)
    let gris:UIColor = UIColor(red:200.0/255.0,green:200.0/255.0,blue:200.0/255.0,alpha:1.0)
    let vert:UIColor = UIColor(red:159.0/255.0,green:215.0/255.0,blue:125.0/255.0,alpha:1.0)
    var dico=Dictionary<Int,UIButton>()
    var dicoColors = Dictionary<Int,UIColor>()
    var largeur1:Int=7

    // Screen width.
    public var screenWidth: CGFloat { // CGFloat
        return (UIScreen.main.bounds.width)
    }
    
    // Screen height.
    public var screenHeight: CGFloat {
        return (UIScreen.main.bounds.height)
    }
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    ///////////////////////////
    
    func makeButtonWithText(text:String,a:Int,b:Int,largeur:Int,hauteur:Int,coul:UIColor,
                            debutY:CGFloat,finY:CGFloat,origineTag:Int) -> UIButton {
        let myButton = UIButton(type: UIButtonType.system)
        let aF=CGFloat(a)
        let bF=CGFloat(b)
        let largeurF=CGFloat(largeur)
        let hauteurF=CGFloat(hauteur)
        //Set a frame for the button. Ignored in AutoLayout/ Stack Views
        myButton.frame = CGRect(x:aF*screenWidth/largeurF+2,
                                y:bF*screenHeight/hauteurF+2,
                                width:screenWidth/largeurF-4,
                                height:screenHeight/hauteurF-4)
        myButton.layer.cornerRadius = 5  // get some fancy pantsy rounding
        
        //Set background color
        myButton.backgroundColor = coul

        //State dependent properties title and title color
        myButton.setTitle(text, for: [])
        myButton.setTitleColor(UIColor.black, for: [])
        //myButton.setTitle("Touched!!", for: .highlighted)
        //myButton.setTitleColor(UIColor.orange, for: .highlighted)
        myButton.tag=b*largeur+a+origineTag
        if(b<=2){
            dico[myButton.tag]=myButton
            dicoColors[myButton.tag]=coul
        }
        else{
            myButton.tag = -1 - myButton.tag
            dico[myButton.tag]=myButton
            dicoColors[myButton.tag]=coul
        }
        myButton.addTarget(self,action: #selector(outButton),for: .touchUpInside)
        myButton.addTarget(self,action: #selector(helloButton),for: .touchDown)
        //myButton.addTarget(self,action: #selector(helloButton),for: .touchDragEnter)
        //myButton.addTarget(self,action: #selector(outButton),for: .touchDragExit)

        return myButton
    }
    
    //MARK: - Actions and Selectors
    @IBAction func helloButton(sender:UIButton){
        let nbChordsLine=globalVar.scaleConfigList[globalVar.scale_n].nbChordsLine
        var ligne=0
        var colonne=0
        var tag:Int = 0
        if(sender.tag < 0){
            tag = -((Int)(sender.tag)+1)
            colonne=tag % nbChordsLine
            ligne=tag / nbChordsLine
        }else{
            tag = (Int)(sender.tag)
            colonne=tag % largeur1
            ligne=tag / largeur1
        }
        
        //appDelegate.mySampler.sampler.startNote(60, withVelocity: 120, onChannel: 0)
        //print("coucou")
        if (colonne==largeur1-2 && ligne==2) {
            globalVar.origine-=12
            populate()}
        else if (colonne==largeur1-1 && ligne==2){
            globalVar.origine+=12
            populate()}
        else if (colonne==nbChordsLine-3 && ligne==5){
            globalVar.origine-=1
            globalVar.origineChords = (globalVar.origine-4)%12 + 40
            populate()}
        else if (colonne==nbChordsLine-2 && ligne==5){
            globalVar.origine+=1
            globalVar.origineChords = (globalVar.origine-4)%12 + 40
            populate()
        }
        else if(ligne == 5 && colonne == nbChordsLine-1){
            /*let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "Settings") as! UIViewController
            let navi = UINavigationController(rootViewController: vc)
            navigationController?.pushViewController(navi, animated: true)*/
            performSegue(withIdentifier: "segueToSettings",
                         sender: sender)
        }else {
            if(dicoColors[sender.tag] == UIColor.white){
                sender.backgroundColor = gris
            }
            else if(dicoColors[sender.tag] == vertClair){
                sender.backgroundColor = vert
            }
            
            if (ligne>=3){
                let t=tag-3*nbChordsLine
                let n0:UInt32=UInt32(globalVar.origineChords +
                    globalVar.scaleConfigList[globalVar.scale_n].accBase[t])
                globalVar.audioUnit.playChord(n:n0,
                                              v:globalVar.scaleConfigList[globalVar.scale_n].accVec[t].v,
                                              vol: globalVar.volume)
            }
            else{
                var n0:UInt32
                if(globalVar.afficherTout){
                    n0 = UInt32(globalVar.origine+12*ligne+colonne)
                }else{
                    n0=UInt32(globalVar.origine+12*ligne +
                        globalVar.scaleConfigList[globalVar.scale_n].gamme[colonne])
                }
                globalVar.audioUnit.playPatch1On(n:n0, vol: globalVar.volume)
            }
        }
    }
    
    @IBAction func outButton(sender:UIButton){
        var ligne=0
        var colonne=0
        var tag:Int = 0
        let nbChordsLine=globalVar.scaleConfigList[globalVar.scale_n].nbChordsLine
        if(sender.tag < 0){
            tag = -((Int)(sender.tag)+1)
            colonne=tag % nbChordsLine
            ligne=tag / nbChordsLine
        }else{
            tag = (Int)(sender.tag)
            colonne=tag % largeur1
            ligne=tag / largeur1
        }
        
        sender.backgroundColor = dicoColors[sender.tag]
        
        if (colonne==largeur1-2 && ligne==2) {
        }else if (colonne==largeur1-1 && ligne==2){
        }else if (colonne==nbChordsLine-3 && ligne==5){
        }else if (colonne==nbChordsLine-2 && ligne==5){
        }else if(ligne == 5 && colonne == nbChordsLine-1){
        }else {
            if (ligne>=3){
                let t=tag-3*nbChordsLine
                let n0:UInt32=UInt32(globalVar.origineChords
                    + globalVar.scaleConfigList[globalVar.scale_n].accBase[t])
                globalVar.audioUnit.stopChord(n:n0, v:globalVar.scaleConfigList[globalVar.scale_n].accVec[t].v)
            }else{
                var n0:UInt32
                if(globalVar.afficherTout){
                    n0 = UInt32(globalVar.origine+12*ligne+colonne)
                }else{
                    n0=UInt32(globalVar.origine+12*ligne +
                        globalVar.scaleConfigList[globalVar.scale_n].gamme[colonne])
                }
                globalVar.audioUnit.playPatch1Off(n:n0)
            }
        }
    }
    
    func clear(){
        for subview in subviews {
            subview.removeFromSuperview()
        }
        subviews=[]
    }
    
    func populate(){
        clear()
        var v:UIView
        var t:String=""
        var x:Int
        var coul:UIColor=UIColor.white
        let config=globalVar.scaleConfigList[globalVar.scale_n]
        
        
        //////////////////////////////////////////
        //  buttons du haut
        ///////////////////////////////////
        
        if(globalVar.afficherTout){
            largeur1=12
        }else{
            largeur1=config.gamme.count
        }
        
        for a1 in 0...(largeur1-1) {
            for b1 in 0...(3-1) {
                if (a1==largeur1-2 && b1==2) {
                    t="-12"
                    coul=UIColor.green
                } else if (a1==largeur1-1 && b1==2){
                    t="+12"
                    coul=UIColor.green
                } else{ // !!!
                    if (!globalVar.afficherTout){
                        x=globalVar.origine+12*b1
                        + globalVar.scaleConfigList[globalVar.scale_n].gamme[a1]
                        if(x>=0){
                            t=globalVar.notes[x]
                        }else{
                            t=""
                        }
                        coul=UIColor.white
                    }else{
                        x=globalVar.origine+12*b1+a1
                        if(x>=0){
                            t=globalVar.notes[x]
                        }else{
                            t=""
                        }
                        coul=UIColor.white //!!!!!
                    }
                }
                
                v=makeButtonWithText(
                    text:t,//String(a1)+" "+String(b1),
                    a: a1,
                    b: b1,
                    largeur: largeur1,
                    hauteur: 6,
                    coul: coul,
                    debutY:0,
                    finY:0,
                    origineTag:0
                )
                subviews.append(v)
                view.addSubview(v)
            }
        }
        
        if (globalVar.afficherTout){ // vert clair sur gamme
            var b:UIButton
            for a1 in 0...(config.gamme.count-1) {
                for b1 in 0...(3-1) {
                    let n = 12*b1 + globalVar.scaleConfigList[globalVar.scale_n].gamme[a1]
                    b=dico[n]!
                    b.backgroundColor=vertClair
                    dicoColors[n]=vertClair
                }
            }
            b=dico[12*2 + 11]!
            dicoColors[12*2 + 11]=UIColor.green
            b.backgroundColor=UIColor.green
            
            b=dico[12*2 + 10]!
            dicoColors[12*2 + 10]=UIColor.green
            b.backgroundColor=UIColor.green

        }

        
        //////////////////////////////////////////
        //  buttons du bas
        ///////////////////////////////////
        var flag:Bool=true
        let scale=globalVar.scaleConfigList[globalVar.scale_n]
        for a1 in 0...(scale.nbChordsLine-1) {
            for b1 in 3...(6-1) {
                flag=true
                if (a1==scale.nbChordsLine-3 && b1==5){
                    t="-1"
                    coul=UIColor.green
                } else if (a1==scale.nbChordsLine-2 && b1==5){
                    t="+1"
                    coul=UIColor.green
                } else if (a1==scale.nbChordsLine-1 && b1==5){
                    t="Settings"
                    coul=UIColor.yellow
                } else if scale.accBase.count > scale.nbChordsLine*(b1-3)+a1 {
                    x = globalVar.origine + scale.accBase[scale.nbChordsLine*(b1-3)+a1]
                    t = globalVar.notesModulo12[x%12]
                        + scale.accVec[scale.nbChordsLine*(b1-3)+a1].name
                    coul=UIColor.white
                } else{
                    flag=false
                }
                
                if(flag){
                    v=makeButtonWithText(
                        text:t,//String(a1)+" "+String(b1),
                        a: a1,
                        b: b1,
                        largeur: scale.nbChordsLine,
                        hauteur: 6,
                        coul: coul,
                        debutY:0,
                        finY:0,
                        origineTag:0)
                    subviews.append(v)
                    view.addSubview(v)
                }
            }
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()


        //background color for the view
        view.backgroundColor = UIColor(white: 0.6, alpha: 1.0)

        //print(screenWidth)
        //print(screenHeight)
        
        populate()
    }
    
    /*@IBOutlet weak var boubou2: UIButton!
    
    @IBAction func fonctionBoubou2(_ sender: Any) {
        performSegue(withIdentifier: "Show1",
                     sender: self)
    }*/
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func rewinding(segue:UIStoryboardSegue){
        populate()
    }
    
}






