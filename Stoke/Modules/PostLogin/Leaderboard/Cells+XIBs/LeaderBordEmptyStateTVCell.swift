//
//  LeaderBordEmptyStateTVCell.swift
//  Stoke
//
//  Created by Admin on 03/05/21.
//

import UIKit

class LeaderBordEmptyStateTVCell: UITableViewCell {
    
    
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    
    var type:LeaderBordType = .like{
        didSet{
            headingLabel.isHidden = false
            iconImageView.isHidden = false
            switch type {
            case .like:
                iconImageView.image = #imageLiteral(resourceName: "no-most-like-available")
                headingLabel.text = "No Most Like Available"
            case .clap:
                iconImageView.image = #imageLiteral(resourceName: "ic-exclamation-black-2")
                headingLabel.text = "No Most Claps Available"
            default:
                iconImageView.image = #imageLiteral(resourceName: "No Most laugh Available")
                headingLabel.text = "No Most laugh Available"
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}
