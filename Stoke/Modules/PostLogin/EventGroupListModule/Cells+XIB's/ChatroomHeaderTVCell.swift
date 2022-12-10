//
//  ChatroomHeaderTVCell.swift
//  Stoke
//
//  Created by Admin on 21/03/21.
//

import UIKit

class ChatroomHeaderTVCell: UITableViewCell {
    
    
    @IBOutlet weak var trustedBadge: UIImageView!
    @IBOutlet weak var liveLabel: UILabel!
    @IBOutlet weak var liveView: UIView!
    @IBOutlet weak var roomImageView: UIImageView!
    @IBOutlet weak var roomTitle: UILabel!
    @IBOutlet weak var createrImageView: UIImageView!
    @IBOutlet weak var createrUsername: UILabel!
    @IBOutlet weak var groupDesc: UILabel!
    @IBOutlet weak var isPrivateicon: UIImageView!
    
    var isTrusted:Bool = false{
        didSet{
            trustedBadge.isHidden = !isTrusted
        }
    }
    
    var isLive:Bool = false
    var openProfile:(()->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        roomTitle.numberOfLines = 1
//        roomTitle.minimumScaleFactor = 0.5
//        roomTitle.adjustsFontSizeToFitWidth = true
        createrImageView.isUserInteractionEnabled = true
        createrUsername.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapOnImage))
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(tapOnImage))
        createrImageView.addGestureRecognizer(tap)
        createrUsername.addGestureRecognizer(tap2)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        roomImageView.image = nil
        createrImageView.image = nil
    }
    
    @objc func tapOnImage(){
        if let t = openProfile{ t()}
    }
        
    func populateCell(_ chat:ChatRoom){
        isLive = chat.isLive
        printDebug(chat.startDateObject)
        printDebug(chat.isToday)
        
        if !isLive{
            let dt = chat.startDateObject.toString(dateFormat: "MMM d")
            let time = chat.startDateObject.toString(dateFormat: "h:mm a")
            liveLabel.text = time + " | " + dt
            liveLabel.textColor = #colorLiteral(red: 0.4666666667, green: 0.4666666667, blue: 0.4666666667, alpha: 1)
            liveView.backgroundColor = #colorLiteral(red: 0.9490196078, green: 0.9490196078, blue: 0.9490196078, alpha: 0.4)
            liveLabel.font = AppFonts.Bold.withSize(11)
            liveView.isHidden = true
        }else{
            liveLabel.text = "Live"
            liveLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            liveView.backgroundColor = AppColors.themeColor
            liveLabel.font = AppFonts.Regular.withSize(11)
        }
        isPrivateicon.isHidden = chat.roomType == ._public
        if chat.image.isEmpty {
            roomImageView.image = #imageLiteral(resourceName: "ic_profile_placeholder")
        } else {
            roomImageView.setImageWithIndicator(with: URL(string: chat.image), placeholderImage: #imageLiteral(resourceName: "ic_profile_placeholder"))
        }
        
        roomTitle.text = chat.name
        
        if chat.createdBy.image.isEmpty {
            createrImageView.image = #imageLiteral(resourceName: "ic-profile-placeholder")

        } else {
            createrImageView.setImageWithIndicator(with: URL(string: chat.createdBy.image), placeholderImage: #imageLiteral(resourceName: "ic-profile-placeholder"))

        }
        createrUsername.text = chat.createdBy.userName.isEmpty ? "Stoke" : chat.createdBy.userName
        groupDesc.text = chat.description
        isTrusted = chat.createdBy.isTrusted
    }
    
}
