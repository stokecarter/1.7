//
//  TagsCVCell.swift
//  Stoke
//
//  Created by Admin on 18/03/21.
//

import UIKit

class TagsCVCell: UICollectionViewCell {

    
    @IBOutlet weak var imView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var bookmarkIMView:UIImageView!
    
    var isSaved:Bool = false{
        didSet{
            bookmarkIMView.image = isSaved ? #imageLiteral(resourceName: "ic_bookmark_active") : #imageLiteral(resourceName: "ic-inactive-bookmark")
            }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imView.image = nil
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        imView.setBorderCurve(width: 2, color: AppColors.labelColor)
        imView.clipsToBounds = true
    }
    
    func populateCell(_ tag:Tag){
        if tag.image.isEmpty {
            imView.image = nil

        } else {
            imView.setImageWithIndicator(with: URL(string: tag.image))
        }
        
        nameLabel.text = tag.name
        isSaved = tag.isSaved
    }

}
