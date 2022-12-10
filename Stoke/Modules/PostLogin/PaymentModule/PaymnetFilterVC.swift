//
//  PaymnetFilterVC.swift
//  Stoke
//
//  Created by Admin on 12/05/21.
//

import UIKit

protocol PaymnetFilterDelegate:AnyObject {
    func getFilterData(_ fDate:Date?, toDate:Date?, amount:Double?)
    func clearFilter()
}

class PaymnetFilterVC: BaseVC {
    
    
    @IBOutlet weak var fromTF: AppTextField!
    @IBOutlet weak var toTf: AppTextField!
    @IBOutlet weak var amountSlider: UISlider!
    @IBOutlet weak var saveBtn: AppButton!
    @IBOutlet weak var cancelBtn: AppButton!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var amountLabel: UILabel!
    
    weak var delegate:PaymnetFilterDelegate?
    var fromDt: Date?
    var toDate:Date?
    var amount:Double = 200
    var isFresh = true
    
    var enableApplyBtn:Bool = false{
        didSet{
            if enableApplyBtn{
                saveBtn.alpha = 1
                saveBtn.isUserInteractionEnabled = true
            }else{
                saveBtn.alpha = 0.6
                saveBtn.isUserInteractionEnabled = false
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if !isFresh{
            amountSlider.setValue(Float(amount), animated: true)
            amountLabel.text = "$\(Int(amount))"
            if let d = fromDt{
                fromTF.text = d.toString(dateFormat: "dd/MM/yyyy")
            }
            if let d = toDate{
                toTf.text = d.toString(dateFormat: "dd/MM/yyyy")
            }
            enableApplyBtn = true
        }else{
            enableApplyBtn = true
        }
        amountSlider.minimumValue = 0
        amountSlider.maximumValue = 200
        bgView.roundCorner([.topLeft,.topRight], radius: 20)
        fromTF.placeholder = "dd/mm/yyyy"
        toTf.placeholder = "dd/mm/yyyy"
        fromTF.textRightPadding = 10
        toTf.textRightPadding = 10
        fromTF.setIconOnRight(#imageLiteral(resourceName: "ic-calendar"))
        toTf.setIconOnRight(#imageLiteral(resourceName: "ic-calendar"))
        fromTF.createDatePicker(start: nil, end: Date(), current: Date()) { (date) in
            self.fromTF.text = date.toString(dateFormat: "dd/MM/yyyy")
            self.fromDt = date
            self.setUpToTF()
            self.toTf.isUserInteractionEnabled = true
        }
        fromTF.textLeftPadding = 10
        toTf.textLeftPadding = 10
        toTf.isUserInteractionEnabled = false
        cancelBtn.btnType = .whiteColor
    }
    
    func setUpToTF(){
        toTf.inputView = nil
        toTf.createDatePicker(start: fromDt , end: Date(), current: Date()) { (date) in
            self.toTf.text = date.toString(dateFormat: "dd/MM/yyyy")
            self.toDate = date
            self.enableApplyBtn = true
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        bgView.roundCorner([.topLeft,.topRight], radius: 20)
    }
    
    @IBAction func didChangeSlider(_ sender: UISlider) {
        amountLabel.text = "$\(Int(sender.value))"
        amount = Double(sender.value)
    }
    
    @IBAction func clearAllTapped(_ sender: Any) {
        dismiss(animated: false) { [weak self] in
            self?.delegate?.clearFilter()
        }
    }
    
    @IBAction func canceltapped(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func saveTapped(_ sender: Any) {
        if toDate == nil && fromDt != nil{
            CommonFunctions.showToastWithMessage("Please select all fields")
            return
        }else{
            self.dismiss(animated: false) { [weak self] in
                self?.delegate?.getFilterData(self?.fromDt, toDate: self?.toDate, amount: self?.amount)
            }
        }
    }
    
}
