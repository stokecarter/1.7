//
//  NotificationTVCell.swift
//  Stoke
//
//  Created by Admin on 26/05/21.
//

import UIKit

class NotificationTVCell: UITableViewCell {
    
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var chatroomImage: UIImageView!
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    
    var isReaded:Bool = true{
        didSet{
            if isReaded{
                bgView.backgroundColor = .white
            }else{
                bgView.backgroundColor = AppColors.themeColor.withAlphaComponent(0.1)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        chatroomImage.image = nil
    }
    
    func populateCell(_ m:NotificationModel){
        isReaded = m.isRead
        titleLabel.text = m.title
        bodyLabel.text = m.message
        if m.chatroomImage.isEmpty {
            chatroomImage.image = #imageLiteral(resourceName: "ic_profile_placeholder")
        } else {
            chatroomImage.setImageWithIndicator(with: URL(string: m.chatroomImage), placeholderImage: #imageLiteral(resourceName: "ic_profile_placeholder"))
        }
        
        timeLabel.text = m.timeStamp
    }
}
