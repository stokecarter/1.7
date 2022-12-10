//
//  EditToggleTVCell.swift
//  Stoke
//
//  Created by Admin on 17/05/21.
//

import UIKit

class EditToggleTVCell: UITableViewCell {
    
    @IBOutlet weak var engagementSwitch: UISwitch!
    @IBOutlet weak var privateAccountSwitch: UISwitch!
    
    var setEngagemnet:((Bool)->())?
    var setPrivateStatus:((Bool)->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func engagementSwitchToggled(_ sender: UISwitch) {
        if let eng = setEngagemnet { eng(sender.isOn)}
    }
    
    @IBAction func privateSwitchToggled(_ sender: UISwitch) {
        if let eng = setPrivateStatus { eng(sender.isOn)}
    }
    
    
}
