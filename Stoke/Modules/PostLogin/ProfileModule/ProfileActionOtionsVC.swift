//
//  ProfileActionOtionsVC.swift
//  Stoke
//
//  Created by Admin on 18/05/21.
//

import UIKit

protocol ProfileActionOtionsDelegate:AnyObject {
    func getSelectedOption(_ index:Int)
}


class ProfileActionOtionsVC: BaseVC {
    
    
    @IBOutlet weak var bgView: UIView!
    
    weak var delegate:ProfileActionOtionsDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        bgView.roundCorner([.topLeft,.topRight], radius: 20)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        bgView.roundCorner([.topLeft,.topRight], radius: 20)
    }
    
    @IBAction func dismissView(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func blockTapped(_ sender: Any) {
        dismiss(animated: false) { [weak self] in
            self?.delegate?.getSelectedOption(0)
        }
    }
    
    @IBAction func reportTapped(_ sender: Any) {
        dismiss(animated: false) { [weak self] in
            self?.delegate?.getSelectedOption(1)
        }
    }
    
    @IBAction func copyProfileUrl(_ sender: Any) {
        dismiss(animated: false) { [weak self] in
            self?.delegate?.getSelectedOption(2)
        }
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
}
