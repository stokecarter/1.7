//
//  AppThemeBtnTVCell.swift
//  Stoke
//
//  Created by Admin on 21/03/21.
//

import UIKit

class AppThemeBtnTVCell: UITableViewCell {

    
    @IBOutlet weak var appbtn: AppButton!
    
    var createRoom:(()->())?
    override func awakeFromNib() {
        super.awakeFromNib()
        appbtn.btnType = .whiteColor
    }
    
    @IBAction func btnTapped(_ sender: Any) {
        if let tap = createRoom { tap()}
    }
}
