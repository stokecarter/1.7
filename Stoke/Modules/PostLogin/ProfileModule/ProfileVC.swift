//
//  ProfileVC.swift
//  Stoke
//
//  Created by Admin on 18/03/21.
//

import UIKit

class ProfileVC: BaseVC {

    @IBOutlet weak var guestUserView: UIView!
    @IBOutlet weak var thumbIcon: UIImageView!
    @IBOutlet weak var thumbMessage: UILabel!
    @IBOutlet weak var logoutBtn: AppButton!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var noInternetViewHeight:NSLayoutConstraint!
    
    
    var defaultHeight:CGFloat = 0.0
    var scrollViewContentHeight:CGFloat = 0
    var screenHeight = UIScreen.main.bounds.height
    var refresh = UIRefreshControl()
    var isFromOutside = false
    var viewModel:UserProfileVM!
    var isInnerViewScrolling = true
    var lastContentOffset: CGFloat = 0
    
    var isInternetAvilabel:Bool = true{
        didSet{
            if isInternetAvilabel{
                noInternetViewHeight.constant = CGFloat.leastNormalMagnitude
            }else{
                noInternetViewHeight.constant = 25
                if let v = viewModel{
                    v.fetchOfflineData()
                }
            }
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        isInternetAvilabel = AppNetworkDetector.sharedInstance.isIntenetOk
        StokeAnalytics.shared.setScreenVisitEvent(.visitMyProfile)
        setupView()
        applyTransparentBackgroundToTheNavigationBar(100)
        defaultHeight = tableview.height
        if !CommonFunctions.isGuestLogin && !UserModel.main.isAdmin{
            viewModel = UserProfileVM(NetworkLayer())
            viewModel.notify = { [weak self] in
                let t = (self?.viewModel.model.fullName.byRemovingLeadingTrailingWhiteSpaces ?? "").isEmpty ? "Profile" : (self?.viewModel.model.fullName.byRemovingLeadingTrailingWhiteSpaces ?? "")
                self?.setNavigationBar(title: t, backButton: true, backButtonImage: UIImage(named: "ic_add_user"), showTextOnRightBtn: nil)
                self?.tableview.reloadData()
                self?.checkForScrolling()
            }
            if isFromOutside{
                setNavigationBar(title: "Profile", backButton: true, backButtonImage: UIImage(named: "ic_add_user"), showTextOnRightBtn: nil)
            }else{
                setNavigationBar(title: "Profile", backButton: true, backButtonImage: UIImage(named: "ic_add_user"), showTextOnRightBtn: nil)
                addRightButtonToNavigation(image: #imageLiteral(resourceName: "more-1"))
            }
        }
        refresh.addTarget(self, action: #selector(pullToRefresh(_:)), for: .valueChanged)
        tableview.refreshControl = refresh
    }
    
    @objc func pullToRefresh(_ sender:UIRefreshControl){
        sender.endRefreshing()
        viewModel.getProfile()
        viewModel.getSavedCommnets()
        viewModel.getSavedTaggs()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(scrollToTop), name: .scrollTotop, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handelInternetStatus(_:)), name: .internetUpdate, object: nil)
        super.viewWillAppear(animated)
        if let _ = viewModel{
            viewModel.getProfile()
            viewModel.getSavedCommnets()
            viewModel.getSavedTaggs()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: .scrollTotop, object: nil)
        NotificationCenter.default.removeObserver(self, name: .internetUpdate, object: nil)
    }
    
    override func initalSetup() {
        tableview.delegate = self
        tableview.dataSource = self
        tableview.registerCell(with: ProfileHeaderTVCell.self)
        tableview.registerCell(with: TwoTabsProfileTVCell.self)
        tableview.registerCell(with: ThreeTabsProfileTVCell.self)
    }
    
    @IBAction func logoutTapped(_ sender: Any) {
        CommonFunctions.logoutUser {
            AppRouter.checkUserFlow()
        }
    }
    
//    @IBAction func guestuserTapped(_ sender: Any) {
////        UserModel.main = UserModel()
////        AppRouter.checkUserFlow()
//    }
    override func backButtonTapped() {
        let items = [URL(string: "https://apps.apple.com/us/app/stoke-live-tv-chat/id1575928622")!]
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(ac, animated: true)
    }
    
    override func rightBarButtonTapped(_ sender: UIButton) {
        let vc = SettingVC.instantiate(fromAppStoryboard: .Chat)
        vc.user = viewModel.model
        AppRouter.pushViewController(self, vc)
    }
    
    @objc func scrollToTop() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            if let _ = self?.viewModel{
                self?.tableview.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            }
        }
    }
    
    private func openEditProfile(){
        let vc = EditProfileVC.instantiate(fromAppStoryboard: .Home)
        vc.model = viewModel.model
        AppRouter.pushFromTabbar(vc)
    }
    
    private func showFollowers(_ flag:Bool){
        let vc = FollowFollowingVC.instantiate(fromAppStoryboard: .Home)
        vc.userName = viewModel.model.userName
        vc.showFollowers = flag
        vc.userId = viewModel.model._id
        AppRouter.pushViewController(self, vc)
    }
    
    private func presentTwoOptionsBtn(_ section:Int){
        CommonFunctions.vaibratePhone()
        let vc = TwoBtnPopup.instantiate(fromAppStoryboard: .Home)
        vc.btn1Title = "Remove"
        vc.btn2Title = "Cancel"
        vc.section = section
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .coverVertical
        vc.delagate = self
        present(vc, animated: false, completion: nil)
    }
    
    private func presentPopupView(){
        let vc = RoomCreatedSuccessVC.instantiate(fromAppStoryboard: .Events)
        vc.delegate = self
        vc.heading = "Tag Remove Successful"
        vc.okBtntitle = "OK"
        vc.subheading = "You have successfully removed the tag from your account. You can still search and save the tag from the Discover Section"
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: false, completion: nil)
    }
    
    private func setupView(){
        if CommonFunctions.isGuestLogin{
            guestUserView.isHidden = false
            thumbIcon.image = #imageLiteral(resourceName: "ic_signup_login")
            thumbMessage.text = "You must be logged in to view this page"
            logoutBtn.setTitle("Log In / Sign Up", for: .normal)
        }else if UserModel.main.isAdmin{
            guestUserView.isHidden = false
            thumbIcon.image = #imageLiteral(resourceName: "ic_signup_login")
            thumbMessage.text = "You are login as a Stoke"
            logoutBtn.setTitle("Logout", for: .normal)
            setNavigationBar(title: UserModel.main.fullName, backButton: true, backButtonImage: UIImage(named: "ic_add_user"), showTextOnRightBtn: nil)
        }else{
            guestUserView.isHidden = true
        }
    }
    
    
    private func checkForScrolling(){
        guard let cell = tableview.cellForRow(at: IndexPath(row: 1, section: 0)) as? TwoTabsProfileTVCell else { return }
        let outerY = Int(tableview.contentOffset.y)
        let innerY = Int(tableview.rectForRow(at: IndexPath(row: 1, section: 0)).minY - 1)
        if outerY >= innerY{
            cell.saveCommnetsTV.isScrollEnabled = true
            cell.tagsCV.isScrollEnabled = true
        }else{
            cell.saveCommnetsTV.isScrollEnabled = false
            cell.tagsCV.isScrollEnabled = false
        }
       
    }
    
    @objc func handelInternetStatus(_ sender:NSNotification){
        if let dict =  sender.object as? [String:Bool]{
            if let status = dict["status"]{
                isInternetAvilabel = status
            }
        }
    }
}

extension ProfileVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel != nil ? 2 : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0{
            let cell = tableView.dequeueCell(with: ProfileHeaderTVCell.self)
            cell.populateCell(viewModel.model)
            cell.buttonTapped = { [weak self] in
                self?.openEditProfile()
            }
            cell.showFollowers = { [weak self] flag in
                self?.showFollowers(flag)
            }
            return cell
        }else{
            let cell = tableView.dequeueCell(with: TwoTabsProfileTVCell.self)
            cell.populateCommnetCell(viewModel.savedCommnets)
            cell.populateTags(viewModel.savedTags)
            cell.selectionMade = { [weak self] selection in
                self?.tableview.beginUpdates()
                self?.viewModel.currentSection = selection
                self?.tableview.endUpdates()
            }
            cell.tapedOnCommnet = { [weak self] index in
                self?.presentTwoOptionsBtn(index)
            }
            cell.tapOnTags = { [weak self] in
                self?.presentPopupView()
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 1{
            if viewModel.currentSection == .savedCommnets{
                return self.tableview.height
            }else{
                return self.tableview.height
            }
        }else{
            return UITableView.automaticDimension
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        checkForScrolling()
    }
}

extension ProfileVC : ThreeBtnPopupDelegate {
    func getUserChoice(_ index: Int, section: Int) {
        if index == 0{
            let vc = GenericPopupVC.instantiate(fromAppStoryboard: .Chat)
            vc.delegate = self
            vc.isForDelete = true
            vc.headingText = ""
            vc.subheadingTxt = "Are you sure you want to remove comment?"
            vc.firstbtnTitle = "Cancel"
            vc.secondbtnTitle = "Remove"
            vc.id = viewModel.savedCommnets[section]._id
            vc.modalTransitionStyle = .coverVertical
            vc.modalPresentationStyle = .overFullScreen
            present(vc, animated: false, completion: nil)
        }
        
    }
}

extension ProfileVC : SignupSucessDelegate {
    func okTapped() {
        viewModel.getSavedTaggs()
    }
}


extension ProfileVC : GenericPopupDelegate{
    
    func optionTapped(_ flag: Bool, isDelete: Bool, id: String) {
        if flag{
            viewModel.unsavedCommnet(id)
        }
    }
}


