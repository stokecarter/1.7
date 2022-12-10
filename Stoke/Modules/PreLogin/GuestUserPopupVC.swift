//
//  GuestUserPopupVC.swift
//  Stoke
//
//  Created by Admin on 28/05/21.
//

import UIKit

class GuestUserPopupVC: BaseVC {

    @IBOutlet weak var bottomView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bottomView.roundCorner([.topLeft,.topRight], radius: 10)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        bottomView.roundCorner([.topLeft,.topRight], radius: 10)
    }
    
    @IBAction func dismissPopup(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func loginButtonTapped(_ sender: Any) {
        UserModel.main = UserModel()
        AppRouter.checkUserFlow()
    }
}
