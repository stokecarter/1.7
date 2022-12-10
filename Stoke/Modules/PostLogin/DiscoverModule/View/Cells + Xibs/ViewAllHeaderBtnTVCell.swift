//
//  ViewAllHeaderBtnTVCell.swift
//  Stoke
//
//  Created by Admin on 17/03/21.
//

import UIKit

class ViewAllHeaderBtnTVCell: UITableViewCell {

    @IBOutlet weak var viewAllBtn: UIButton!
    @IBOutlet weak var headerLabel: UILabel!
    
    var btnAction:(()->())?
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        initialSetup()
    }
    
    private func initialSetup(){
        viewAllBtn.setTitleColor(AppColors.themeColor, for: .normal)
        viewAllBtn.titleLabel?.font  = AppFonts.Medium.withSize(14)
        headerLabel.font = AppFonts.Medium.withSize(16)
        headerLabel.textColor = #colorLiteral(red: 0.3019607843, green: 0.3019607843, blue: 0.3019607843, alpha: 1)
    }
    
    
    @IBAction func viewAllTapped(_ sender: Any) {
        if let tap = btnAction { tap() }
    }
    
}
