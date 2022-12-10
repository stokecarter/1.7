//
//  ReplyThreadTVCell.swift
//  Stoke
//
//  Created by Admin on 20/04/21.
//

import UIKit

class ReplyThreadTVCell: UITableViewCell {
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var comment: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var seeThreadBtn: UIButton!
    @IBOutlet weak var celibrityIcon:UIImageView!
    
    @IBOutlet weak var leadingConstant: NSLayoutConstraint!
    var seeThread:(()->())?
    
    
    var isCommnetSelected:Bool = false{
        didSet{
            if isCommnetSelected{
                contentView.backgroundColor = #colorLiteral(red: 0.9333333333, green: 0.9333333333, blue: 0.9333333333, alpha: 1)
            }else{
                contentView.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            }
        }
    }
    
    
    var isIndexing:Bool?{
        didSet{
            if let _ = isIndexing{
                leadingConstant.constant = 96
            }else{
                leadingConstant.constant = 70
            }
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        userImageView.image = nil
    }
    
    @IBAction func tapOnReply(_ sender: Any) {
        if let tap = seeThread { tap() }
    }
    @IBAction func seeThreadTapped(_ sender: Any) {
        if let tap = seeThread { tap() }
    }
    
    func populateCell(_ reply:Reply?){
        guard let reply = reply else { return }
        if reply.user.image.isEmpty {
            userImageView.image = #imageLiteral(resourceName: "ic-profile-placeholder")
        } else {
            userImageView.setImageWithIndicator(with: URL(string: reply.user.image), placeholderImage: #imageLiteral(resourceName: "ic-profile-placeholder"))
        }
        
        userName.text = reply.user.userName
        comment.text = reply.comment
        timeLabel.text = Date(timeIntervalSince1970: reply.createdAt/1000).timeAgoSince
        seeThreadBtn.setAttributedTitle(NSAttributedString(string: "See Thread", attributes: [NSAttributedString.Key.font:AppFonts.Semibold.withSize(12),NSAttributedString.Key.foregroundColor:AppColors.themeColor,NSAttributedString.Key.underlineStyle:NSUnderlineStyle.single.rawValue,NSAttributedString.Key.underlineColor:AppColors.themeColor]), for: .normal)
        if reply.user.isCelebrity{
            celibrityIcon.isHidden = false
            userImageView.borderWidth = 1.5
            userImageView.borderColor = AppColors.themeColor
        }else{
            celibrityIcon.isHidden = true
            userImageView.borderWidth = CGFloat.leastNormalMagnitude
            userImageView.borderColor = .clear
        }
    }
    
}
