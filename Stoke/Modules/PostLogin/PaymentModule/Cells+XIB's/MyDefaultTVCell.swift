//
//  MyDefaultTVCell.swift
//  Stoke
//
//  Created by Admin on 12/05/21.
//

import UIKit

class MyDefaultTVCell: UITableViewCell {
    
    @IBOutlet weak var brandTypeIMView: UIImageView!
    @IBOutlet weak var cardNoLabel: UILabel!

    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func populateData(_ data:StripCards){
        brandTypeIMView.image = data.brand.image
        cardNoLabel.text = "**** **** **** \(data.last4)"
    }
    
}
