//
//  ThreeBtnPopup.swift
//  Stoke
//
//  Created by Admin on 24/03/21.
//

import UIKit

protocol ThreeBtnPopupDelegate:AnyObject {
    func getUserChoice(_ index:Int,section:Int)
}


class ThreeBtnPopup: BaseVC {
    
    @IBOutlet weak var btn1:UIButton!
    @IBOutlet weak var btn2:UIButton!
    @IBOutlet weak var btn3:UIButton!

    weak var delagate:ThreeBtnPopupDelegate?
    var btn1Title:String = ""
    var btn2Title:String = ""
    var btn3Title:String = ""
    var section = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        [btn2,btn1,btn3].forEach {
            $0?.titleLabel?.font = AppFonts.Semibold.withSize(14)
            $0?.setTitleColor(UIColor.black, for: .normal)
        }
        btn1.setTitle(btn1Title, for: .normal)
        btn2.setTitle(btn2Title, for: .normal)
        btn3.setTitle(btn3Title, for: .normal)
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
    @IBAction func btn3Tapped(_ sender:UIButton){
        dismiss(animated: false) { [weak self] in
            self?.delagate?.getUserChoice(2,section: self?.section ?? 0)
        }
    }

}
