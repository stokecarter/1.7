//
//  CommnetTVCell.swift
//  Stoke
//
//  Created by Admin on 20/04/21.
//

import UIKit

class CommnetTVCell: UITableViewCell {
    
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var comment: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var celibrityIcon: UIImageView!
    @IBOutlet weak var approvalbadge: UIImageView!
    @IBOutlet weak var likeByCreatorViewHeight: NSLayoutConstraint!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var approveByBtn: UIButton!
    @IBOutlet weak var countLabelTrailing: NSLayoutConstraint!
    
    @IBOutlet weak var leadingConstant: NSLayoutConstraint!
    @IBOutlet weak var saperatorLine: UIView!
    
    var openProfileTapped:(()->())?
    var handelLongPress:(()->())?
    
    var showSaperatorLine:Bool = false{
        didSet{
            saperatorLine.isHidden = !showSaperatorLine
        }
    }
    
    var countNo:Int? = nil{
        didSet{
            if let c = countNo{
                countLabel.text = "\(c)."
                countLabelTrailing.constant = 15
                leadingConstant.constant = 45
            }else{
                countLabelTrailing.constant = CGFloat.leastNormalMagnitude
                countLabel.text = ""
                leadingConstant.constant = 16
            }
        }
    }
    
    var showButton:Bool = false{
        didSet{
            if showButton{
                countLabel.text = "0"
                countLabelTrailing.constant = 15
            }else{
                countLabelTrailing.constant = CGFloat.leastNormalMagnitude
                countLabel.text = ""
            }
        }
    }
    
    
    
    var doubleTapped:(()->())?
    
    var isLikeByCreator:Bool = false{
        didSet{
            likeByCreatorViewHeight.constant = isLikeByCreator ? 40 : CGFloat.leastNormalMagnitude
            layoutIfNeeded()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        approvalbadge.image = #imageLiteral(resourceName: "ic-user-trusted")
        showSaperatorLine = false
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapFunc))
                doubleTap.numberOfTapsRequired = 2
                self.addGestureRecognizer(doubleTap)
        self.isUserInteractionEnabled = true
        countLabel.font = AppFonts.Medium.withSize(16)
        userImageView.isUserInteractionEnabled = true
        userName.isUserInteractionEnabled = true
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(openProfile))
        userImageView.addGestureRecognizer(imageTap)
        let nameTap = UITapGestureRecognizer(target: self, action: #selector(openProfile))
        userName.addGestureRecognizer(nameTap)
        setupLongPressGesture()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        userImageView.image = nil
    }

    @objc func openProfile(){
        if let o = openProfileTapped { o()}
    }
    
    @objc func doubleTapFunc() {
        if let tap = doubleTapped { tap()}
    }
    
    func setupLongPressGesture() {
        let longPressGesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress))
        longPressGesture.minimumPressDuration = 0.5
        longPressGesture.delegate = self
        self.addGestureRecognizer(longPressGesture)
    }
    
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer){
        if gestureRecognizer.state == .began {
            if let long = handelLongPress { long()}
        }
    }
    
    func populateCell(_ model:Comment,index:Int? = nil){
        showSaperatorLine = false
        countNo = index
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
        approvalbadge.isHidden = !model.user.isTrusted
        let name = (model.celebrity.fullName.byRemovingLeadingTrailingWhiteSpaces).isEmpty ? model.celebrity.userName : (model.celebrity.fullName.byRemovingLeadingTrailingWhiteSpaces)
        approveByBtn.setTitle("Approved by \(name)", for: .normal)
        isLikeByCreator = model.isApprovedByCelebrity
    }
    
    func populateReplyCell(_ model:Reply){
        countNo = nil
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
        approvalbadge.isHidden = !model.user.isTrusted
        let name = (model.celebrity.fullName.byRemovingLeadingTrailingWhiteSpaces).isEmpty ? model.celebrity.userName : (model.celebrity.fullName.byRemovingLeadingTrailingWhiteSpaces)
        approveByBtn.setTitle("Approved by \(name)", for: .normal)
        isLikeByCreator = model.isApprovedByCelebrity
    }
    
}
