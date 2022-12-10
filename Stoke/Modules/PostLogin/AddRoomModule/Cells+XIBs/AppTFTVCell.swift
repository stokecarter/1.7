//
//  AppTFTVCell.swift
//  Stoke
//
//  Created by Admin on 21/03/21.
//

import UIKit

class AppTFTVCell: UITableViewCell {

    @IBOutlet weak var chatroomNameTF: AppTextField!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        chatroomNameTF.setupAs = .chatroom
    }
    
}
