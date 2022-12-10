//
//  BaseVC.swift
//  Stoke
//
//  Created by Admin on 25/02/21.
//

import UIKit

class BaseVC: UIViewController {

    
    var rightButton: UIButton?
    var leftButton:UIBarButtonItem?
    override func viewDidLoad() {
        super.viewDidLoad()
        initalSetup()
        setupFounts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    func initalSetup(){
        
    }
    
    func setupFounts(){
        
    }
    
    
    final func setWhiteNavigationBar(title: String = "", backButton : Bool = true, backButtonImage: UIImage? = #imageLiteral(resourceName: "icBack"), showTextOnRightBtn:String? = nil) {
        //self.navigationItem.title = title
        self.navigationController?.navigationBar.backgroundColor = .clear
        let titleFont = AppFonts.Bold.withSize(23)
        let _title = title
        let titleSize = _title.size(withAttributes: [.font: titleFont])

        let frame = CGRect(x: 0, y: 0, width: titleSize.width, height: 20.0)
        let titleLabel = UILabel(frame: frame)
        titleLabel.font = titleFont
        titleLabel.textColor = AppColors.whiteColor
        titleLabel.textAlignment = .center
        titleLabel.text = title
        navigationItem.titleView = titleLabel
        navigationController?.setNavigationBarHidden(false, animated: true)
        self.applyTransparentBackgroundToTheNavigationBar(0)
        if backButton{
            let leftButton : UIBarButtonItem = UIBarButtonItem(image: backButtonImage, style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.backButtonTapped))
            leftButton.imageInsets = UIEdgeInsets(top: 0, left: -3, bottom: 0, right: 0)
            leftButton.tintColor = AppColors.themeColor
            navigationItem.leftBarButtonItem = leftButton
        }else{
            navigationItem.setHidesBackButton(true, animated: true)
        }
        if let t = showTextOnRightBtn{
            let button = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
            button.setTitle(t, for: .normal)
            button.titleLabel?.font = AppFonts.Semibold.withSize(14)
            button.setTitleColor(#colorLiteral(red: 0.4666666667, green: 0.4666666667, blue: 0.4666666667, alpha: 1), for: .normal)
            let rightButton: UIBarButtonItem = UIBarButtonItem(customView: button)
            navigationItem.rightBarButtonItem = rightButton
        }
        self.navigationController?.navigationBar.shadowImage = UIImage()

    }
    @objc func handelTapOnHeader(){
        
    }
    
    final func setNavigationBar(title: String = "", backButton : Bool = true, backButtonImage: UIImage? = #imageLiteral(resourceName: "icBack"), showTextOnRightBtn:String? = nil) {
        //self.navigationItem.title = title
        self.navigationController?.navigationBar.backgroundColor = .clear
        let titleFont = AppFonts.Semibold.withSize(18)
        let _title = title
        let titleSize = _title.size(withAttributes: [.font: titleFont])
        let frame = CGRect(x: 0, y: 0, width: titleSize.width, height: 20.0)
        let titleLabel = UILabel(frame: frame)
        titleLabel.font = titleFont
        titleLabel.textColor = .black
        titleLabel.textAlignment = .center
        titleLabel.text = title
        navigationItem.titleView = titleLabel
        navigationController?.setNavigationBarHidden(false, animated: true)
        self.applyTransparentBackgroundToTheNavigationBar(0)
        if backButton{
            leftButton = UIBarButtonItem(image: backButtonImage, style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.backButtonTapped))
            leftButton?.imageInsets = UIEdgeInsets(top: 0, left: -3, bottom: 0, right: 0)
            leftButton?.tintColor = AppColors.themeColor
            navigationItem.leftBarButtonItem = leftButton
        }else{
            navigationItem.setHidesBackButton(true, animated: true)
        }
        if let t = showTextOnRightBtn{
            let button = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
            button.setTitle(t, for: .normal)
            button.titleLabel?.font = AppFonts.Semibold.withSize(14)
            button.setTitleColor(#colorLiteral(red: 0.4666666667, green: 0.4666666667, blue: 0.4666666667, alpha: 1), for: .normal)
            let rightButton: UIBarButtonItem = UIBarButtonItem(customView: button)
            navigationItem.rightBarButtonItem = rightButton
        }
        self.navigationController?.navigationBar.shadowImage = UIImage()

    }
    func addRightButtonToNavigation(image: UIImage? = #imageLiteral(resourceName: "ic_sort"), title:String? = nil){
        rightButton = UIButton(type: .custom)
        rightButton?.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        if let image = image{
            rightButton?.setImage(image, for: .normal)
        }
        if let text = title{
            rightButton?.setTitle(text, for: .normal)
            rightButton?.titleLabel?.font = AppFonts.Medium.withSize(14)
            rightButton?.setTitleColor(AppColors.themeColor, for: .normal)
            rightButton?.setImage(UIImage(), for: .normal)
        }
        rightButton?.addTarget(self, action: #selector(rightBarButtonTapped(_:)), for: .touchUpInside)
        let rightBarButton = UIBarButtonItem(customView: rightButton!)
        navigationItem.rightBarButtonItem = rightBarButton
    }
    
    func showRightBtn(){
        if let b = rightButton{
            b.isHidden = false
        }
    }
    func hideRightBtn(){
        if let b = rightButton{
            b.isHidden = true
        }
    }
    
    @objc func rightBarButtonTapped(_ sender: UIButton){
        
    }
    
    @objc func backButtonTapped(){
        pop()
    }
    final func applyTransparentBackgroundToTheNavigationBar(_ opacity: CGFloat) {
        guard let navController = self.navigationController else {return}
        
        
        var transparentBackground: UIImage
        
        /*    The background of a navigation bar switches from being translucent
         to transparent when a background image is applied. The intensity of
         the background image's alpha channel is inversely related to the
         transparency of the bar. That is, a smaller alpha channel intensity
         results in a more transparent bar and vis-versa.
         
         Below, a background image is dynamically generated with the desired opacity.
         */
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 1, height: 1),
                                               false,
                                               navController.navigationBar.layer.contentsScale)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(red: 1, green: 1, blue: 1, alpha: opacity)
        UIRectFill(CGRect(x: 0, y: 0, width: 1, height: 1))
        transparentBackground = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        /*    You should use the appearance proxy to customize the appearance of
         UIKit elements. However changes made to an element's appearance
         proxy do not effect any existing instances of that element currently
         in the view hierarchy. Normally this is not an issue because you
         will likely be performing your appearance customizations in
         -application:didFinishLaunchingWithOptions:. However, this example
         allows you to toggle between appearances at runtime which necessitates
         applying appearance customizations directly to the navigation bar.
         */
        //let navigationBarAppearance =
        //      UINavigationBar.appearance(whenContainedInInstancesOf: [UINavigationController.self])
        let navigationBarAppearance = self.navigationController!.navigationBar
        navigationBarAppearance.setBackgroundImage(transparentBackground, for: .default)
    }
    

}

extension BaseVC:UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
