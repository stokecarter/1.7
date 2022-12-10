//
//  PaymentDetailVC.swift
//  Stoke
//
//  Created by Admin on 12/05/21.
//

import UIKit

class PaymentDetailVC: BaseVC {
    
    @IBOutlet weak var liveLabel: UILabel!
    @IBOutlet weak var privateIndicator: UIImageView!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var imView: UIImageView!
    @IBOutlet weak var groupTitleLabel: UILabel!
    @IBOutlet weak var groupSubTitleLabel: UILabel!
    @IBOutlet weak var liveView: UIView!
    @IBOutlet weak var viewDetail: UIButton!
    @IBOutlet weak var successStatusBtn: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var chatRoomNameLabel: UILabel!
    @IBOutlet weak var txnIdLabel: UILabel!
    
    var model:PaymentModel!
    var viewModel:PaymnetDetailVM!
    
    var isLive:Bool = false
    var date:Date = Date(){
        didSet{
            let t = date.toString(dateFormat: "h:mm a")
            let d = date.toString(dateFormat: "d MMM")
            let txt = "\(d) | \(t)"
            timeLabel.text = txt
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = PaymnetDetailVM(NetworkLayer(), paymnetId: model._id)
        viewModel.update = { [weak self] in
            guard let self = self else { return }
            self.model = self.viewModel.data
            self.populate(self.viewModel.data)
        }
        viewModel.popToBack = { [weak self] in
            self?.pop()
        }
        setNavigationBar(title: "Payment Details", backButton: true)
        imView.roundCorner([.topLeft,.topRight], radius: 8)
        bgView.drawShadow(shadowColor: #colorLiteral(red: 0.368627451, green: 0.368627451, blue: 0.368627451, alpha: 0.35), shadowOpacity: 6, shadowRadius: 3, cornerRadius: 8, offset: CGSize.zero)
        populate(model)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imView.roundCorner([.topLeft,.topRight], radius: 8)
        self.bgView.drawShadow(shadowColor: #colorLiteral(red: 0.368627451, green: 0.368627451, blue: 0.368627451, alpha: 0.35), shadowOpacity: 6, shadowRadius: 3, cornerRadius: 8, offset: CGSize.zero)
    }
    
    override func setupFounts() {
        viewDetail.titleLabel?.font = AppFonts.Medium.withSize(13)
        viewDetail.round(radius: 8)
        viewDetail.setTitleColor(AppColors.themeColor, for: .normal)
        viewDetail.setBorder(width: 1, color: #colorLiteral(red: 0.8392156863, green: 0.8392156863, blue: 0.8392156863, alpha: 1))
        viewDetail.backgroundColor = .white
        viewDetail.addTarget(self, action: #selector(tapOnViewDetail(_:)), for: .touchUpInside)
    }
    
    @objc func tapOnViewDetail(_ sender:UIButton){
        manageNavigation()
    }
    
    private func populate(_ model:PaymentModel){
        let chat = model.room
        isLive = model.room.isLive
        if !isLive{
            if Calendar.current.isDateInToday(chat.startDateObject){
                liveLabel.text = chat.startDateObject.toString(dateFormat: "h:mm a")
            }else{
                liveLabel.text = chat.startDateObject.toString(dateFormat: "MMM d")
            }
            liveLabel.textColor = #colorLiteral(red: 0.4666666667, green: 0.4666666667, blue: 0.4666666667, alpha: 1)
            liveView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.85)
            liveView.setBorderCurve(width: 1, color: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
            liveLabel.font = AppFonts.Bold.withSize(11)
        }else{
            liveLabel.text = "Live"
            liveLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            liveView.setBorderCurve(width: 0, color: .clear)
            liveView.backgroundColor = AppColors.themeColor
            liveLabel.font = AppFonts.Regular.withSize(11)
        }
        imView.setImageWithIndicator(with: URL(string: chat.image))
        groupTitleLabel.text = chat.name
        groupSubTitleLabel.text = chat.event.name
        isLive = chat.isLive
        let t = chat.isConcluded ? "View Recap" : "View Details"
        viewDetail.setTitle(t, for: .normal)
        privateIndicator.isHidden = chat.roomType == ._public
        
        if model.paymentStatus == .success{
            successStatusBtn.backgroundColor = #colorLiteral(red: 0.2901960784, green: 0.6862745098, blue: 0.2235294118, alpha: 1).withAlphaComponent(0.1)
            successStatusBtn.setTitleColor(#colorLiteral(red: 0.2901960784, green: 0.6862745098, blue: 0.2235294118, alpha: 1), for: .normal)
        }else if model.paymentStatus == .pending{
            successStatusBtn.backgroundColor = UIColor.blue.withAlphaComponent(0.1)
            successStatusBtn.setTitleColor(UIColor.blue, for: .normal)
        }else if model.paymentStatus == .failed{
            successStatusBtn.backgroundColor = UIColor.red.withAlphaComponent(0.1)
            successStatusBtn.setTitleColor(UIColor.red, for: .normal)
        }else{
            successStatusBtn.isHidden = true
        }
        successStatusBtn.setTitle(model.paymentStatus.title, for: .normal)
        date = model.createDate
        amountLabel.text = model.amount.toCurrency
        chatRoomNameLabel.text = model.room.name
        txnIdLabel.text = model.transactionId.isEmpty ? "-" : model.transactionId
    }
    
    
    private func manageNavigation(){
        
        
        
        
        let r = model.room
        if r.isLive{
            let param = ["chatroomId":r._id]
            SocketIOManager.instance.emit(with: .joinRoom,param )
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let vc = ChatRoomVC.instantiate(fromAppStoryboard: .Chat)
                vc.room = r
                AppRouter.pushFromTabbar(vc)
            }
        }else if r.isConcluded{
            let vc = RecapVC.instantiate(fromAppStoryboard: .Chat)
            vc.room = r
            AppRouter.pushViewController(self, vc)
        }else{
            NotificationHandler.shared.manageRoom(model.room)
        }
    }
}
