//
//  PaymnetSucessVC.swift
//  Stoke
//
//  Created by Admin on 12/05/21.
//

import UIKit

protocol PaymnetSucessDelagate:AnyObject {
    func okTapped()
}

class PaymnetSucessVC: BaseVC {

    
    weak var delegate: PaymnetSucessDelagate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func okBtnTapped(_ sender: Any) {
        dismiss(animated: false) { [weak self] in
            self?.delegate?.okTapped()
        }
        
    }
    
}
