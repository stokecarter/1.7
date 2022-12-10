//
//  FAQSectionCell.swift
//  Stoke
//
//  Created by Admin on 29/10/21.
//

import UIKit

class FAQSectionCell: UITableViewCell {
    
    var question: String = ""{
        didSet{
            questionLbl.text = question
        }
    }
    
    var isOpen: Bool = false{
        didSet{
            if isOpen{
                self.btn.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
                borderView.alpha = 0
            }else{
                self.btn.transform = CGAffineTransform.identity
                borderView.alpha = 1
            }
            
        }
    }
    
    @IBOutlet weak var btn: UIButton!
    @IBOutlet weak var questionLbl: UILabel!
    @IBOutlet weak var borderView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
