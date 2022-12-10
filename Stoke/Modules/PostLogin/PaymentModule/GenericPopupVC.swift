//
//  GenericPopupVC.swift
//  Stoke
//
//  Created by Admin on 12/05/21.
//

import UIKit

protocol GenericPopupDelegate:AnyObject {
    func optionTapped(_ flag:Bool, isDelete:Bool,id:String)
}

class GenericPopupVC: BaseVC {

    @IBOutlet weak var heading: UILabel!
    @IBOutlet weak var subHeading: UILabel!
    @IBOutlet weak var firstBtn: AppButton!
    @IBOutlet weak var seconBtn: AppButton!
    
    weak var delegate:GenericPopupDelegate?
    var isForDelete:Bool = false
    var headingText = ""
    var subheadingTxt = ""
    var firstbtnTitle = ""
    var secondbtnTitle = ""
    var id:String = ""
    var callback:(()->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        heading.text = headingText
        subHeading.text = subheadingTxt
        firstBtn.btnType = .whiteColor
        seconBtn.btnType = .themeColor
        firstBtn.setTitle(firstbtnTitle, for: .normal)
        seconBtn.setTitle(secondbtnTitle, for: .normal)

    }
    
    @IBAction func firstBtnTapped(_ sender: Any) {
        dismiss(animated: false) { [weak self] in
            self?.delegate?.optionTapped(false,isDelete:self?.isForDelete ?? false,id: self?.id ?? "")
        }
        
    }
    
    @IBAction func secondBtnTapped(_ sender: Any) {
        dismiss(animated: false) { [weak self] in
            if let call = self?.callback{ call() }
            self?.delegate?.optionTapped(true,isDelete:self?.isForDelete ?? false,id: self?.id ?? "")
        }
        
    }
    
}
