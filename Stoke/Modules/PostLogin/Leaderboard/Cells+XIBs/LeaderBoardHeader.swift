//
//  LeaderBoardHeader.swift
//  Stoke
//
//  Created by Admin on 27/04/21.
//

import UIKit

class LeaderBoardHeader: UITableViewCell {
    
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var clapbtn: UIButton!
    @IBOutlet weak var laughBtn: UIButton!
    
    var selectionMade:((UIButton,LeaderBordType)->())?

    override func awakeFromNib() {
        super.awakeFromNib()
        likeBtn.setImage(#imageLiteral(resourceName: "like-inactive"), for: .normal)
        likeBtn.setImage(#imageLiteral(resourceName: "like-active-1"), for: .selected)
        clapbtn.setImage(#imageLiteral(resourceName: "clap-inactive"), for: .normal)
        clapbtn.setImage(#imageLiteral(resourceName: "exclamation-active"), for: .selected)
        laughBtn.setImage(#imageLiteral(resourceName: "laugh-inactive-1"), for: .normal)
        laughBtn.setImage(#imageLiteral(resourceName: "laugh-active"), for: .selected)
        [likeBtn,clapbtn,laughBtn].forEach {
            $0?.setTitleColor(AppColors.themeColor, for: .selected)
            $0?.setTitleColor(AppColors.labelColor, for: .normal)
        }
    }
    
    
    @IBAction func btnSelection(_ sender: UIButton) {
        switch sender {
        case likeBtn:
            if let select = selectionMade { select(sender,.like)}
        case clapbtn:
            if let select = selectionMade { select(sender,.clap)}
        default:
            if let select = selectionMade { select(sender,.laugh)}
        }
    }
    
    func manageSelectedState(_ sender:UIButton){
        switch sender {
        case likeBtn:
            sender.addShadow()
            sender.isSelected = true
            clapbtn.isSelected = false
            laughBtn.isSelected = false
            clapbtn.dropShadow()
            laughBtn.dropShadow()
        case clapbtn:
            sender.isSelected = true
            likeBtn.isSelected = false
            laughBtn.isSelected = false
            sender.addShadow()
            likeBtn.dropShadow()
            laughBtn.dropShadow()
        default:
            sender.isSelected = true
            likeBtn.isSelected = false
            clapbtn.isSelected = false
            sender.addShadow()
            likeBtn.dropShadow()
            clapbtn.dropShadow()
        }
    }
    
}
