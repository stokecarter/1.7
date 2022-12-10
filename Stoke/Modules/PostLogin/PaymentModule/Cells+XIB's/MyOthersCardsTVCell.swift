//
//  MyOthersCardsTVCell.swift
//  Stoke
//
//  Created by Admin on 12/05/21.
//

import UIKit

class MyOthersCardsTVCell: UITableViewCell {
    
    @IBOutlet weak var brandTypeIMView: UIImageView!
    @IBOutlet weak var cardNoLabel: UILabel!

    var action:((Bool)->())?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func populateData(_ data:StripCards){
        brandTypeIMView.image = data.brand.image
        cardNoLabel.text = "**** **** **** \(data.last4)"
    }
    
    
    @IBAction func markDefaultTapped(_ sender: Any) {
        if let a = action { a(true)}
    }
    
    @IBAction func removeTapped(_ sender: Any) {
        if let a = action { a(false)}
    }
}
