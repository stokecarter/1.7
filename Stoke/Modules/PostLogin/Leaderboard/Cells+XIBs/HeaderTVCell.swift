//
//  HeaderTVCell.swift
//  Stoke
//
//  Created by Admin on 27/04/21.
//

import UIKit

class HeaderTVCell: UITableViewCell {
    

    // First
    @IBOutlet weak var firstUserIMView: UIImageView!
    @IBOutlet weak var firstUserName: UILabel!
    @IBOutlet weak var firstName: UILabel!
    @IBOutlet weak var firstTotal: UILabel!
    
    @IBOutlet weak var firstRankCount: UILabel!
    @IBOutlet weak var secondRankCount: UILabel!
    @IBOutlet weak var thirdRankCount: UILabel!
    
    @IBOutlet weak var v1: UIView!
    @IBOutlet weak var v2: UIView!
    @IBOutlet weak var v3: UIView!
    
    @IBOutlet weak var firstTrustedBadge: UIImageView!
    @IBOutlet weak var secondTrustedBadge: UIImageView!
    @IBOutlet weak var thirdTrustedBadge: UIImageView!

    
    
    // Second
    @IBOutlet weak var secondUserIMView: UIImageView!
    @IBOutlet weak var secondUserUserName: UILabel!
    @IBOutlet weak var secondUserName: UILabel!
    @IBOutlet weak var secondUserTotal: UILabel!
    // Third
    @IBOutlet weak var thirdUserIMView: UIImageView!
    @IBOutlet weak var thirdUserUserName: UILabel!
    @IBOutlet weak var thirdUserName: UILabel!
    @IBOutlet weak var thirdUserTotal: UILabel!
    
    
    var tapOnImage:((Int)->())?
    var openuserProfile:((Int)->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        [firstRankCount,secondRankCount,thirdRankCount].forEach {
            $0?.isHidden = false
        }
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(opneFirstList))
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(opneSecondList))
        let tap3 = UITapGestureRecognizer(target: self, action: #selector(opneThirdList))
        firstUserIMView.addGestureRecognizer(tap1)
        firstUserIMView.isUserInteractionEnabled = true
        secondUserIMView.addGestureRecognizer(tap2)
        secondUserIMView.isUserInteractionEnabled = true
        thirdUserIMView.addGestureRecognizer(tap3)
        thirdUserIMView.isUserInteractionEnabled = true
        
        [secondUserUserName,firstUserName,thirdUserUserName].forEach {
            $0?.isUserInteractionEnabled = true
        }
        let tap4 = UITapGestureRecognizer(target: self, action: #selector(openFirstProfile))
        let tap5 = UITapGestureRecognizer(target: self, action: #selector(openSecondProfile))
        let tap6 = UITapGestureRecognizer(target: self, action: #selector(openThirdProfile))
        secondUserUserName.addGestureRecognizer(tap5)
        firstUserName.addGestureRecognizer(tap4)
        thirdUserUserName.addGestureRecognizer(tap6)
        [firstUserName,secondUserUserName,thirdUserUserName].forEach{
            $0?.font = AppFonts.Medium.withSize(12)
            $0?.numberOfLines = 1
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        firstUserIMView.image = nil
    }
    
    @objc func openFirstProfile(){
        if let t = openuserProfile { t(1)}
    }
    @objc func openSecondProfile(){
        if let t = openuserProfile { t(2)}
    }
    @objc func openThirdProfile(){
        if let t = openuserProfile { t(3)}
    }
    
    @objc func opneFirstList(){
        if let tap = tapOnImage { tap(1) }
    }
    @objc func opneSecondList(){
        if let tap = tapOnImage { tap(2) }
    }
    @objc func opneThirdList(){
        if let tap = tapOnImage { tap(3) }
    }
    
    func populateCell(_ d:[LeaderBoard],type:LeaderBordType){
        if let first = d.firstIndex(where: { $0.rank == 1 }){
            let f = d[first]
            if f.image.isEmpty {
                firstUserIMView.image = #imageLiteral(resourceName: "ic-profile-placeholder")
            } else {
                firstUserIMView.setImageWithIndicator(with: URL(string: f.image), placeholderImage: #imageLiteral(resourceName: "ic-profile-placeholder"))
            }
            
            firstUserName.text = f.userName
            firstName.text = f.fullName
            firstTrustedBadge.isHidden = !f.isTrusted
            switch type {
            case .like:
                firstTotal.text = "\(f.count)"
            case .clap:
                firstTotal.text = "\(f.count)"
            default:
                firstTotal.text = "\(f.count)"
            }
            v1.isHidden = false
            firstUserIMView.borderWidth = 2
        }else{
            firstTrustedBadge.isHidden = true
            firstUserIMView.borderWidth = 0
            firstUserIMView.image = nil
            firstUserName.text = nil
            firstName.text = nil
            v1.isHidden = true
            firstTotal.text = nil
            
        }
        if let second = d.firstIndex(where: { $0.rank == 2}){
            let f = d[second]
            if f.image.isEmpty {
                secondUserIMView.image = #imageLiteral(resourceName: "ic-profile-placeholder")
            } else {
                secondUserIMView.setImageWithIndicator(with: URL(string: f.image), placeholderImage: #imageLiteral(resourceName: "ic-profile-placeholder"))
            }
            
            secondUserUserName.text = f.userName
            secondUserName.text = f.fullName
            secondTrustedBadge.isHidden = !f.isTrusted
            switch type {
            case .like:
                secondUserTotal.text = "\(f.count)"
            case .clap:
                secondUserTotal.text = "\(f.count)"
            default:
                secondUserTotal.text = "\(f.count)"
            }
            v2.isHidden = false
            secondUserIMView.borderWidth = 2
        }else{
            secondTrustedBadge.isHidden = true
            secondUserIMView.borderWidth = 0
            secondUserIMView.image = nil
            secondUserUserName.text = nil
            secondUserName.text = nil
            v2.isHidden = true
            secondUserTotal.text = nil
            
        }
        if let third = d.firstIndex(where: { $0.rank == 3}){
            let f = d[third]
            if f.image.isEmpty {
                thirdUserIMView.image = #imageLiteral(resourceName: "ic-profile-placeholder")
            } else {
                thirdUserIMView.setImageWithIndicator(with: URL(string: f.image), placeholderImage: #imageLiteral(resourceName: "ic-profile-placeholder"))
            }
            
            thirdUserUserName.text = f.userName
            thirdUserName.text = f.fullName
            switch type {
            case .like:
                thirdUserTotal.text = "\(f.count)"
            case .clap:
                thirdUserTotal.text = "\(f.count)"
            default:
                thirdUserTotal.text = "\(f.count)"
            }
            v3.isHidden = false
            thirdTrustedBadge.isHidden = !f.isTrusted
            thirdUserIMView.borderWidth = 2
        }else{
            thirdTrustedBadge.isHidden = true
            thirdUserIMView.borderWidth = 0
            thirdUserIMView.image = nil
            thirdUserUserName.text = nil
            thirdUserName.text = nil
            v3.isHidden = true
            thirdUserTotal.text = nil
        }
    }
    
}
