//
//  VeriticalGridCVCell.swift
//  Stoke
//
//  Created by Admin on 18/03/21.
//

import UIKit

class VeriticalGridCVCell: UICollectionViewCell {
    
    @IBOutlet weak var imView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        DispatchQueue.main.async { [unowned self] in
            self.imView.roundCorner([.allCorners], radius: 10)
        }
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imView.image = nil
    }
    
    func populateCell(_ cat:Categories){
        if cat.image.isEmpty {
            imView.image = nil
        } else {
            imView.setImageWithIndicator(with: URL(string: cat.image))
        }
        
        titleLabel.text = cat.name
    }

    private func initialSetup(){
        imView.image = #imageLiteral(resourceName: "INDIA-vs-ENGLAND")
        imView.clipsToBounds = true
        titleLabel.font = AppFonts.Semibold.withSize(14)
        titleLabel.textColor = .white
        titleLabel.text = "Sports"
    }
    
}
