//
//  NotificationAcceptTVCell.swift
//  Stoke
//
//  Created by Admin on 26/05/21.
//

import UIKit


enum FollowStatus:String{
    case pending = "pending"
    case accepted = "accepted"
    case none = "none"
}

class NotificationAcceptTVCell: UITableViewCell {
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var chatroomImage: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var acceptBtn: AppButton!
    @IBOutlet weak var declineBtn: AppButton!
    @IBOutlet weak var statusbtn: UIButton!
    @IBOutlet weak var stackViewHeight: NSLayoutConstraint!
    @IBOutlet weak var stackViewBottomHeight: NSLayoutConstraint!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var titleLeadingConstant: NSLayoutConstraint!
    @IBOutlet weak var chatroomImageHeight: NSLayoutConstraint!
    
    var actionOn:((Bool)->())?
    
    var isReaded:Bool = true{
        didSet{
            if isReaded{
                bgView.backgroundColor = .white
            }else{
                bgView.backgroundColor = AppColors.themeColor.withAlphaComponent(0.1)
            }
        }
    }
    
    var hideBtn:Bool = false{
        didSet{
            if hideBtn{
                acceptBtn.isHidden = true
                declineBtn.isHidden = true
                statusbtn.isHidden = false
                stackViewBottomHeight.constant = CGFloat.leastNormalMagnitude
                stackViewHeight.constant = CGFloat.leastNormalMagnitude
            }else{
                acceptBtn.isHidden = false
                declineBtn.isHidden = false
                statusbtn.isHidden = true
                acceptBtn.setTitle("Accept", for: .normal)
                declineBtn.setTitle("Decline", for: .normal)
                stackViewBottomHeight.constant = 14
                stackViewHeight.constant = 35
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        acceptBtn.btnType = .themeColor
        declineBtn.btnType = .whiteColor
        [acceptBtn,declineBtn].forEach {
            $0?.titleLabel?.font = AppFonts.Medium.withSize(14)
        }
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        chatroomImage.image = nil
    }
    
    @IBAction func acceptTapped(_ sender: Any) {
        if let t = actionOn { t(true)}
    }
    
    @IBAction func declineTapped(_ sender: Any) {
        if let t = actionOn { t(false)}
    }
    
    func populateInviteType(_ m:NotificationModel){
        titleLeadingConstant.constant = 14
        chatroomImageHeight.constant = 40
        if m.notificationType == .requestAccepted{
            hideBtn = true
            statusbtn.isHidden = true
        }else{
            if m.roomType == ._private{
                if m.isInvitedByCreator{
                    if let u = m.fromUser?.inviteStatus{
                        switch u {
                        case .pending:
                            hideBtn = false
                        case .accepted:
                            hideBtn = false
                            statusbtn.isHidden = true
                            acceptBtn.isHidden = true
                            declineBtn.isHidden = false
                            declineBtn.setTitle("Accepted", for: .normal)
                        default:
                            hideBtn = true
                            statusbtn.setTitle(u.rawValue, for: .normal)
                            statusbtn.setTitleColor(AppColors.themeColor, for: .normal)
                        }
                    }
                }else{
                    hideBtn = true
                    statusbtn.isHidden = true
                }
            }else{
                hideBtn = true
                statusbtn.isHidden = true
            }
        }
        isReaded = m.isRead
        titleLabel.text = m.title
        bodyLabel.text = m.message
        if m.chatroomImage.isEmpty {
            chatroomImage.image = #imageLiteral(resourceName: "ic_profile_placeholder")
        } else {
            chatroomImage.setImageWithIndicator(with: URL(string: m.chatroomImage), placeholderImage: #imageLiteral(resourceName: "ic_profile_placeholder"))
        }
        
        timeLabel.text = m.timeStamp
        userImage.setImageWithIndicator(with: URL(string: m.fromUser?.image ?? ""), placeholderImage: #imageLiteral(resourceName: "ic-profile-placeholder"))
        layoutIfNeeded()
    }
    
    
    func populateFollowRequestStatus(_ m:NotificationModel){
        titleLeadingConstant.constant = CGFloat.leastNormalMagnitude
        chatroomImageHeight.constant = CGFloat.leastNormalMagnitude
        guard let u = m.fromUser else { return }
        hideBtn = true
        acceptBtn.isHidden = true
        declineBtn.isHidden = true
        statusbtn.isHidden = true
        isReaded = m.isRead
        titleLabel.text = m.title
        bodyLabel.text = m.message
        if m.chatroomImage.isEmpty {
            chatroomImage.image = #imageLiteral(resourceName: "ic_profile_placeholder")
        } else {
            chatroomImage.setImageWithIndicator(with: URL(string: m.chatroomImage), placeholderImage: #imageLiteral(resourceName: "ic_profile_placeholder"))
        }
        
        timeLabel.text = m.timeStamp
        userImage.setImageWithIndicator(with: URL(string: u.image), placeholderImage: #imageLiteral(resourceName: "ic-profile-placeholder"))
        layoutIfNeeded()
    }
    
    func populateFollowRequest(_ m:NotificationModel){
        titleLeadingConstant.constant = CGFloat.leastNormalMagnitude
        chatroomImageHeight.constant = CGFloat.leastNormalMagnitude
        hideBtn = false
        acceptBtn.isHidden = false
        declineBtn.isHidden = false
        statusbtn.isHidden = true
        isReaded = m.isRead
        titleLabel.text = m.title
        bodyLabel.text = m.message
        
        if m.chatroomImage.isEmpty {
            chatroomImage.image = #imageLiteral(resourceName: "ic_profile_placeholder")
        } else {
            chatroomImage.setImageWithIndicator(with: URL(string: m.chatroomImage), placeholderImage: #imageLiteral(resourceName: "ic_profile_placeholder"))
        }
        
        timeLabel.text = m.timeStamp
        userImage.setImageWithIndicator(with: URL(string: m.userImage), placeholderImage: #imageLiteral(resourceName: "ic-profile-placeholder"))
        layoutIfNeeded()
    }
    
    func populateReply(_ m:NotificationModel){
        titleLeadingConstant.constant = 14
        chatroomImageHeight.constant = 40
        hideBtn = true
        statusbtn.isHidden = true
        isReaded = m.isRead
        titleLabel.text = m.title
        bodyLabel.text = m.message
        
        if m.chatroomImage.isEmpty {
            chatroomImage.image = #imageLiteral(resourceName: "ic_profile_placeholder")
        } else {
            chatroomImage.setImageWithIndicator(with: URL(string: m.chatroomImage), placeholderImage: #imageLiteral(resourceName: "ic_profile_placeholder"))
        }
        
        timeLabel.text = m.timeStamp
        userImage.setImageWithIndicator(with: URL(string: m.fromUser?.image ?? ""), placeholderImage: #imageLiteral(resourceName: "ic-profile-placeholder"))
        layoutIfNeeded()
    }
    
    func populateTagEventReminder(_ m:NotificationModel){
        titleLeadingConstant.constant = 14
        chatroomImageHeight.constant = 40
        hideBtn = true
        statusbtn.isHidden = true
        isReaded = m.isRead
        titleLabel.text = m.title
        bodyLabel.text = m.message
        if m.chatroomImage.isEmpty {
            chatroomImage.image = #imageLiteral(resourceName: "ic_profile_placeholder")
        } else {
            chatroomImage.setImageWithIndicator(with: URL(string: m.chatroomImage), placeholderImage: #imageLiteral(resourceName: "ic_profile_placeholder"))
        }
        
        timeLabel.text = m.timeStamp
        userImage.setImageWithIndicator(with: URL(string: m.tagImage), placeholderImage: #imageLiteral(resourceName: "ic-profile-placeholder"))
        layoutIfNeeded()
    }
    
    func populateNewChatroom(_ m:NotificationModel){
        guard let u = m.fromUser else { return }
        titleLeadingConstant.constant = 14
        chatroomImageHeight.constant = 40
        hideBtn = true
        acceptBtn.isHidden = true
        declineBtn.isHidden = true
        statusbtn.isHidden = true
        isReaded = m.isRead
        titleLabel.text = m.title
        bodyLabel.text = m.message
        if m.chatroomImage.isEmpty {
            chatroomImage.image = #imageLiteral(resourceName: "ic_profile_placeholder")
        } else {
            chatroomImage.setImageWithIndicator(with: URL(string: m.chatroomImage), placeholderImage: #imageLiteral(resourceName: "ic_profile_placeholder"))
        }
        
        timeLabel.text = m.timeStamp
        userImage.setImageWithIndicator(with: URL(string: u.image), placeholderImage: #imageLiteral(resourceName: "ic-profile-placeholder"))
        layoutIfNeeded()
    }
    
    func populateAdminNotification(_ m:AdminNotificationModel){
        titleLeadingConstant.constant = 14
        chatroomImageHeight.constant = 40
        hideBtn = true
        statusbtn.isHidden = true
        isReaded = m.isRead
        titleLabel.text = m.title
        bodyLabel.text = m.message
        if m.image.isEmpty {
            chatroomImage.image = #imageLiteral(resourceName: "ic_profile_placeholder")
        } else {
            chatroomImage.setImageWithIndicator(with: URL(string: m.image), placeholderImage: #imageLiteral(resourceName: "ic_profile_placeholder"))
        }
        
        timeLabel.text = m.timeStamp
        userImage.setImageWithIndicator(with: URL(string: m.user.image), placeholderImage: #imageLiteral(resourceName: "ic-profile-placeholder"))
        layoutIfNeeded()
    }
}
