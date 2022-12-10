//
//  RadioBtnTVCell.swift
//  Stoke
//
//  Created by Admin on 21/03/21.
//

import UIKit

class RadioBtnTVCell: UITableViewCell {
    
    @IBOutlet weak var publicBtn: UIButton!
    @IBOutlet weak var privateBtn: UIButton!
    
    @IBOutlet weak var btn1: UIButton!
    @IBOutlet weak var btn2: UIButton!
    
    var isPublicSelected:((Bool)->())?
    var isPublic:Bool = true{
        didSet{
            if isPublic{
                publicBtn.isSelected = true
                privateBtn.isSelected = false
            }else{
                publicBtn.isSelected = false
                privateBtn.isSelected = true
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        initialSetup()
    }
    
    private func initialSetup(){
        [publicBtn,privateBtn].forEach {$0.isUserInteractionEnabled = false}
        [publicBtn,privateBtn].forEach {
            $0?.setImage(#imageLiteral(resourceName: "ic-check-inactive"), for: .normal)
            $0?.setImage(#imageLiteral(resourceName: "ic_active_radio"), for: .selected)
        }
    }
    
    
    @IBAction func publicTapped(_ sender: Any) {
        publicBtn.isSelected = true
        privateBtn.isSelected = false
        if let tap = isPublicSelected { tap(true)}
    }
    
    
    @IBAction func privateTapped(_ sender: Any) {
        privateBtn.isSelected = true
        publicBtn.isSelected = false
        if let tap = isPublicSelected { tap(false)}
    }
    
    
}
