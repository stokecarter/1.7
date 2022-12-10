//
//  BlockUserListTVCell.swift
//  Stoke
//
//  Created by Admin on 18/05/21.
//

import UIKit

class BlockUserListTVCell: UITableViewCell {

    
    @IBOutlet weak var trustedbadge: UIImageView!
    @IBOutlet weak var blockBtn: AppButton!
    @IBOutlet weak var userProfilePicture: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    
    var tapped:(()->())?
    var isTrusted:Bool = false{
        didSet{
            trustedbadge.isHidden = !isTrusted
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        userProfilePicture.image = nil
    }
    
    func populateBlockCell(_ u:User){
        if u.id == UserModel.main.userId{
            blockBtn.isHidden = true
        }else{
            blockBtn.isHidden = false
        }
        blockBtn.btnType = .themeRound
        blockBtn.titleLabel?.font = AppFonts.Medium.withSize(11)
        blockBtn.setTitle("Unblock", for: .normal)
        if u.image.isEmpty {
            userProfilePicture.image = #imageLiteral(resourceName: "ic-profile-placeholder")
        } else {
            userProfilePicture.setImageWithIndicator(with: URL(string: u.image), placeholderImage: #imageLiteral(resourceName: "ic-profile-placeholder"))
        }
        nameLabel.text = u.fullName
        userNameLabel.text = u.userName
        userNameLabel.textColor = .black
        if UserModel.main.isAdmin{
            blockBtn.isHidden = true
        }
        isTrusted = u.isTrusted
    }
    
    func populateFollower(_ u:User){
        if u.id == UserModel.main.userId{
            blockBtn.isHidden = true
        }else{
            blockBtn.isHidden = false
        }
        blockBtn.btnType = .whiteRound
        if u.followStatus == .accepted{
            blockBtn.setTitle("Following", for: .normal)
            blockBtn.btnType = .whiteRound
            blockBtn.setTitleColor(AppColors.themeColor, for: .normal)
        }else if u.followStatus == .pending{
            blockBtn.setTitle("Requested", for: .normal)
            blockBtn.btnType = .themeRound
        }else{
            blockBtn.setTitle("Follow", for: .normal)
            blockBtn.btnType = .themeRound
        }
        blockBtn.titleLabel?.font = AppFonts.Medium.withSize(11)
        if u.image.isEmpty {
            userProfilePicture.image = #imageLiteral(resourceName: "ic-profile-placeholder")
        } else {
            userProfilePicture.setImageWithIndicator(with: URL(string: u.image), placeholderImage: #imageLiteral(resourceName: "ic-profile-placeholder"))
        }
        
        nameLabel.text = u.fullName
        userNameLabel.text = u.userName
        userNameLabel.textColor = .black
        if UserModel.main.isAdmin{
            blockBtn.isHidden = true
        }
        isTrusted = u.isTrusted
    }
    
    func populateFollowing(_ u:User){
        if u.id == UserModel.main.userId{
            blockBtn.isHidden = true
        }else{
            blockBtn.isHidden = false
        }
        blockBtn.btnType = .whiteRound
        if u.followStatus == .accepted{
            blockBtn.setTitle("Following", for: .normal)
            blockBtn.btnType = .whiteRound
            blockBtn.setTitleColor(AppColors.themeColor, for: .normal)
        }else{
            blockBtn.setTitle("Follow", for: .normal)
            blockBtn.btnType = .themeRound
        }        
        blockBtn.titleLabel?.font = AppFonts.Medium.withSize(11)
        if u.image.isEmpty {
            userProfilePicture.image = #imageLiteral(resourceName: "ic-profile-placeholder")
        } else {
            userProfilePicture.setImageWithIndicator(with: URL(string: u.image), placeholderImage: #imageLiteral(resourceName: "ic-profile-placeholder"))
        }
        nameLabel.text = u.fullName
        userNameLabel.text = u.userName
        userNameLabel.textColor = .black
        if UserModel.main.isAdmin{
            blockBtn.isHidden = true
        }
        isTrusted = u.isTrusted
    }
    
    @IBAction func blockTapped(_ sender: Any) {
        if let t = tapped{ t()}
    }
    
}
