//
//  ChatRoomDetailTVCell.swift
//  Stoke
//
//  Created by Admin on 21/03/21.
//

import UIKit

class ChatRoomDetailTVCell: UITableViewCell {
    
    
    @IBOutlet weak var tagsHeadingLabel: UILabel!
    @IBOutlet weak var roomDateTimeLabel: UILabel!
    @IBOutlet weak var eventname: UILabel!
//    @IBOutlet weak var noOfPeoples: UILabel!
//    @IBOutlet weak var noOfFollowers: UILabel!
    @IBOutlet weak var paidRoomHeight: NSLayoutConstraint!
    @IBOutlet weak var joinRoomBtnHeight: NSLayoutConstraint!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var joinBtn: AppButton!
    @IBOutlet weak var tagsViewHeight: NSLayoutConstraint!
    @IBOutlet weak var stackviewtopConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewPendingbtn: AppButton!
    @IBOutlet weak var dateTimeViewHeightConstant: NSLayoutConstraint!
    @IBOutlet weak var paidAmountLabel: UILabel!
    @IBOutlet weak var acceptbtn: AppButton!
    @IBOutlet weak var declineBtn: AppButton!
    @IBOutlet weak var innerStackView: UIStackView!
    @IBOutlet weak var tagsCollectionViewBottom: NSLayoutConstraint!
    @IBOutlet weak var priceViewBottomHeight: NSLayoutConstraint!
    
    
    var isAccepted:((Bool)->())?
    
    
    var acceptBtnType:Bool = false{
        didSet{
            if acceptBtnType{
                innerStackView.isHidden = false
                acceptbtn.isHidden = false
                declineBtn.isHidden = false
                joinBtn.isHidden = true
                viewPendingbtn.isHidden = true
            }else{
                innerStackView.isHidden = true
                joinBtn.isHidden = false
                viewPendingbtn.isHidden = false
                acceptbtn.isHidden = true
                declineBtn.isHidden = true
            }
        }
    }
    
    
    var joinTapped:(()->())?
    var viewPending:(()->())?
    
    var tags:[Tags] = [] {
        didSet{
            collectionView.reloadData()
        }
    }
    
    var shouldHideAllBtn:Bool = false{
        didSet{
            stackviewtopConstraint.constant = CGFloat.leastNormalMagnitude
            viewPendingbtn.isHidden = true
            joinBtn.isHidden = true
        }
    }
    
    var todayStartTime:Date? = nil{
        didSet{
            if let d = todayStartTime{
                let time = d.toString(dateFormat: "h:mm a")
                let str = "This room opens at \(time)"
                let attributedString = NSMutableAttributedString(string: str,
                                                                 attributes: [NSAttributedString.Key.font: AppFonts.Medium.withSize(14),NSAttributedString.Key.foregroundColor:AppColors.labelColor])
                let boldFontAttribute: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: AppFonts.Bold.withSize(14),NSAttributedString.Key.foregroundColor:UIColor.black]
                let range2 = (str as NSString).range(of: time)
                attributedString.addAttributes(boldFontAttribute, range: range2)
                roomDateTimeLabel.attributedText = attributedString
            }
        }
    }
    
    var showTime:Date? = nil{
        didSet{
            if let d = showTime{
                let dt = d.toString(dateFormat: "MMM d")
                let time = d.toString(dateFormat: "h:mm a")
                let str = "This room opens \(dt) at \(time)"
                let attributedString = NSMutableAttributedString(string: str,
                                                                 attributes: [NSAttributedString.Key.font: AppFonts.Medium.withSize(14),NSAttributedString.Key.foregroundColor:AppColors.labelColor])
                let boldFontAttribute: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: AppFonts.Bold.withSize(14),NSAttributedString.Key.foregroundColor:UIColor.black]
                let range1 = (str as NSString).range(of: dt)
                let range2 = (str as NSString).range(of: time)
                attributedString.addAttributes(boldFontAttribute, range: range1)
                attributedString.addAttributes(boldFontAttribute, range: range2)
                roomDateTimeLabel.attributedText = attributedString
            }
        }
    }
    var showConcludeTime:Date? = nil{
        didSet{
            if let d = showConcludeTime{
                let dt = d.toString(dateFormat: "MMM d")
                let time = d.toString(dateFormat: "h:mm a")
                let str = "This room ended on \(dt) at \(time)"
                let attributedString = NSMutableAttributedString(string: str,
                                                                 attributes: [NSAttributedString.Key.font: AppFonts.Medium.withSize(14),NSAttributedString.Key.foregroundColor:AppColors.labelColor])
                let boldFontAttribute: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: AppFonts.Bold.withSize(14),NSAttributedString.Key.foregroundColor:UIColor.black]
                let range1 = (str as NSString).range(of: dt)
                let range2 = (str as NSString).range(of: time)
                attributedString.addAttributes(boldFontAttribute, range: range1)
                attributedString.addAttributes(boldFontAttribute, range: range2)
                roomDateTimeLabel.attributedText = attributedString
            }
        }
    }
    
    var showTodayConcludeTime:Date? = nil{
        didSet{
            if let d = showTodayConcludeTime{
                let time = d.toString(dateFormat: "h:mm a")
                let str = "This room ended at \(time)"
                let attributedString = NSMutableAttributedString(string: str,
                                                                 attributes: [NSAttributedString.Key.font: AppFonts.Medium.withSize(14),NSAttributedString.Key.foregroundColor:AppColors.labelColor])
                let boldFontAttribute: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: AppFonts.Bold.withSize(14),NSAttributedString.Key.foregroundColor:UIColor.black]
                let range2 = (str as NSString).range(of: time)
                attributedString.addAttributes(boldFontAttribute, range: range2)
                roomDateTimeLabel.attributedText = attributedString
            }
        }
    }
    
    
    @IBAction func btnAction(_ sender: AppButton) {
        if let tap = isAccepted { tap(sender === acceptbtn) }
    }
    var amount:Double = 0{
        didSet{
            let normal = "Price: \(amount.toCurrency)"
            let bold = "\(amount.toCurrency)"
            let attributedString = NSMutableAttributedString(string: normal,
                                                             attributes: [NSAttributedString.Key.font: AppFonts.Medium.withSize(14),NSAttributedString.Key.foregroundColor:AppColors.labelColor])
            let boldFontAttribute: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: AppFonts.Bold.withSize(14),NSAttributedString.Key.foregroundColor:UIColor.black]
            let range1 = (normal as NSString).range(of: bold)
            attributedString.addAttributes(boldFontAttribute, range: range1)
            paidAmountLabel.attributedText = attributedString
        }
    }
    
    var isFree:Bool = false{
        didSet{
            paidRoomHeight.constant = isFree ? CGFloat.leastNormalMagnitude : 20
            priceViewBottomHeight.constant = isFree ? CGFloat.leastNormalMagnitude : 10
        }
    }
    
    var isMyChatRoom:Bool = false{
        didSet{
            if !isMyChatRoom{
                viewPendingbtn.isHidden = true
            }
        }
    }
        
    override func awakeFromNib() {
        super.awakeFromNib()
        acceptbtn.btnType = .themeColor
        declineBtn.btnType = .whiteColor
        acceptBtnType = false
        eventname.font = AppFonts.Bold.withSize(14)
        eventname.textColor = .black
        collectionView.delegate = self
        collectionView.dataSource = self
        viewPendingbtn.btnType = .whiteColor
        collectionView.registerCell(with: TagCVCell.self)
    }
    
    func populateCell(_ chat:ChatRoom){
        tagsViewHeight.constant = chat.tags.isEmpty ? CGFloat.leastNormalMagnitude : 64
        eventname.text = chat.event.name
//        noOfPeoples.text = chat.noOfUsers
//        noOfFollowers.text = chat.noOfFollowings
        isFree = chat.isFree
        if !isFree{
            amount = chat.amount
        }
        if chat.isConcluded{
            if chat.event.endDate.isToday{
                showTodayConcludeTime = chat.event.endDate
            }else{
                showConcludeTime = chat.event.endDate
            }
        }else{
            if chat.startDateObject.isToday{
                todayStartTime = chat.startDateObject
            }else{
                showTime = chat.startDateObject
            }
        }
        
        isMyChatRoom = chat.isCreatedByMe
        dateTimeViewHeightConstant.constant = chat.isLive ? CGFloat.leastNormalMagnitude : 55
        tagsCollectionViewBottom.constant = !chat.isLive ? CGFloat.leastNormalMagnitude : 15
        tags = chat.tags
        layoutIfNeeded()
    }
    
    @IBAction func joinBtnTapped(_ sender: Any) {
        if let tap = joinTapped { tap()}
    }
    
    @IBAction func viewpendingtapped(_ sender: Any) {
        if let tap = viewPending { tap()}
    }
    
}

extension ChatRoomDetailTVCell : UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueCell(with: TagCVCell.self, indexPath: indexPath)
        cell.populateCell(tags[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let h = collectionView.frame.height
        let wd = tags[indexPath.item].name.widthOfText(25, font: AppFonts.Bold.withSize(14))
        let w:CGFloat = wd + 75
        return CGSize(width: w, height: h)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        CommonFunctions.actionOnTags(tags[indexPath.item].id, action: !tags[indexPath.item].isSaved) { [weak self] in
            self?.tags[indexPath.item].isSaved.toggle()
            self?.collectionView.reloadData()
        }
    }
}

