//
//  LeaderboardListTVCell.swift
//  Stoke
//
//  Created by Admin on 27/04/21.
//

import UIKit

class LeaderboardListTVCell: UITableViewCell {

    @IBOutlet weak var trustedBadge: UIImageView!
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var totalLikesCount: UILabel!
    @IBOutlet weak var bgView: UIView!
    
    
    var isTrusted:Bool = false{
        didSet{
            trustedBadge.isHidden = !isTrusted
        }
    }
    
    var openUserProfile:(()->())?
    
    var likes:Int = 0{
        didSet{
            addAttributeText("\(likes)", normalText: "\(likes)")
        }
    }
    
    var claps:Int = 0{
        didSet{
            addAttributeText("\(claps)", normalText: "\(claps)")
        }
    }
    
    var laugh:Int = 0{
        didSet{
            addAttributeText("\(laugh)", normalText: "\(laugh)")
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initalSetup()
        profileImage.isUserInteractionEnabled = true
        userNameLabel.isUserInteractionEnabled = true
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(openProfile))
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(openProfile))
        profileImage.addGestureRecognizer(tap1)
        userNameLabel.addGestureRecognizer(tap2)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        profileImage.image = nil
    }
    
    @objc func openProfile(){
        if let t = openUserProfile{ t()}
    }
    
    private func initalSetup(){
        rankLabel.font = AppFonts.Medium.withSize(16)
        userNameLabel.font = AppFonts.Medium.withSize(14)
        userNameLabel.textColor = #colorLiteral(red: 0.3019607843, green: 0.3019607843, blue: 0.3019607843, alpha: 1)
        rankLabel.textColor = #colorLiteral(red: 0.3019607843, green: 0.3019607843, blue: 0.3019607843, alpha: 1)
        nameLabel.font = AppFonts.Regular.withSize(12)
        nameLabel.textColor = AppColors.labelColor
    }
    
    private func addAttributeText(_ boldtext:String, normalText:String){
        let attributedString = NSMutableAttributedString(string: normalText,
                                                         attributes: [NSAttributedString.Key.font: AppFonts.Medium.withSize(14),NSAttributedString.Key.foregroundColor:AppColors.labelColor])
        let boldFontAttribute: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: AppFonts.Medium.withSize(16),NSAttributedString.Key.foregroundColor:#colorLiteral(red: 0.3019607843, green: 0.3019607843, blue: 0.3019607843, alpha: 1)]
        let range = (normalText as NSString).range(of: boldtext)
        attributedString.addAttributes(boldFontAttribute, range: range)
        totalLikesCount.attributedText = attributedString
    }
    
    func populateCell(_ m:LeaderBoard,type:LeaderBordType){
        switch type {
        case .like: likes = m.count
        case .clap: claps = m.count
        default: laugh = m.count
        }
        
        userNameLabel.text = m.userName
        userNameLabel.textColor = .black
        nameLabel.text = m.fullName
        
        if m.image.isEmpty {
            profileImage.image = #imageLiteral(resourceName: "ic-profile-placeholder")
        } else {
            profileImage.setImageWithIndicator(with: URL(string: m.image), placeholderImage: #imageLiteral(resourceName: "ic-profile-placeholder"))
        }
        
        rankLabel.text = "\(m.rank)."
        if m._id == UserModel.main.userId{
            bgView.borderWidth = 1
            bgView.borderColor = AppColors.themeColor
        }else{
            bgView.borderWidth = CGFloat.leastNormalMagnitude
            bgView.borderColor = .clear
        }
        isTrusted = m.isTrusted
    }
    
}
