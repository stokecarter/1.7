//
//  StaticPageOptionsVC.swift
//  Stoke
//
//  Created by Admin on 18/05/21.
//

import UIKit

class StaticPageOptionsVC: BaseVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar(title: "About", backButton: true)
    }
    
    @IBAction func tncTapped(_ sender: Any) {
        let vc = StaticWebKitVC.instantiate(fromAppStoryboard: .Events)
        vc.heading = "Terms of Service"
        vc.type = .tnc
        AppRouter.pushViewController(self, vc)
    }
    
    @IBAction func aboutUsTapped(_ sender: Any) {
        let vc = StaticWebKitVC.instantiate(fromAppStoryboard: .Events)
        vc.heading = "Privacy Policy"
        vc.type = .pvc
        AppRouter.pushViewController(self, vc)
    }
    
}
