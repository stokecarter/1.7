//
//  InviteUserTVCell.swift
//  Stoke
//
//  Created by Admin on 25/03/21.
//

import UIKit

class InviteUserTVCell: UITableViewCell {
    

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var selectionBtn: UIButton!
    @IBOutlet weak var userNamelabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var inviteSentBtn: UIButton!
    @IBOutlet weak var trustedBadge: UIImageView!
    @IBOutlet weak var celibrityIcon: UIImageView!

    
    
    
    var selectionTapped:(()->())?
    
    var isAlreadyInvited:Bool = false{
        didSet{
            if isAlreadyInvited{
                selectionBtn.isHidden = true
                inviteSentBtn.isHidden = false
            }else{
                selectionBtn.isHidden = false
                inviteSentBtn.isHidden = true
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        isAlreadyInvited = false
        selectionBtn.setImage(#imageLiteral(resourceName: "ic-check-inactive"), for: .normal)
        selectionBtn.setImage(#imageLiteral(resourceName: "ic_login_successful"), for: .selected)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        userImageView.image = nil
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        userImageView.roundCorners()
    }
    
    @IBAction func selectionbtnTapped(_ sender: Any) {
        if let select = selectionTapped { select()}
    }
    
    func populateCell(_ user:User){
        trustedBadge.isHidden = !user.isTrusted
        if user.isCelebrity{
            celibrityIcon.isHidden = false
            userImageView.borderWidth = 1.5
            userImageView.borderColor = AppColors.themeColor
        }else{
            celibrityIcon.isHidden = true
            userImageView.borderWidth = CGFloat.leastNormalMagnitude
            userImageView.borderColor = .clear
        }
        isAlreadyInvited = user.isInvited
        nameLabel.text = user.userName
        userNamelabel.text = user.fullName
        nameLabel.textColor = .black
        if user.image.isEmpty {
            userImageView.image = #imageLiteral(resourceName: "ic-profile-placeholder")
        } else {
            userImageView.setImageWithIndicator(with: URL(string: user.image), placeholderImage: #imageLiteral(resourceName: "ic-profile-placeholder"))
        }
        
        selectionBtn.isSelected = user.isInvited
    }
    
    
}
