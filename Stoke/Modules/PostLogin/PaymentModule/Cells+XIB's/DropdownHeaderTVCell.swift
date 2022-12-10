//
//  DropdownHeaderTVCell.swift
//  Stoke
//
//  Created by Admin on 07/05/21.
//

import UIKit

class DropdownHeaderTVCell: UITableViewCell {
    
    
    @IBOutlet weak var heading: UILabel!
    @IBOutlet weak var droupDownBtn: UIButton!
    
    
    var isExpanded:Bool = false{
        didSet{
            if isExpanded{
                UIView.animate(withDuration: 0.33, animations: {
                    self.droupDownBtn.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
                })
            }else{
                UIView.animate(withDuration: 0.33, animations: {
                    self.droupDownBtn.transform = .identity
                })
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}
