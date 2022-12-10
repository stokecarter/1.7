//
//  AdminNotificationTVCell.swift
//  Stoke
//
//  Created by Admin on 26/05/21.
//

import UIKit

class AdminNotificationTVCell: UITableViewCell {
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var adminImage: UIImageView!
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
        adminImage.image = nil
    }
    
    func populateCell(_ m:NotificationModel){
        isReaded = m.isRead
        titleLabel.text = m.title
        bodyLabel.text = m.message
        if m.userImage.isEmpty {
            adminImage.image = #imageLiteral(resourceName: "ic-profile-placeholder")
        } else {
            adminImage.setImageWithIndicator(with: URL(string: m.userImage), placeholderImage: #imageLiteral(resourceName: "ic-profile-placeholder"))
        }
        
        timeLabel.text = m.timeStamp
    }
    
    func populateAdminNotificationCell(_ m:AdminNotificationModel){
        isReaded = m.isRead
        titleLabel.text = m.title
        bodyLabel.text = m.message
        if m.user.image.isEmpty {
            adminImage.image = #imageLiteral(resourceName: "ic-profile-placeholder")
        } else {
            adminImage.setImageWithIndicator(with: URL(string: m.user.image), placeholderImage: #imageLiteral(resourceName: "ic-profile-placeholder"))
        }
        timeLabel.text = m.timeStamp
    }
    
}
