//
//  ProfileHeaderTVCell.swift
//  Stoke
//
//  Created by Admin on 16/05/21.
//

import UIKit

class ProfileHeaderTVCell: UITableViewCell {
    
    @IBOutlet weak var trustedBadge: UIImageView!
    @IBOutlet weak var followersCount: UILabel!
    @IBOutlet weak var followingCount: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var trendingFlagView: UIView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var editBtn: AppButton!
    @IBOutlet weak var likesBtn: UIButton!
    @IBOutlet weak var disLikesBtn: UIButton!
    @IBOutlet weak var clapsbtn: UIButton!
    @IBOutlet weak var laughBtn: UIButton!
    @IBOutlet weak var reactionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var saperatorLine: UIView!
    @IBOutlet weak var trendingcategorylabel: UILabel!
    @IBOutlet weak var ribonImage: UIImageView!
    @IBOutlet weak var buttonTop: NSLayoutConstraint!
    @IBOutlet weak var buttonHeight: NSLayoutConstraint!
    @IBOutlet weak var editButtonBottm: NSLayoutConstraint!
    @IBOutlet weak var profileViewHeight: NSLayoutConstraint!
    @IBOutlet weak var trendingFlagHeight: NSLayoutConstraint!
    
    var buttonTapped:(()->())?
    var showFollowers:((Bool)->())?
    var didHideEditBtn:Bool  = false{
        didSet{
            if didHideEditBtn{
                buttonTop.constant = CGFloat.leastNormalMagnitude
                buttonHeight.constant = CGFloat.leastNormalMagnitude
                
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userImageView.round()
        editBtn.btnType = .whiteColor
        editBtn.titleLabel?.font = AppFonts.Medium.withSize(14)
        editBtn.addTarget(self, action: #selector(editBtnTapped), for: .touchUpInside)
        trendingcategorylabel.minimumScaleFactor = 0.5
        trendingcategorylabel.numberOfLines = 2
        trendingcategorylabel.adjustsFontSizeToFitWidth = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        userImageView.image = nil
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        userImageView.round()
    }
    
    
    func populateCell(_ model:UserProfileModel){
        followersCount.text = "\(model.followersCount)"
        followingCount.text = "\(model.followingCount)"
        if model.bio.isEmpty{
            bioLabel.text = nil
            editButtonBottm.constant = CGFloat.leastNormalMagnitude
        }else{
            bioLabel.text = model.bio
            editButtonBottm.constant = 20
        }
        likesBtn.setTitle("\(model.like)", for: .normal)
        disLikesBtn.setTitle("\(model.dislike)", for: .normal)
        clapsbtn.setTitle("\(model.clap)", for: .normal)
        laughBtn.setTitle("\(model.laugh)", for: .normal)
        userNameLabel.text = model.userName
        
        if model.profilePicture.isEmpty {
            userImageView.image = #imageLiteral(resourceName: "ic-profile-placeholder")
        } else {
            userImageView.setImageWithIndicator(with: URL(string: model.profilePicture), placeholderImage: #imageLiteral(resourceName: "ic-profile-placeholder"))
        }
        
        manageBtnTitle(model._id == UserModel.main.userId, followStatus: model)
        if model.isHideEngagementStats{
            reactionViewHeight.constant = CGFloat.leastNormalMagnitude
            saperatorLine.backgroundColor = .clear
        }else{
            reactionViewHeight.constant = 68
            saperatorLine.backgroundColor = #colorLiteral(red: 0.7882352941, green: 0.7882352941, blue: 0.7882352941, alpha: 1)
        }
        returnRankData(model.rankData)
        trustedBadge.isHidden = !model.isTrusted
        layoutIfNeeded()
    }
    
    @objc func editBtnTapped(){
        if let tap = buttonTapped { tap()}
    }
    
    @IBAction func followerstapped(_ sender: Any) {
        if let t = showFollowers { t(true) }
    }
    
    @IBAction func followingtapped(_ sender: Any) {
        if let t = showFollowers { t(false) }
    }
    
    private func manageBtnTitle(_ isMyProfile:Bool, followStatus:UserProfileModel){
        if UserModel.main.isAdmin{
            didHideEditBtn = true
        }else{
            if isMyProfile{
                editBtn.setTitle("Edit Profile", for: .normal)
                editBtn.btnType = .whiteColor
            }else{
                if followStatus.isPrivateAccount{
                    if followStatus.myfollowStatus == .accepted{
                        editBtn.setTitle("Following", for: .normal)
                        editBtn.btnType = .whiteColor
                    }else if followStatus.myfollowStatus == .pending{
                        editBtn.setTitle("Requested", for: .normal)
                        editBtn.btnType = .whiteColor
                    }else{
                        editBtn.setTitle("Follow", for: .normal)
                        editBtn.btnType = .themeColor
                    }
                }else{
                    if followStatus.isFollow{
                        editBtn.setTitle("Following", for: .normal)
                        editBtn.btnType = .whiteColor
                    }else{
                        editBtn.setTitle("Follow", for: .normal)
                        editBtn.btnType = .themeColor
                    }
                }
            }
            editBtn.titleLabel?.font = AppFonts.Medium.withSize(14)
        }
    }
    
    private func returnRankData(_ d:RankData){
        var s = ""
        trendingFlagView.isHidden = !d.isTop100
        if d.isTop100 {
            profileViewHeight.constant = 135
            trendingFlagHeight.constant = 25
            if d.rankingType == .category{
                switch d.type{
                case .like:
                    s = "\(d.rankString) Most Liked in \(d.category)"
                case .clap:
                    s = "\(d.rankString) Most Emphasized in \(d.category)"
                default:
                    s = "\(d.rankString) Funniest in \(d.category)"
                }
            }else{
                switch d.type{
                case .like:
                    s = "\(d.rankString) Most Liked Overall"
                case .clap:
                    s = "\(d.rankString) Most Emphasized Overall"
                default:
                    s = "\(d.rankString) Funniest Overall"
                }
            }
            trendingcategorylabel.text = s
            switch d.rank {
            case 1...10:
                ribonImage.image = #imageLiteral(resourceName: "golden-ribbon")
            case 11...25:
                ribonImage.image = #imageLiteral(resourceName: "green-ribbon")
            case 26...75:
                ribonImage.image = #imageLiteral(resourceName: "blue-ribbon")
            default:
                ribonImage.image = #imageLiteral(resourceName: "black-ribbon")
            }
        }else{
            trendingcategorylabel.text = nil
            profileViewHeight.constant = 110
            trendingFlagHeight.constant = CGFloat.leastNormalMagnitude
        }
    }
}
