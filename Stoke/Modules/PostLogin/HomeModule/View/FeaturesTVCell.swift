//
//  FeaturesTVCell.swift
//  Stoke
//
//  Created by Admin on 17/03/21.
//

import UIKit

class FeaturesTVCell: UITableViewCell {

    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var eventTimeLabel: UILabel!
    @IBOutlet weak var liveView: UIView!
    @IBOutlet weak var imView: UIImageView!
    @IBOutlet weak var eventCategoryLabel: UILabel!
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var noOfRoomsLabel: UILabel!
//    @IBOutlet weak var noOfPeoplesLabel: UILabel!
    
    var viewRoomAvailable = "View Rooms Available"

    var setPeople:Int = 0 {
        didSet{
            let str = "\(setPeople) People"
//            noOfPeoplesLabel.attributedText = attributedText(withString: str, boldString: "\(setRooms)", font: AppFonts.Regular.withSize(12))
        }
    }
    
    var isLive:Bool = false{
        didSet{
            liveView.isHidden = !isLive
            eventTimeLabel.isHidden = isLive
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        noOfRoomsLabel.text = viewRoomAvailable
        setPeople = 17
        isLive = false
        eventTimeLabel.font = AppFonts.Regular.withSize(12)
        eventTimeLabel.textColor = AppColors.labelColor
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imView.image = nil
        
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        bgView.drawShadow(shadowColor: #colorLiteral(red: 0.368627451, green: 0.368627451, blue: 0.368627451, alpha: 0.35), shadowOpacity: 6, shadowRadius: 4, cornerRadius: 8, offset: CGSize.zero)
        imView.roundCorner([.topLeft,.bottomLeft], radius: 8)
    }
    
    func populateData(_ event:Event,isFeature:Bool = false){
        isLive = event.isLive
        if isFeature{
            eventTimeLabel.text = event.startDateTimeFormat
        }else{
            if event.startDate.isToday{
                eventTimeLabel.text = event.startDateTimeFormat
            }else{
                let d = event.startDate.toString(dateFormat: "MMM d")
                let t = event.startDateTimeFormat
                eventTimeLabel.text = d + " | " + t
            }
        }
        if event.isEventConcluded{
            eventTimeLabel.text = "Ended"
        }
        if event.squareImage.isEmpty {
            imView.image = nil

        } else {
            imView.setImageWithIndicator(with: URL(string: event.squareImage))

        }
        eventCategoryLabel.text = event.category.name
        eventNameLabel.text = event.name
//        setPeople = event.noOfUsers
    }
    
    
    
    func populateSearchData(_ event:Event){
        isLive = event.isLive
        if event.isEventConcluded{
            eventTimeLabel.text = "Ended"
        }else{
            let d = event.startDate.toString(dateFormat: "MMM d")
            let t = event.startDateTimeFormat
            eventTimeLabel.text = d + " | " + t
        }
        if event.squareImage.isEmpty {
            imView.image = nil
        } else {
            imView.setImageWithIndicator(with: URL(string: event.squareImage))
        }
        
        eventCategoryLabel.text = event.category.name
        eventNameLabel.text = event.name
//        setPeople = event.noOfUsers
    }
    
    private func attributedText(withString string: String, boldString: String,font: UIFont,color:UIColor = AppColors.labelColor) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: string,
                                                         attributes: [NSAttributedString.Key.font: font,NSAttributedString.Key.foregroundColor:color])
        let boldFontAttribute: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: AppFonts.Semibold.withSize(14),NSAttributedString.Key.foregroundColor:color]
        let range = (string as NSString).range(of: boldString)
        attributedString.addAttributes(boldFontAttribute, range: range)
        return attributedString
    }
    
}
