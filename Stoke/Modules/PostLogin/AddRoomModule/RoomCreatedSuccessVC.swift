//
//  RoomCreatedSuccessVC.swift
//  Stoke
//
//  Created by Admin on 22/03/21.
//

import UIKit

class RoomCreatedSuccessVC: BaseVC {

    @IBOutlet weak var okBtn: AppButton!
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var subHeading: UILabel!
    @IBOutlet weak var tickIcon: UIImageView!
    
    
    
    weak var delegate: SignupSucessDelegate?
    var heading:String = ""
    var subheading:String = ""
    var okBtntitle:String = "Ok"
    
    
    var isFromSignup:Bool = false
    var msg:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        okBtn.setTitle(okBtntitle, for: .normal)
    }
    
    override func initalSetup() {
        okBtn.btnType = .themeColor
    }
    
    override func setupFounts() {
        headingLabel.font = AppFonts.Medium.withSize(18)
        subHeading.font = AppFonts.Regular.withSize(16)
        subHeading.textColor = AppColors.labelColor
        headingLabel.text = heading
        subHeading.text = subheading
        
    }
    
    @IBAction func okTapped(_ sender: Any) {
        delegate?.okTapped()
        dismiss(animated: false, completion: nil)
    }

}
