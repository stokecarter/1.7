//
//  AddImageTVCell.swift
//  Stoke
//
//  Created by Admin on 21/03/21.
//

import UIKit

class AddImageTVCell: UITableViewCell {
    
    
    @IBOutlet weak var profileIMView: UIImageView!
    
    var tapOnIMView:(()->())?

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        profileIMView.image = nil
    }
    
    @IBAction func addProfileTapped(_ sender: Any) {
        if let tap = tapOnIMView { tap() }
    }
    
    func populateImage(_ img:String){
        if img.isEmpty {
            profileIMView.image = nil
        } else {
            profileIMView.setImageWithIndicator(with: URL(string: img))
        }
        
    }
    
}
