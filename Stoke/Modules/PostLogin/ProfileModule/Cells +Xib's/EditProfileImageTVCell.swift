//
//  EditProfileImageTVCell.swift
//  Stoke
//
//  Created by Admin on 17/05/21.
//

import UIKit

class EditProfileImageTVCell: UITableViewCell {
    
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var changePhotoBtn: UIButton!
    
    var openGalery:(()->())?
    
    var imgUrl:String = ""{
        didSet{
            if imgUrl.isEmpty{
                changePhotoBtn.setTitle("Add Picture", for: .normal)
                userImageView.image = #imageLiteral(resourceName: "ic-profile-placeholder")
            }else{
                userImageView.setImageWithIndicator(with: URL(string: imgUrl), placeholderImage: #imageLiteral(resourceName: "ic-profile-placeholder"))
                changePhotoBtn.setTitle("Change Picture", for: .normal)
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        userImageView.image = nil
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        userImageView.round()
    }
    
    @IBAction func changePhotoBtnTapped(_ sender: Any) {
        if let open = openGalery { open() }
    }
    
}
