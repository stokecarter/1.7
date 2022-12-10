//
//  MyPaymentsTVCell.swift
//  Stoke
//
//  Created by Admin on 12/05/21.
//

import UIKit

class MyPaymentsTVCell: UITableViewCell {
    
    @IBOutlet weak var successStatusBtn: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var chatRoomNameLabel: UILabel!
    @IBOutlet weak var txnIdLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    var date:Date = Date(){
        didSet{
            let t = date.toString(dateFormat: "h:mm a")
            let d = date.toString(dateFormat: "d MMM")
            let txt = "\(d) | \(t)"
            timeLabel.text = txt
        }
    }
    
    func populateCell(_ p:PaymentModel){
        if p.paymentStatus == .success{
            successStatusBtn.backgroundColor = #colorLiteral(red: 0.2901960784, green: 0.6862745098, blue: 0.2235294118, alpha: 1).withAlphaComponent(0.1)
            successStatusBtn.setTitleColor(#colorLiteral(red: 0.2901960784, green: 0.6862745098, blue: 0.2235294118, alpha: 1), for: .normal)
        }else if p.paymentStatus == .pending{
            successStatusBtn.backgroundColor = UIColor.blue.withAlphaComponent(0.1)
            successStatusBtn.setTitleColor(UIColor.blue, for: .normal)
        }else if p.paymentStatus == .failed{
            successStatusBtn.backgroundColor = UIColor.red.withAlphaComponent(0.1)
            successStatusBtn.setTitleColor(UIColor.red, for: .normal)
        }else{
            successStatusBtn.isHidden = true
        }
        successStatusBtn.setTitle(p.paymentStatus.title, for: .normal)
        date = p.createDate
        amountLabel.text = p.amount.toCurrency
        chatRoomNameLabel.text = p.room.name
        txnIdLabel.text = p.transactionId.isEmpty ? "-" : p.transactionId
        
    }
    
}
