//
//  GroupCVCell.swift
//  Stoke
//
//  Created by Admin on 21/03/21.
//

import UIKit

class GroupCVCell: UICollectionViewCell {

    
    @IBOutlet weak var liveLabel: UILabel!
    @IBOutlet weak var privateIndicator: UIImageView!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var imView: UIImageView!
    @IBOutlet weak var groupTitleLabel: UILabel!
    @IBOutlet weak var groupSubTitleLabel: UILabel!
    @IBOutlet weak var liveView: UIView!
//    @IBOutlet weak var noOfPeoplesCountLabel: UILabel!
//    @IBOutlet weak var noOfFollowersCount: UILabel!
    @IBOutlet weak var viewDetail: UIButton!
    
    var viewDetailTapped:(()->())?
    
    var isLive:Bool = false/*{
        didSet{
            liveView.isHidden = !isLive
        }
    } */
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        printDebug("Cell size : \(rect.width)")
        DispatchQueue.main.async { [unowned self] in
            self.bgView.drawShadow(shadowColor: #colorLiteral(red: 0.368627451, green: 0.368627451, blue: 0.368627451, alpha: 0.35), shadowOpacity: 6, shadowRadius: 3, cornerRadius: 8, offset: CGSize.zero)
            self.imView.roundCorner([.topLeft,.topRight], radius: 8)
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        viewDetail.titleLabel?.font = AppFonts.Medium.withSize(13)
        viewDetail.round(radius: 8)
        viewDetail.setTitleColor(AppColors.themeColor, for: .normal)
        viewDetail.setBorder(width: 1, color: #colorLiteral(red: 0.8392156863, green: 0.8392156863, blue: 0.8392156863, alpha: 1))
        viewDetail.backgroundColor = .white
        viewDetail.addTarget(self, action: #selector(tapOnViewDetail(_:)), for: .touchUpInside)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imView.image = nil
    }
    
    @objc func tapOnViewDetail(_ sender:UIButton){
        if let tap = viewDetailTapped { tap()}
    }
    
    func populatecell(_ chat:ChatRoom){
        isLive = chat.isLive
        if !isLive{
            if chat.isConcluded{
                liveLabel.text = "Ended"
            }else if Calendar.current.isDateInToday(chat.startDateObject){
                liveLabel.text = chat.startDateObject.toString(dateFormat: "h:mm a")
            }else{
                liveLabel.text = chat.startDateObject.toString(dateFormat: "MMM d")
            }
            liveLabel.textColor = #colorLiteral(red: 0.4666666667, green: 0.4666666667, blue: 0.4666666667, alpha: 1)
            liveView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.85)
            liveView.setBorderCurve(width: 1, color: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
            liveLabel.font = AppFonts.Bold.withSize(11)
        }else{
            liveLabel.text = "Live"
            liveLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            liveView.setBorderCurve(width: 0, color: .clear)
            liveView.backgroundColor = AppColors.themeColor
            liveLabel.font = AppFonts.Regular.withSize(11)
        }
        if chat.image.isEmpty {
            imView.image = nil
        } else {
            imView.setImageWithIndicator(with: URL(string: chat.image))
        }
        
        groupTitleLabel.text = chat.name
        groupSubTitleLabel.text = chat.event.name
        isLive = chat.isLive
//        noOfPeoplesCountLabel.text = chat.noOfUsers
//        noOfFollowersCount.text = chat.noOfFollowings
        viewDetail.isHidden = chat.isLive
        if chat.roomType == ._public{
            if chat.isFree{
                let t = chat.isConcluded ? "View Recap" : "View Details"
                viewDetail.setTitle(t, for: .normal)
            }else{
                if chat.isConcluded{
                    let t = chat.paymentStatus == .success ? "View Recap" : "View Details"
                    viewDetail.setTitle(t, for: .normal)
                }else{
                    let t = "View Details"
                    viewDetail.setTitle(t, for: .normal)
                }
            }
        }else{
            if chat.isCreatedByMe{
                let t = chat.isConcluded ? "View Recap" : "View Details"
                viewDetail.setTitle(t, for: .normal)
            }else{
                if chat.isConcluded{
                    let t = chat.requestStatus == .readyToJoin ? "View Recap" : "View Details"
                    viewDetail.setTitle(t, for: .normal)
                }else{
                    let t = "View Details"
                    viewDetail.setTitle(t, for: .normal)
                }
            }
        }
        privateIndicator.isHidden = chat.roomType == ._public
    }

}
