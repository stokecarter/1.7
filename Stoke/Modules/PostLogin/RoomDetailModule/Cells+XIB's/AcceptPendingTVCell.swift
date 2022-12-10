//
//  AcceptPendingTVCell.swift
//  Stoke
//
//  Created by Admin on 15/04/21.
//

import UIKit

class AcceptPendingTVCell: UITableViewCell {
    
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var acceptBtn: AppButton!
    @IBOutlet weak var rejectBtn: AppButton!
    @IBOutlet weak var statusbtn: UIButton!
    @IBOutlet weak var trustedbadge: UIImageView!
    
    var isAccepted:((Bool)->())?
    
    var isTrusted:Bool = false{
        didSet{
            trustedbadge.isHidden = !isTrusted
        }
    }
    
    var status:RequestStatus = .pending{
        didSet{
            statusbtn.setTitle(status.rawValue, for: .normal)
            if status == .accepted{
                statusbtn.setTitleColor(#colorLiteral(red: 0.2901960784, green: 0.6862745098, blue: 0.2235294118, alpha: 1), for: .normal)
            }else{
                statusbtn.setTitleColor(#colorLiteral(red: 1, green: 0.6352941176, blue: 0.2274509804, alpha: 1), for: .normal)
            }
        }
    }
    
    var showtwoBtn:Bool = false{
        didSet{
            if showtwoBtn{
                statusbtn.isHidden = true
                acceptBtn.isHidden = false
                rejectBtn.isHidden = false
            }else{
                statusbtn.isHidden = false
                acceptBtn.isHidden = true
                rejectBtn.isHidden = true
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        acceptBtn.btnType = .themeRound
        rejectBtn.btnType = .whiteRound
        rejectBtn.setTitleColor(AppColors.themeColor, for: .normal)
        [acceptBtn,rejectBtn].forEach {
            $0?.titleLabel?.font = AppFonts.Medium.withSize(12)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        userImageView.image = nil
    }
    
    @IBAction func btnAction(_ sender: AppButton) {
        if sender === acceptBtn{
            if let tap = isAccepted { tap(true)}
        }else{
            if let tap = isAccepted { tap(false)}
        }
    }
    
    func populatecell(_ user:User){
        usernameLabel.text = "\(user.userName)"
        nameLabel.text = user.fullName
        usernameLabel.textColor = .black
        if user.image.isEmpty {
            userImageView.image = #imageLiteral(resourceName: "ic-profile-placeholder")
        } else {
            userImageView.setImageWithIndicator(with: URL(string: user.image), placeholderImage: #imageLiteral(resourceName: "ic-profile-placeholder"))
        }
        
        status = user.status
        isTrusted = user.isTrusted
        if UserModel.main.isAdmin{
            acceptBtn.isHidden = true
            rejectBtn.isHidden = true
        }
    }
}
