//
//  AllUsersTVCell.swift
//  Stoke
//
//  Created by Admin on 15/04/21.
//

import UIKit

class AllUsersTVCell: UITableViewCell {
    
    
    
    @IBOutlet weak var trustedBadge: UIImageView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var followBtn: AppButton!
    
    var btnTapped:(()->())?
    
    var isTrusted:Bool = false{
        didSet{
            trustedBadge.isHidden = !isTrusted
        }
    }
    
    var isFollwed:FollowStatus = .none{
        didSet{
            switch isFollwed{
            case .none:
                followBtn.isSelected = false
                followBtn.btnType = .themeRound
                followBtn.setTitle("Follow", for: .normal)
            case .accepted:
                followBtn.isSelected = true
                followBtn.btnType = .whiteRound
                followBtn.setTitle("Following", for: .selected)
                followBtn.setTitleColor(AppColors.themeColor, for: .selected)
            case .pending:
                followBtn.isSelected = true
                followBtn.btnType = .whiteRound
                followBtn.setTitle("Requested", for: .selected)
                followBtn.setTitleColor(AppColors.themeColor, for: .selected)
            }
            followBtn.titleLabel?.font = AppFonts.Medium.withSize(12)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        isFollwed = .none
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        userImageView.image = nil
    }
    
    @IBAction func followBtnTapped(_ sender: AppButton) {
        if let tap = btnTapped { tap()}
    }
    
    func populateCell(_ user:User){
        if user.isGuest{
            usernameLabel.text = "Guest User"
        }else{
            usernameLabel.text = "\(user.userName)"
        }
        usernameLabel.textColor = .black
        nameLabel.text = user.fullName
        if user.image.isEmpty {
            userImageView.image = #imageLiteral(resourceName: "ic-profile-placeholder")
        } else {
            userImageView.setImageWithIndicator(with: URL(string: user.image), placeholderImage: #imageLiteral(resourceName: "ic-profile-placeholder"))
        }
        isFollwed = user.followStatus
        followBtn.isHidden = user.isGuest
        isTrusted = user.isTrusted
        if UserModel.main.isAdmin || UserModel.main.userId == user.id{
            followBtn.isHidden = true
        }
        
    }
}
