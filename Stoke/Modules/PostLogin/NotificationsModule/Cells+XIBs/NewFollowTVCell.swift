//
//  NewFollowTVCell.swift
//  Stoke
//
//  Created by Admin on 09/06/21.
//

import UIKit

class NewFollowTVCell: UITableViewCell {

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
        if m.fromUser?.isTrusted ?? false{
            bodyLabel.attributedText = m.message.insertTrustedBadge(after: m.fromUser?.name ?? "")
        }else{
            bodyLabel.text = m.message
        }
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
                    followbtn.btnType = .whiteColor
                    followbtn.setTitle("Following", for: .normal)
                case .none:
                    followbtn.btnType = .themeColor
                    followbtn.setTitle("Follow", for: .normal)
                case .pending:
                    followbtn.btnType = .whiteColor
                    followbtn.setTitle("Requested", for: .normal)
                }
            }else{
                if f.followStatus == .accepted{
                    followbtn.btnType = .whiteColor
                    followbtn.setTitle("Following", for: .normal)
                }else{
                    followbtn.btnType = .themeColor
                    followbtn.setTitle("Follow", for: .normal)
                }
            }
        }
        followbtn.titleLabel?.font = AppFonts.Medium.withSize(14)
    }
}
