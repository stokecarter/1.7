//
//  AccesptDeclineTVCell.swift
//  Stoke
//
//  Created by Admin on 21/04/21.
//

import UIKit

class AccesptDeclineTVCell: UITableViewCell {
    
    @IBOutlet weak var acceptBtn: AppButton!
    @IBOutlet weak var declineBtn: AppButton!

    var isAccepted:((Bool)->())?

    override func awakeFromNib() {
        super.awakeFromNib()
        acceptBtn.btnType = .themeColor
        declineBtn.btnType = .whiteColor
    }
    
    @IBAction func btnAction(_ sender: AppButton) {
        if let tap = isAccepted { tap(sender === acceptBtn) }
    }
    
    
}
