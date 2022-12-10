//
//  CommnetReactionTVCell.swift
//  Stoke
//
//  Created by Admin on 20/04/21.
//

import UIKit

enum ReationType:String{
    case like
    case dislike
    case clap
    case laugh
}

class CommnetReactionTVCell: UITableViewCell {
    
    @IBOutlet weak var reactionsLedingConstant: NSLayoutConstraint!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var dislikeBtn: UIButton!
    @IBOutlet weak var laughBtn: UIButton!
    @IBOutlet weak var exclimationBtn: UIButton!
    
    @IBOutlet weak var saperatorLine: UIView!
    
    @IBOutlet weak var buttonStackBottomHeight: NSLayoutConstraint!
    
    var hideSaperator:Bool = true{
        didSet{
            saperatorLine.isHidden = hideSaperator
        }
    }
    
    var isCommnetSelected:Bool = false{
        didSet{
            if isCommnetSelected{
                contentView.backgroundColor = #colorLiteral(red: 0.9333333333, green: 0.9333333333, blue: 0.9333333333, alpha: 1)
            }else{
                contentView.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            }
        }
    }
    
    var react:ReationType = .like
    var indexing:Int?{
        didSet{
            if let _ = indexing{
                reactionsLedingConstant.constant = 96
            }else{
                reactionsLedingConstant.constant = 70
            }
        }
    }
    var reactionTapped:((ReationType)->())?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initalSetup()
        hideSaperator = true
    }
    
    private func initalSetup(){
        likeBtn.setImage(#imageLiteral(resourceName: "like-active"), for: .selected)
        likeBtn.setImage(#imageLiteral(resourceName: "ic-like-inactive"), for: .normal)
        dislikeBtn.setImage(#imageLiteral(resourceName: "dislike-inactive"), for: .normal)
        dislikeBtn.setImage(#imageLiteral(resourceName: "dislike-active"), for: .selected)
        laughBtn.setImage(#imageLiteral(resourceName: "laugh-inactive"), for: .normal)
        laughBtn.setImage(#imageLiteral(resourceName: "laugh-active"), for: .selected)
        exclimationBtn.setImage(#imageLiteral(resourceName: "exclamation_inactive"), for: .normal)
        exclimationBtn.setImage(#imageLiteral(resourceName: "exclamation_active"), for: .selected)
        [likeBtn,dislikeBtn,laughBtn,exclimationBtn].forEach {
            $0?.setTitleColor(AppColors.themeColor, for: .selected)
            $0?.setTitleColor(AppColors.labelColor, for: .normal)
        }
    }
    
    @IBAction func reationsTapped(_ sender: UIButton) {
        switch sender {
        case likeBtn:
            if let tap = reactionTapped{ tap(.like)}
        case dislikeBtn:
            if let tap = reactionTapped{ tap(.dislike)}
        case exclimationBtn:
            if let tap = reactionTapped{ tap(.clap)}
        default:
            if let tap = reactionTapped{ tap(.laugh)}
        }
    }
    
    func populateCommnetReacts( model:Comment){
        likeBtn.isSelected = model.isLiked
        dislikeBtn.isSelected = model.isDisliked
        exclimationBtn.isSelected = model.isClap
        laughBtn.isSelected = model.isLaugh
        likeBtn.setTitle("\(model.noOfLikes)", for: .normal)
        dislikeBtn.setTitle("\(model.noOfDislikes)", for: .normal)
        exclimationBtn.setTitle("\(model.noOfClaps)", for: .normal)
        laughBtn.setTitle("\(model.noOfLaughs)", for: .normal)

    }
    
    func populateReplyReacts( model:Reply){
        likeBtn.isSelected = model.isLiked
        dislikeBtn.isSelected = model.isDisliked
        exclimationBtn.isSelected = model.isClap
        laughBtn.isSelected = model.isLaugh
        likeBtn.setTitle("\(model.noOfLikes)", for: .normal)
        dislikeBtn.setTitle("\(model.noOfDislikes)", for: .normal)
        exclimationBtn.setTitle("\(model.noOfClaps)", for: .normal)
        laughBtn.setTitle("\(model.noOfLaughs)", for: .normal)
    }
}
