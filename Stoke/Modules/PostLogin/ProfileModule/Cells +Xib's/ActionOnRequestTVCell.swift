//
//  ActionOnRequestTVCell.swift
//  Stoke
//
//  Created by Admin on 08/06/21.
//

import UIKit

class ActionOnRequestTVCell: UITableViewCell {

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var acceptbtn: AppButton!
    @IBOutlet weak var declineBtn: AppButton!
    var actionOnRequest:((Bool)->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initailSetup()
    }
    
    private func initailSetup(){
        titleLbl.font = AppFonts.Semibold.withSize(14)
        acceptbtn.btnType = .themeColor
        declineBtn.btnType = .whiteColor
        declineBtn.setTitleColor(AppColors.themeColor, for: .normal)
        [declineBtn,acceptbtn].forEach {
            $0?.titleLabel?.font = AppFonts.Medium.withSize(14)
        }
    }
    
    @IBAction func actionTapped(_ sender: AppButton) {
        if let action = actionOnRequest { action(sender == acceptbtn)}
    }
    
    func populate(_ name:String){
        titleLbl.text = "\(name) wants to follow you"
    }
    
}
