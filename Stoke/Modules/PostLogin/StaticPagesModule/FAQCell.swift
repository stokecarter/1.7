//
//  FAQCell.swift
//  Stoke
//
//  Created by Admin on 29/10/21.
//

import UIKit

class FAQCell: UITableViewCell {
    
    var answer: String = ""{
        didSet{
            answerLbl.text = answer
        }
    }
    
    @IBOutlet weak var answerLbl: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
