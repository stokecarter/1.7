//
//  HotTakesTVCell.swift
//  Stoke
//
//  Created by Admin on 21/07/22.
//

import UIKit

class HotTakesTVCell: UITableViewCell {

    @IBOutlet weak var postLabel: UILabel!
    @IBOutlet weak var voteLabel: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var upVoteButton: UIButton!
    @IBOutlet weak var downVoteButton: UIButton!
    @IBOutlet weak var postCreatedAtLabel: UILabel!
    
    var upButtonTapped:(()->())?
    var downButtonTapped:(()->())?
    var handelLongPress:(()->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        upVoteButton.addTarget(self, action: #selector(upVoteButtonTapped), for: .touchUpInside)
        downVoteButton.addTarget(self, action: #selector(downVoteButtonTapped), for: .touchUpInside)
        setupLongPressGesture()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func populateData(_ hotTake: HotTake) {
        postLabel.text = hotTake.text
        voteLabel.text = "\(hotTake.vote)"
        postCreatedAtLabel.text  = Date(timeIntervalSince1970: hotTake.createdAt/1000).timeAgoSince
        if hotTake.isVoted {
            voteLabel.textColor = AppColors.themeColor
            if hotTake.ownVote == 1 {
                upVoteButton.isSelected = true//AppColors.themeColor
                downVoteButton.isSelected = false//UIColor.gray
            } else {
                upVoteButton.isSelected = false//UIColor.gray
                downVoteButton.isSelected = true//AppColors.themeColor
            }
        } else {
            voteLabel.textColor = UIColor.gray
            upVoteButton.isSelected = false//UIColor.gray
            downVoteButton.isSelected = false//UIColor.gray
        }
    }
    
    @objc func upVoteButtonTapped(){
        if let tap = upButtonTapped { tap()}
    }
    
    @objc func downVoteButtonTapped(){
        if let tap = downButtonTapped { tap()}
    }
    
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer){
        if gestureRecognizer.state == .began {
            if let long = handelLongPress { long()}
        }
    }
    
    func setupLongPressGesture() {
        let longPressGesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress))
        longPressGesture.minimumPressDuration = 0.5
        longPressGesture.delegate = self
        self.addGestureRecognizer(longPressGesture)
    }
}
