//
//  RoomTimeTVCell.swift
//  Stoke
//
//  Created by Admin on 13/04/21.
//

import UIKit

class RoomTimeTVCell: UITableViewCell {
    
    
    @IBOutlet weak var timeLabel: UILabel!
    
    var showTime:Date? = nil{
        didSet{
            if let d = showTime{
                let dt = d.toString(dateFormat: "MMM d")
                let time = d.toString(dateFormat: "h:mm a")
                let str = "This room opens \(dt) at \(time)"
                let attributedString = NSMutableAttributedString(string: str,
                                                                 attributes: [NSAttributedString.Key.font: AppFonts.Medium.withSize(14),NSAttributedString.Key.foregroundColor:AppColors.labelColor])
                let boldFontAttribute: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: AppFonts.Bold.withSize(14),NSAttributedString.Key.foregroundColor:UIColor.black]
                let range1 = (str as NSString).range(of: dt)
                let range2 = (str as NSString).range(of: time)
                attributedString.addAttributes(boldFontAttribute, range: range1)
                attributedString.addAttributes(boldFontAttribute, range: range2)
                timeLabel.attributedText = attributedString
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}
