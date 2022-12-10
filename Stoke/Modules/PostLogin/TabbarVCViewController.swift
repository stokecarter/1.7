//
//  TabbarVCViewController.swift
//  Stoke
//
//  Created by Admin on 25/02/21.
//

import UIKit

class TabbarVC: UITabBarController {
        
    var isNewNotification:Int? = nil{
        didSet{
            if let c = isNewNotification{
                tabBar.items?[3].selectedImage = #imageLiteral(resourceName: "ic-notification-active")
                if c > 9{
                    tabBar.items?[3].badgeValue = "9+"
                }else{
                    tabBar.items?[3].badgeValue = "\(c)"
                }
                tabBar.items?[3].badgeColor = AppColors.themeColor
                for tabBarButton in self.tabBar.subviews{
                        for badgeView in tabBarButton.subviews{
                        let className = NSStringFromClass(badgeView.classForCoder)
                            if  className == "_UIBadgeView"
                            {
                                badgeView.layer.transform = CATransform3DIdentity
                                badgeView.layer.transform = CATransform3DMakeTranslation(-8, 1, 1.0)
                                badgeView.borderWidth = 1
                                badgeView.borderColor = .white
                                badgeView.cornerRadius = badgeView.bounds.height/2
                            }
                        }
                    }
            }else{
                tabBar.items?[3].selectedImage = #imageLiteral(resourceName: "ic-notification-active")
                tabBar.items?[3].badgeValue = nil
            }
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.backgroundColor = AppColors.tabBarBackgroundColor
        tabBar.tintColor = AppColors.themeColor
        
        tabBar.layer.borderWidth = 0.24
        tabBar.layer.borderColor = AppColors.labelColor.cgColor
        tabBar.clipsToBounds = false
        
        delegate = self
        applyTransparentBackgroundToTheNavigationBar(100)
        manageNavigationBarTitle()
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        CommonFunctions.updateRibbonLogic()

    }
    
    
    final func applyTransparentBackgroundToTheNavigationBar(_ opacity: CGFloat) {
        guard let navController = self.navigationController else {return}
        var transparentBackground: UIImage
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 1, height: 1),
                                               false,
                                               navController.navigationBar.layer.contentsScale)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(red: 1, green: 1, blue: 1, alpha: opacity)
        UIRectFill(CGRect(x: 0, y: 0, width: 1, height: 1))
        transparentBackground = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        let navigationBarAppearance = self.navigationController!.navigationBar
        navigationBarAppearance.setBackgroundImage(transparentBackground, for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.barTintColor = .white
    }
    
    private func manageNavigationBarTitle(index:Int = 0){
        NotificationCenter.default.post(name: NSNotification.Name.scrollTotop, object: nil)
//        switch index {
//        case 0:
//            NotificationCenter.default.post(name: NSNotification.Name.scrollTotop, object: nil)
//        default:
//            printDebug("Do nothing")
//        }
    }
    
}


extension TabbarVC : UITabBarControllerDelegate {
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if let index = tabBar.items?.firstIndex(of: item){
            manageNavigationBarTitle(index: index)
        }
    }
}


extension NSNotification.Name{
    static let scrollTotop = NSNotification.Name("scrollToTop")
//    static let reconnectChat = NSNotification.Name("reconnectChat")
}
