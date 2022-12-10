//
//  CardListYVCell.swift
//  Stoke
//
//  Created by Admin on 07/05/21.
//

import UIKit

class CardListYVCell: UITableViewCell {

    @IBOutlet weak var brandTypeIMView: UIImageView!
    @IBOutlet weak var removeBtn: UIButton!
    @IBOutlet weak var cvvTF: AppTextField!
    @IBOutlet weak var selectionBtn: UIButton!
    @IBOutlet weak var cardNoLabel: UILabel!
    
    var removeBtntapped:(()->())?
    var primeSelection:(()->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cvvTF.textLeftPadding = 10
        cvvTF.textRightPadding = 10
        selectionBtn.setImage(#imageLiteral(resourceName: "ic-check-inactive"), for: .normal)
        selectionBtn.setImage(#imageLiteral(resourceName: "ic_active_radio"), for: .selected)
        selectionBtn.addTarget(self, action: #selector(selectionBtnTapped(_:)), for: .touchUpInside)
        cvvTF.setupAs = .cvv
    }
    
    func populateData(_ data:StripCards,isActive:Bool){
        selectionBtn.isSelected = isActive
        brandTypeIMView.image = data.brand.image
        cvvTF.isHidden = true
        removeBtn.isHidden = true
        cardNoLabel.text = "**** **** **** \(data.last4)"
    }
    
    @objc func selectionBtnTapped(_ sender:UIButton){
        if let select = primeSelection { select()}
    }
    
    @IBAction func removeBtnTapped(_ sender: Any) {
        if let tap = removeBtntapped { tap()}
    }
    
    
}
