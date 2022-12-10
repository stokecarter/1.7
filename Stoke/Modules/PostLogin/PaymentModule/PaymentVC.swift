//
//  PaymentVC.swift
//  Stoke
//
//  Created by Admin on 06/05/21.
//

import UIKit
import Stripe

class PaymentVC: BaseVC {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var payNowBtn: AppButton!
    
    var isCheckOut:Bool = false
    var amount:Double = 0.0
    var showSaveCards = false
    var showAddCard = false
    var cards = 0
    var viewModel:PaymentVM!
    var primeCardIndex = 0
    var room:ChatRoom!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = PaymentVM(NetworkLayer())
        viewModel.amount = amount
        viewModel.reloadData = { [weak self] in
            self?.showSaveCards = !(self?.viewModel.cards.isEmpty ?? true)
            self?.enablePayBtn = self?.showSaveCards ?? false
            self?.showAddCard = !(self?.showSaveCards ?? true)
            self?.tableView.reloadData()
        }
        payNowBtn.setTitle("Pay \(room.amount.toCurrency)", for: .normal)

    }
    
    var enablePayBtn:Bool = false{
        didSet{
            if enablePayBtn{
                payNowBtn.alpha = 1
                payNowBtn.isUserInteractionEnabled = true
            }else{
                payNowBtn.alpha = 0.6
                payNowBtn.isUserInteractionEnabled = false
            }
        }
    }
    
    override func initalSetup() {
        enablePayBtn = false
        setNavigationBar(title: "Payment", backButton: true)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerCell(with: DropdownHeaderTVCell.self)
        tableView.registerCell(with: CardListYVCell.self)
        tableView.registerCell(with: AddCardTVCell.self)
    }
    
    private func presentPaymnetSucess(){
        CommonFunctions.showToastWithMessage("Payment successful.", theme: .success)
        pop()
//        let vc = PaymnetSucessVC.instantiate(fromAppStoryboard: .Chat)
//        vc.modalTransitionStyle = .coverVertical
//        vc.modalPresentationStyle = .overFullScreen
//        vc.delegate = self
//        self.present(vc, animated: false, completion: nil)
    }

    @IBAction func payNowTapped(_ sender: Any) {
        let vc = GenericPopupVC.instantiate(fromAppStoryboard: .Chat)
        vc.delegate = self
        vc.isForDelete = true
        vc.headingText = "Payment"
        vc.subheadingTxt = "Pay \(room.amount.toCurrency) to purchase this Room"
        vc.firstbtnTitle = "Cancel"
        vc.secondbtnTitle = "Pay"
        if showSaveCards{
            vc.id = viewModel.cards[primeCardIndex].id
        }
        vc.modalTransitionStyle = .coverVertical
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: false, completion: nil)
    }
    
    private func doPayment(_ id:String,isDefault:Bool = true){
        viewModel.paymnetIntent(room._id, paymentMethodId: id, amount: room.amount) { (paymentIntentParams) in
            let paymentHandler = STPPaymentHandler.shared()
            paymentHandler.confirmPayment(paymentIntentParams, with: self) { (status, paymentIntent, error) in
                printDebug(paymentIntent?.description ?? "")
                switch (status) {
                case .failed:
                    CommonFunctions.showToastWithMessage(error?.localizedDescription ?? "")
                    break
                case .canceled:
                    CommonFunctions.showToastWithMessage(error?.localizedDescription ?? "")
                    break
                case .succeeded:
                    guard let p = paymentIntent else { return }
                    self.viewModel.confirmPaymnet(p.stripeId, chatroomId: self.room._id, paymentMethodId: p.paymentMethodId ?? "",isDefault: isDefault) { [weak self] in
                        guard let self = self else { return }
                        DispatchQueue.main.async {
                            self.presentPaymnetSucess()
                        }
                    }
                    break
                @unknown default:
                    fatalError()
                    break
                }
            }
        }
    }
    
    private func saveCard(){
        viewModel.addCard { [weak self](setupIntentParams) in
            guard let self = self else  { return }
            let paymentHandler = STPPaymentHandler.shared()
            paymentHandler.confirmSetupIntent(setupIntentParams, with: self) { status, setupIntent, error in
                switch (status) {
                case .failed:
                    CommonFunctions.showToastWithMessage(error?.localizedDescription ?? "")
                    break
                case .canceled:
                    CommonFunctions.showToastWithMessage(error?.localizedDescription ?? "")
                    break
                case .succeeded:
                    self.doPayment(setupIntent?.paymentMethodID ?? "",isDefault: self.viewModel.cardModel?.isDefault ?? false)
                    break
                @unknown default:
                    fatalError()
                    break
                }
            }
        }
    }
    
    private func displayAlert(_ title:String? = nil, message:String, completion:@escaping()->()){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default) { (action) in
            completion()
        }
        alert.addAction(ok)
        present(alert, animated: false, completion: nil)
    }
    
    private func checkForValidatingCard(){
        if showAddCard{
            if (viewModel.cardHolderName.isEmpty || viewModel.cardNo.isEmpty || viewModel.cvv.isEmpty){
                enablePayBtn = false
            }else{
                enablePayBtn = true
            }
        }
    }
}

extension PaymentVC : UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            if showSaveCards{
                return 1 + viewModel.cards.count
            }else{
                return 1
            }
        }else{
            if showAddCard{
                return 2
            }else{
                return 1
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueCell(with: DropdownHeaderTVCell.self)
                cell.heading.text = "Saved Card"
                cell.isExpanded = showSaveCards
                return cell
            default:
                let cell = tableView.dequeueCell(with: CardListYVCell.self)
                cell.populateData(viewModel.cards[indexPath.row - 1], isActive: primeCardIndex == (indexPath.row - 1))
                cell.primeSelection = { [weak self] in
                    self?.primeCardIndex = indexPath.row - 1
                    self?.tableView.reloadData()
                }
                return cell
            }
        }else{
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueCell(with: DropdownHeaderTVCell.self)
                cell.heading.text = "Add Card"
                cell.isExpanded = showAddCard
                return cell
            default:
                let cell = tableView.dequeueCell(with: AddCardTVCell.self)
                cell.addCardTapped = { [weak self] cardModel in
                    guard let self = self else { return }
                    self.viewModel.cardModel = cardModel
                   self.checkForValidatingCard()
                }
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath == [0,0]{
            showSaveCards = !showSaveCards
            showAddCard = false
            tableView.reloadData()
        }else if indexPath == [1,0]{
            showAddCard = !showAddCard
            showSaveCards = false
            tableView.reloadData()
        }
    }
}


extension PaymentVC :  STPAuthenticationContext {
    func authenticationPresentingViewController() -> UIViewController {
        return self
    }
}


extension PaymentVC : PaymnetSucessDelagate {
    func okTapped() {
        pop()
    }
}


extension PaymentVC : GenericPopupDelegate {
    func optionTapped(_ flag: Bool, isDelete: Bool, id: String) {
        if showSaveCards{
            if flag{
                doPayment(id)
            }
        }else{
            saveCard()
        }
    }
 
}
