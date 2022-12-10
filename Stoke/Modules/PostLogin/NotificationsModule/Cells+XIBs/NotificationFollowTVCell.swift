//
//  NotificationFollowTVCell.swift
//  Stoke
//
//  Created by Admin on 16/06/21.
//

import UIKit

class NotificationFollowTVCell: UITableViewCell {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var adminImage: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var followbtn: AppButton!
    
    var followbtnTapped:(()->())?
    
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
        followbtn.btnType = .themeRound
        followbtn.addTarget(self, action: #selector(tappedOnfollowbtn), for: .touchUpInside)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        adminImage.image = nil
    }
    
    @objc func tappedOnfollowbtn(){
        if let tap = followbtnTapped { tap()}
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
        if let f = m.fromUser{
            if f.isPrivateAccount{
                switch f.followStatus {
                case .accepted:
                    followbtn.btnType = .whiteRound
                    followbtn.setTitleColor(AppColors.themeColor, for: .normal)
                    followbtn.setTitle("Following", for: .normal)
                case .none:
                    followbtn.btnType = .themeRound
                    followbtn.setTitle("Follow", for: .normal)
                case .pending:
                    followbtn.btnType = .whiteRound
                    followbtn.setTitle("Requested", for: .normal)
                    followbtn.setTitleColor(AppColors.themeColor, for: .normal)
                }
            }else{
                if f.followStatus == .accepted{
                    followbtn.btnType = .whiteRound
                    followbtn.setTitle("Following", for: .normal)
                    followbtn.setTitleColor(AppColors.themeColor, for: .normal)
                }else{
                    followbtn.btnType = .themeRound
                    followbtn.setTitle("Follow", for: .normal)
                }
            }
        }
        followbtn.titleLabel?.font = AppFonts.Medium.withSize(11)
    }
}
