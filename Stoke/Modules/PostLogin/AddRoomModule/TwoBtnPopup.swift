//
//  TwoBtnPopup.swift
//  Stoke
//
//  Created by Admin on 27/04/21.
//

import UIKit

class TwoBtnPopup: BaseVC {
    
    
    @IBOutlet weak var btn1:UIButton!
    @IBOutlet weak var btn2:UIButton!
    
    weak var delagate:ThreeBtnPopupDelegate?
    var btn1Title:String = ""
    var btn2Title:String = ""
    var section = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        [btn2,btn1].forEach {
            $0?.titleLabel?.font = AppFonts.Semibold.withSize(14)
            $0?.setTitleColor(UIColor.black, for: .normal)
        }
        btn1.setTitle(btn1Title, for: .normal)
        btn2.setTitle(btn2Title, for: .normal)
    }
    
    @IBAction func btn1Tapped(_ sender:UIButton){
        dismiss(animated: false) { [weak self] in
            self?.delagate?.getUserChoice(0,section: self?.section ?? 0)
        }
    }
    @IBAction func btn2Tapped(_ sender:UIButton){
        dismiss(animated: false) { [weak self] in
            self?.delagate?.getUserChoice(1,section: self?.section ?? 0)
        }
    }
    
}
