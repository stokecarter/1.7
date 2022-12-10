//
//  RecommentCoatchMarksVC.swift
//  Stoke
//
//  Created by Admin on 17/03/21.
//

import UIKit

class RecommentCoatchMarksVC: BaseVC {

    
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var contentlabel: UILabel!
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var doneBtn: AppButton!
    @IBOutlet weak var buttonHeightConstant: NSLayoutConstraint!
    
    var height:CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buttonHeightConstant.constant = height
        view.layoutIfNeeded()
    }
    
    override func initalSetup() {
        doneBtn.btnType = .themeColor
    }
    
    override func setupFounts() {
        contentlabel.font = AppFonts.Regular.withSize(14)
        contentlabel.textColor = AppColors.labelColor
        headingLabel.font = AppFonts.Bold.withSize(16)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        bottomView.roundCorner([.topLeft,.topRight], radius: 10)
    }
    
    @IBAction func donrbtnTapped(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
    

}
