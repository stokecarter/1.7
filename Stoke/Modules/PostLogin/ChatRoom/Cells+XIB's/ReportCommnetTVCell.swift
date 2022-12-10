//
//  ReportCommnetTVCell.swift
//  Stoke
//
//  Created by Admin on 27/05/21.
//

import UIKit

class ReportCommnetTVCell: UITableViewCell {

    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var comment: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var celibrityIcon: UIImageView!
    @IBOutlet weak var approvalbadge: UIImageView!
    @IBOutlet weak var likeByCreatorViewHeight: NSLayoutConstraint!
    @IBOutlet weak var approveByBtn: UIButton!
    @IBOutlet weak var selectionBtn: UIButton!
    
    
    
    var isLikeByCreator:Bool = false{
        didSet{
            likeByCreatorViewHeight.constant = isLikeByCreator ? 40 : CGFloat.leastNormalMagnitude
            layoutIfNeeded()
        }
    }
    
    var isCommnetSelected:Bool = false{
        didSet{
            if isCommnetSelected{
                contentView.backgroundColor = #colorLiteral(red: 0.9333333333, green: 0.9333333333, blue: 0.9333333333, alpha: 1)
            }else{
                contentView.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionBtn.setImage(#imageLiteral(resourceName: "ic-check-inactive"), for: .normal)
        selectionBtn.setImage(#imageLiteral(resourceName: "ic_login_successful"), for: .selected)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        userImageView.image = nil
    }
    
    func populateCell(_ model:Comment,selected:Bool = false){
        selectionBtn.isSelected = selected
        if model.user.image.isEmpty {
            userImageView.image = #imageLiteral(resourceName: "ic-profile-placeholder")
        } else {
            userImageView.setImageWithIndicator(with: URL(string: model.user.image), placeholderImage: #imageLiteral(resourceName: "ic-profile-placeholder"))
        }
        userName.text = model.user.userName
        comment.text = model.comment
        timeLabel.text = Date(timeIntervalSince1970: model.createdAt/1000).timeAgoSince
        if model.user.isCelebrity{
            celibrityIcon.isHidden = false
            userImageView.borderWidth = 1.5
            userImageView.borderColor = AppColors.themeColor
        }else{
            celibrityIcon.isHidden = true
            userImageView.borderWidth = CGFloat.leastNormalMagnitude
            userImageView.borderColor = .clear
        }
        approvalbadge.isHidden = true
        approveByBtn.setTitle("Approve by \(model.celebrity.userName)", for: .normal)
        isLikeByCreator = model.isApprovedByCelebrity
    }
    
}

