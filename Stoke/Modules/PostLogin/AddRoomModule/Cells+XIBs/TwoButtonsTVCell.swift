//
//  TwoButtonsTVCell.swift
//  Stoke
//
//  Created by Admin on 21/03/21.
//

import UIKit

class TwoButtonsTVCell: UITableViewCell {

    
    @IBOutlet weak var cancelBtn: AppButton!
    @IBOutlet weak var saveBtn: AppButton!
    
    var enableBtn:Bool = false {
        didSet{
            if enableBtn{
                saveBtn.isUserInteractionEnabled = true
                saveBtn.alpha = 1.0
            }else{
                saveBtn.isUserInteractionEnabled = false
                saveBtn.alpha = 0.4
            }
        }
    }
    
    var isSaveGroup:((Bool)->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cancelBtn.btnType = .whiteColor
        saveBtn.btnType = .themeColor
    }
    
    @IBAction func btnTapped(_ sender: AppButton) {
        if let tap = isSaveGroup { tap(sender == saveBtn)}
    }
    
    
}
