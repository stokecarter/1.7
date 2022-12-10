//
//  ProfileHeaderVC.swift
//  Stoke
//
//  Created by Admin on 07/07/21.
//

import UIKit

class ProfileHeaderVC: BaseVC {

    
    @IBOutlet weak var contentView: UIView!
    var getheight:((CGFloat)->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let size = contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        if let height = getheight {
            height(size.height)
        }
    }
    

}
