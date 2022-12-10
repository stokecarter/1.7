//
//  SettingVC.swift
//  Stoke
//
//  Created by Admin on 11/05/21.
//

import UIKit

class SettingVC: BaseVC {

    @IBOutlet weak var tableView: UITableView!
    
    var user:UserProfileModel!
    
    var dataSource:[(String,UIImage)] = [("Change Password",#imageLiteral(resourceName: "ic_change_password")),
                                         ("Personal Information",#imageLiteral(resourceName: "ic_personal_information")),
                                         ("Notification Settings",#imageLiteral(resourceName: "ic_notification_settings")),
                                         ("My Profile URL",#imageLiteral(resourceName: "link")),
                                         ("My Payments",#imageLiteral(resourceName: "ic_my_payment")),
                                         ("My Cards",#imageLiteral(resourceName: "ic_add_card-1")),
                                         ("Blocked Users",#imageLiteral(resourceName: "block-user")),
                                         ("Feedback",#imageLiteral(resourceName: "ic_feedback")),
                                         ("Contact Us",#imageLiteral(resourceName: "ic_contact_us")),
                                         ("FAQs",#imageLiteral(resourceName: "ic_faq")),
                                         ("About",#imageLiteral(resourceName: "ic_about")),
                                         ("Rules",#imageLiteral(resourceName: "rules")),
                                         ("Delete Account",#imageLiteral(resourceName: "icDeleteAccount")),
                                         ("Logout",#imageLiteral(resourceName: "ic_logout"))]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar(title: "Settings", backButton: true)
        applyTransparentBackgroundToTheNavigationBar(100)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func handelNavigation(_ index:Int){
        switch index {
        case 0:
            let vc = ResetPasswordVC.instantiate(fromAppStoryboard: .Events)
            AppRouter.pushViewController(self, vc)
        case 1:
            let vc = PersonalInfoVC.instantiate(fromAppStoryboard: .Events)
            vc.model = self.user
            AppRouter.pushViewController(self, vc)
        case 2:
            let vc = NotificationSettingsVC.instantiate(fromAppStoryboard: .Events)
            AppRouter.pushViewController(self, vc)
        case 3:
            UIPasteboard.general.string = user.profileLink
            CommonFunctions.showToastWithMessage("Link copied.", theme: .success)
        case 4:
            let vc = MyPaymnetsVC.instantiate(fromAppStoryboard: .Chat)
            AppRouter.pushViewController(self, vc)
        case 5:
            let vc = MyCardsVC.instantiate(fromAppStoryboard: .Chat)
            AppRouter.pushViewController(self, vc)
        case 6:
            let vc = BlockUserVC.instantiate(fromAppStoryboard: .Home)
            AppRouter.pushViewController(self, vc)
        case 7:
            let vc = FeedbackVC.instantiate(fromAppStoryboard: .Events)
            AppRouter.pushViewController(self, vc)
        case 8:
            let vc = ContactUsVC.instantiate(fromAppStoryboard: .Events)
            vc.user = self.user
            AppRouter.pushViewController(self, vc)
        case 9:
            let vc = FAQVc.instantiate(fromAppStoryboard: .Events)
            AppRouter.pushViewController(self, vc)
        case 10:
            let vc = StaticPageOptionsVC.instantiate(fromAppStoryboard: .Events)
            AppRouter.pushViewController(self, vc)
        case 11:
            let vc = StaticWebKitVC.instantiate(fromAppStoryboard: .Events)
            vc.heading = "Rules"
            vc.type = .rules
            AppRouter.pushViewController(self, vc)
        case 12:
            //Delete account
            let vc = GenericPopupVC.instantiate(fromAppStoryboard: .Chat)
            vc.delegate = self
            vc.isForDelete = true
            vc.headingText = "Delete Account"
            vc.subheadingTxt = "This will permanently delete your account and data assocated with your account. There is no way to get this information back once you click the delete button below. Are you sure you would like to delete your account?"
            vc.firstbtnTitle = "Cancel"
            vc.secondbtnTitle = "Delete"
            vc.modalTransitionStyle = .coverVertical
            vc.modalPresentationStyle = .overFullScreen
            present(vc, animated: false, completion: nil)
        case 13:
            let vc = GenericPopupVC.instantiate(fromAppStoryboard: .Chat)
            vc.delegate = self
            vc.isForDelete = false
            vc.headingText = "Logout?"
            vc.subheadingTxt = "Are you sure you want to Logout?"
            vc.firstbtnTitle = "Cancel"
            vc.secondbtnTitle = "Logout"
            vc.modalTransitionStyle = .coverVertical
            vc.modalPresentationStyle = .overFullScreen
            present(vc, animated: false, completion: nil)
        default:
            CommonFunctions.showToastWithMessage("Under Development")
        }
    }

}

extension SettingVC : UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(with: SettingTVCell.self)
        cell.populate = dataSource[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        handelNavigation(indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0{
            if UserModel.main.registeredUsing == 1{
                return UITableView.automaticDimension
            }else{
                return CGFloat.leastNormalMagnitude
            }
        }else if indexPath.row == 4 || indexPath.row == 5{
            if !user.isPaymentDone{
                return CGFloat.leastNormalMagnitude
            }else{
                return UITableView.automaticDimension
            }
        }else{
            return UITableView.automaticDimension
        }
    }
}




class SettingTVCell: UITableViewCell{
    
    
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var copyIcon: UIImageView!
    @IBOutlet weak var heading: UILabel!
    
    var populate:(String,UIImage)? = nil{
        didSet{
            if let p = populate{
                icon.image = p.1
                heading.text = p.0
                copyIcon.isHidden = p.0 != "My Profile URL"
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        clipsToBounds = true
    }
    
    
}


extension SettingVC : GenericPopupDelegate {
    func optionTapped(_ flag: Bool, isDelete: Bool, id: String) {
        if isDelete && flag {
            //Delete and logout
            //Hit Delete Account API
            CommonFunctions.deleteAccount {
                StokeAnalytics.shared.resetAnalytics()
                AppRouter.checkUserFlow()
            }
        } else if flag {
            CommonFunctions.logoutUser {
                StokeAnalytics.shared.resetAnalytics()
                AppRouter.checkUserFlow()
            }
        }
    }
}
