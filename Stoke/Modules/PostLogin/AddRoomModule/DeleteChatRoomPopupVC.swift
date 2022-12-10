//
//  DeleteChatRoomPopupVC.swift
//  Stoke
//
//  Created by Admin on 22/03/21.
//

import UIKit

protocol DeleteChatRoomPopupDelegate:AnyObject {
    func deleteTapped(index:Int)
}

class DeleteChatRoomPopupVC: BaseVC {

    @IBOutlet weak var cancel: AppButton!
    @IBOutlet weak var delete: AppButton!

    @IBOutlet weak var iconGeight: NSLayoutConstraint!
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var subHeading: UILabel!
    
    var section:Int = 0
    var deleteTapped:(()->())?
    
    var hideDeleteBtn:Bool = false
    var showOkOnly:Bool = false
    
    
    weak var delegate: DeleteChatRoomPopupDelegate?
    var heading:String = "Delete Room?"
    var subheading:String = "Are you sure you want to delete this Room?"
    var deleteBtnTitle = "Delete"
    
    var isFromSignup:Bool = false
    var msg:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if hideDeleteBtn{
            iconGeight.constant = 100
            delete.isHidden = true
            cancel.setTitle("OK", for: .normal)
            cancel.btnType  = .themeColor
        }
        
        if showOkOnly{
            delete.isHidden = true
            cancel.setTitle("OK", for: .normal)
            cancel.btnType  = .themeColor
        }
    }
    
    override func initalSetup() {
        cancel.btnType = .whiteColor
        delete.btnType = .themeColor
    }
    
    override func setupFounts() {
        delete.setTitle(deleteBtnTitle, for: .normal)
        headingLabel.font = AppFonts.Medium.withSize(18)
        subHeading.font = AppFonts.Regular.withSize(16)
        subHeading.textColor = AppColors.labelColor
        headingLabel.text = heading
        subHeading.text = subheading
        
    }
    
    @IBAction func deleteTapped(_ sender: Any) {
        if let d = deleteTapped { d() }
        delegate?.deleteTapped(index: section)
        dismiss(animated: false, completion: nil)
    }
    @IBAction func canelTapped(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }

}
