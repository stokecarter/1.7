//
//  ChatRoomVC.swift
//  Stoke
//
//  Created by Admin on 19/04/21.
//

import UIKit
import IQKeyboardManagerSwift

class ChatRoomVC: BaseVC {
    
    @IBOutlet weak var seeNewCommnetBtn: AppButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var trendingTV: UITableView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var trendingView: UIView!
    @IBOutlet weak var allBtn: UIButton!
    @IBOutlet weak var followingBtn: UIButton!
    @IBOutlet weak var myBtn: UIButton!
    @IBOutlet weak var trendingTitle: UILabel!
    @IBOutlet weak var commnetTFViewHeight: NSLayoutConstraint!
    @IBOutlet weak var guestuserView: UIView!
    @IBOutlet weak var guestuserMsgLabel: UILabel!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var guestBtn: AppButton!
    @IBOutlet weak var tumbIcon: UIImageView!
    @IBOutlet weak var noInternetViewHeight: NSLayoutConstraint!
    
    var isInternetAvilabel: Bool = true {
        didSet {
            if isInternetAvilabel {
                noInternetViewHeight.constant = CGFloat.leastNormalMagnitude
            } else {
                noInternetViewHeight.constant = 25
            }
        }
    }
    
    var timer:Timer!
    
    var is5MinWarningshown:Bool = false
    
    var isDeletePopup = false
    
    
    var isPopupShown:Bool = false{
        didSet{
            popupView.isHidden = !isPopupShown
        }
    }
    
    var enableSendBtn:Bool = false{
        didSet{
            if enableSendBtn{
                sendBtn.alpha = 1.0
                sendBtn.isUserInteractionEnabled = true
            }else{
                sendBtn.alpha = 0.6
                sendBtn.isUserInteractionEnabled = false
            }
        }
    }
    
    var showTrending:Bool = false{
        didSet{
            if showTrending{
                self.navigationItem.leftBarButtonItem = nil
                self.navigationItem.setHidesBackButton(true, animated: false)
            }else{
                self.navigationItem.setHidesBackButton(true, animated: false)
                self.navigationItem.leftBarButtonItem = leftButton
            }
            trendingView.isHidden = !showTrending
        }
    }
    
    var chatRefresh = UIRefreshControl()
    var trendingRFefresh = UIRefreshControl()
    
    var viewModel:ChatRoomVM!
    var room:ChatRoom?
    var navButton:UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        NotificationCenter.default.addObserver(self, selector: #selector(reconnectChatRoom), name: .reconnectChat, object: nil)
        
        textView.font = AppFonts.Regular.withSize(14)
        guestBtn.setTitle("Log In / Sign Up", for: .normal)
        popupView.isHidden = true
        popupView.drawShadow(shadowColor: #colorLiteral(red: 0.368627451, green: 0.368627451, blue: 0.368627451, alpha: 0.35), shadowOpacity: 6, shadowRadius: 4, cornerRadius: 8, offset: CGSize.zero)
        userImageView.setImageWithIndicator(with: URL(string: AppUserDefaults.value(forKey: .profilePicture).stringValue), placeholderImage: #imageLiteral(resourceName: "ic-profile-placeholder"))
        userImageView.contentMode = .scaleToFill
        userImageView.roundCorners()
        userImageView.clipsToBounds = true
        enableSendBtn = false
        textView.text = "Comment..."
        textView.textColor = UIColor.lightGray
        viewModel = ChatRoomVM(NetworkLayer(), roomId: room?._id ?? "")
        textView.delegate = self
        view.layoutSubviews()
//        manageSelectedState(allBtn)
        if CommonFunctions.isGuestLogin || UserModel.main.isAdmin{
            commnetTFViewHeight.constant = CGFloat.leastNormalMagnitude
            guestuserView.isHidden = true
        }
        isInternetAvilabel = AppNetworkDetector.sharedInstance.isIntenetOk
        viewModel.reloadForNewComments = { [weak self] in
            guard let self = self else { return }
            
            let margin = self.view.height - self.tableView.height
            let height = self.tableView.frame.size.height
            let contentYoffset = self.tableView.contentOffset.y
            let distanceFromBottom = self.tableView.contentSize.height - contentYoffset - margin
            if distanceFromBottom < height {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.tableView.scrollToRow(at: IndexPath(row: 0, section: self.viewModel.dataSource.data.count - 1), at: .top, animated: true)
                }
                
            } else {
                self.seeNewCommnetBtn.isHidden = false
            }
            self.reload(table: self.tableView)
            
//            self.tableView.reloadData()
            
            
//            let cSize = Int(self.tableView.contentSize.height)
//            let y = Int(self.tableView.contentOffset.y)
//            let height = Int(self.tableView.bounds.height)
//            if (cSize - (y + height) > 200){
//                self.seeNewCommnetBtn.isHidden = false
//            }else if self.viewModel.currentPage == 1{
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//                    self.tableView.scrollToRow(at: IndexPath(row: 0, section: self.viewModel.dataSource.data.count - 1), at: .top, animated: true)
//                }
//            }else{
//
//            }
            
            
            
//            let y = Int(self.tableView.contentOffset.y + 2*self.tableView.bounds.height)
//            let yMax = Int(self.tableView.contentSize.height)
//
//
//
//            printDebug(Int(self.tableView.contentOffset.y))
//            printDebug(2*self.tableView.bounds.height)
//            printDebug("Y ===== \(y) \n\n\n")
//            printDebug("yMax ===== \(yMax) \n\n\n")
//            if y < yMax || self.viewModel.currentPage == 1{
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//                    self.tableView.scrollToRow(at: IndexPath(row: 0, section: self.viewModel.dataSource.data.count - 1), at: .top, animated: true)
//                }
//            }
        }
        
        viewModel.reloadToPreviousIndex = { [weak self] val in
            guard let self = self, val > 1 else { return }
            self.reload(table: self.tableView)
            //            self.tableView.reloadData()
            self.tableView.scrollToRow(at: IndexPath(row: 0, section: val), at: .top, animated: false)
            //            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            //                guard let self = self else { return }
            //                guard !self.viewModel.dataSource.data.isEmpty else { return }
            //
            //                }
        }
        
        
        viewModel.reload = { [weak self] val in
            guard let self = self else { return }
            self.tableView.isScrollEnabled = true
            if let i = val{
                self.tableView.reloadRows(at: [IndexPath(row: 0, section: i),IndexPath(row: 1, section: i),IndexPath(row: 2, section: i)], with: .fade)
            }else{
                self.reload(table: self.tableView)
//                self.tableView.reloadData()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                    guard let self = self else { return }
                    if self.viewModel.currentPage != 1{
                        printDebug("Do nothing....")
                    }else{
                        guard !self.viewModel.dataSource.data.isEmpty else { return }
                        self.tableView.scrollToRow(at: IndexPath(row: 0, section: self.viewModel.dataSource.data.count - 1), at: .top, animated: true)
                    }
                }
            }            
        }
        viewModel.scrollToMyCommnet = { [weak self] in
            guard let self = self else { return }
            self.reload(table: self.tableView)
//            self?.tableView.reloadData()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//                    guard let self = self else { return }
                    guard !self.viewModel.dataSource.data.isEmpty else { return }
                    self.tableView.scrollToRow(at: IndexPath(row: 0, section: self.viewModel.dataSource.data.count - 1), at: .top, animated: true)
                }
        }
        textView.layoutSubviews()
        viewModel.popOutUser = { [weak self] msg in
            let alert = UIAlertController(title: "Alert", message: msg, preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default) { (action) in
                self?.pop()
            }
            alert.addAction(ok)
            self?.present(alert, animated: true, completion: nil)
            
        }
        viewModel.exitFromRoom = { [weak self] msg in
            let alert = UIAlertController(title: "Alert", message: msg, preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default) { (action) in
                self?.pop()
            }
            alert.addAction(ok)
            self?.present(alert, animated: true, completion: nil)
        }
        viewModel.reloadTrending = { [weak self] in
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//                guard let self = self else { return }
//                guard !self.viewModel.trending.data.isEmpty else { return }
//                self.trendingTV.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
//            }
            self?.setupEmptyScreens()
            self?.trendingTV.reloadData()
            
        }
        viewModel.notifyNewComment = { [weak self] in
            guard let self = self else { return }
            let cSize = Int(self.tableView.contentSize.height)
            let y = Int(self.tableView.contentOffset.y)
            let height = Int(self.tableView.bounds.height)
            if (cSize - (y + height) > 200){
                self.seeNewCommnetBtn.isHidden = false
            }
        }
        seeNewCommnetBtn.btnType = .themeRound
        addRightButtonToNavigation(image: #imageLiteral(resourceName: "more-1"))
        tableView.emptyDataSetView { view in
            view.titleLabelString(NSAttributedString(string: "\n\nStart The Conversation!", attributes: [NSAttributedString.Key.font:AppFonts.Semibold.withSize(16),NSAttributedString.Key.foregroundColor:UIColor.black]))
                .image(#imageLiteral(resourceName: "ic-no-chatroom"))
                .didTapDataButton {
                    
                }
                .didTapContentView { [weak self] in
                    self?.view.endEditing(true)
                }
        }
        
        chatRefresh.addTarget(self, action: #selector(refreshLiveChat(_:)), for: .valueChanged)
        
        trendingRFefresh.addTarget(self, action: #selector(refreshTrendingChat(_:)), for: .valueChanged)
        tableView.refreshControl = chatRefresh
        trendingTV.refreshControl = trendingRFefresh
        userImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(openMyProfile))
        userImageView.addGestureRecognizer(tap)
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] (timer) in
            guard let self = self else { return }
            if let r = self.room{
                let endTime = r.event.endDate.timeIntervalSince1970*1000
                let currentTime = Date().timeIntervalSince1970*1000
                let isextented = r.event.isEventExtendedIndefinately
                if !isextented{
                    if endTime - currentTime <= 300000 && !self.is5MinWarningshown{
                        self.is5MinWarningshown = true
                        CommonFunctions.showToastWithMessage("Room ends in 5 minutes.",theme: .info)
                    }else if endTime - currentTime < 1{
                        timer.invalidate()
                        self.showPopup()
                    }else{
                        printDebug("Time left in seconds: \((endTime - currentTime)/1000) sec")
                    }
                }
            }
        })
        setupEmptyScreens()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enableAutoToolbar = false
        setNavigationBar(title: "", backButton: true)
//        self.applyTransparentBackgroundToTheNavigationBar(100)
        navigationBtn()
        NotificationCenter.default.addObserver(self, selector: #selector(handelCelebrityApproval), name: Notification.Name("celebrityApproval"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let _ = timer{
            timer.invalidate()
        }
        IQKeyboardManager.shared.enableAutoToolbar = true
        NotificationCenter.default.removeObserver(self, name: Notification.Name("celebrityApproval"), object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        adjustContentSize(tv: textView)
    }
    
    override func initalSetup() {
        [allBtn,followingBtn,myBtn].forEach {
            $0?.setTitleColor(AppColors.labelColor, for: .normal)
            $0?.setTitleColor(AppColors.themeColor, for: .selected)
            $0?.titleLabel?.font = AppFonts.Medium.withSize(14)
        }
//        setNavigationBar(title: "", backButton: true)
        showTrending = false
//        self.applyTransparentBackgroundToTheNavigationBar(100)
//        navigationBtn()
        [trendingTV,tableView].forEach {
            $0?.delegate = self
            $0?.dataSource = self
            $0?.registerCell(with: CommnetTVCell.self)
            $0?.registerCell(with: ReplyThreadTVCell.self)
            $0?.registerCell(with: CommnetReactionTVCell.self)
        }
        setupLongPressGesture()
    }
    
    override func rightBarButtonTapped(_ sender: UIButton) {
        if UserModel.main.isAdmin{
            if isPopupShown{
                isPopupShown = false
            }else{
                isPopupShown = true
            }
        }else{
            let vc = RoomDetailVC.instantiate(fromAppStoryboard: .Events)
            vc.roomId = room?._id ?? ""
            AppRouter.pushFromTabbar(vc)
        }
    }
    
    override func setupFounts() {
        trendingTitle.font = AppFonts.Semibold.withSize(14)
        trendingTitle.textColor = AppColors.themeColor
    }
    
    @objc func openMyProfile(){
        CommonFunctions.navigateToUserProfile(UserModel.main.userId,onParent: self)
    }
    
    @objc func refreshLiveChat(_ sender:UIRefreshControl){
        sender.endRefreshing()
        if viewModel.dataSource.isLoaded{
            viewModel.currentPage = 1
            viewModel.hitGetComment()
        }
    }
    @objc func refreshTrendingChat(_ sender:UIRefreshControl){
        sender.endRefreshing()
        viewModel.trendingCurrentPage = 1
        viewModel.getTrending(viewModel.commnetType)
    }
    
    @objc func reconnectChatRoom() {
        
        startNYLoader()
        SocketIOManager.instance.initializeSocket()
        SocketIOManager.instance.connectSocket {
            self.viewModel.hitJoinEvent()
            DispatchQueue.delay(5.0) {
                self.viewModel.startObserving()
                
                self.stopNYLoader()
                
                if self.viewModel.dataSource.isLoaded{
                    self.viewModel.currentPage = 1
                    self.viewModel.hitGetComment()
                }
            }
        }
    }
    
    func setupLongPressGesture() {
        let longPressGesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress))
        longPressGesture.minimumPressDuration = 0.5
        longPressGesture.delegate = self
        self.tableView.addGestureRecognizer(longPressGesture)
        
        let trendingLongPress:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handleTrendingLongPress))
        trendingLongPress.minimumPressDuration = 0.5
        trendingLongPress.delegate = self
        self.trendingTV.addGestureRecognizer(trendingLongPress)
    }
    
    
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer){
        if gestureRecognizer.state == .began {
            let touchPoint = gestureRecognizer.location(in: tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                if (!CommonFunctions.isGuestLogin && !UserModel.main.isAdmin){
                    CommonFunctions.vaibratePhone()
                    showPopup(index: indexPath.section)
                }
            }
        }
    }
    
    @objc func handleTrendingLongPress(_ gestureRecognizer: UILongPressGestureRecognizer){
        CommonFunctions.vaibratePhone()
        if gestureRecognizer.state == .began {
            let touchPoint = gestureRecognizer.location(in: trendingTV)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                showTrendingPopup(index: indexPath.section)
            }
        }
    }
    
    @objc func handelCelebrityApproval(){
        if let _ = viewModel{
            viewModel.currentPage = 1
            viewModel.trendingCurrentPage = 1
            viewModel.hitGetComment()
            viewModel.getTrending()
        }
    }
    
    private func showPopup(){
        let alert = UIAlertController(title: "Alert!", message: "This room has been ended now.", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default) { [weak self](acttion) in
            self?.pop()
        }
        alert.addAction(ok)
        present(alert, animated: false, completion: nil)
    }
    
    private func showTrendingPopup(index:Int){
        if viewModel.trending.data[index].user.id == UserModel.main.userId{
            let vc = ThreeBtnPopup.instantiate(fromAppStoryboard: .Home)
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .overFullScreen
            vc.delagate = self
            vc.section = index
            let t = !viewModel.trending.data[index].isCommentSaved ? "Save" : "Unsave"
            vc.btn1Title = t
            vc.btn2Title = "Reply"
            vc.btn3Title = "Cancel"
            present(vc, animated: false, completion: nil)
        }else{
            let vc = ThreeBtnPopup.instantiate(fromAppStoryboard: .Home)
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .overFullScreen
            vc.delagate = self
            vc.section = index
            vc.btn1Title = "Reply"
            vc.btn2Title = "Report"
            vc.btn3Title = "Cancel"
            present(vc, animated: false, completion: nil)
        }
    }
    
    private func showPopup(index:Int){
        if viewModel.dataSource.data[index].user.id == UserModel.main.userId{
            let vc = ThreeBtnPopup.instantiate(fromAppStoryboard: .Home)
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .overFullScreen
            vc.delagate = self
            vc.section = index
            let t = !viewModel.dataSource.data[index].isCommentSaved ? "Save" : "Unsave"
            vc.btn1Title = t
            vc.btn2Title = "Reply"
            vc.btn3Title = "Cancel"
            present(vc, animated: false, completion: nil)
        }else{
            let vc = ThreeBtnPopup.instantiate(fromAppStoryboard: .Home)
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .overFullScreen
            vc.delagate = self
            vc.section = index
            vc.btn1Title = "Reply"
            vc.btn2Title = "Report"
            vc.btn3Title = "Cancel"
            present(vc, animated: false, completion: nil)
        }
    }
    
    private func setupEmptyScreens(){
        var msg = ""
        switch viewModel.commnetType {
        case .all:
            msg = "\n\nStart The Conversation!"
        case .following:
            msg = "\n\nStart The Conversation!"
        case .my:
            msg = "\n\nStart The Conversation!"
        }
        
        trendingTV.emptyDataSetView { view in
            view.titleLabelString(NSAttributedString(string: msg, attributes: [NSAttributedString.Key.font:AppFonts.Semibold.withSize(16),NSAttributedString.Key.foregroundColor:UIColor.black]))
                .image(#imageLiteral(resourceName: "ic-no-chatroom"))
        }
    }

    private func manageGuestuserLabel(_ sender:UIButton){
        if CommonFunctions.isGuestLogin{
            switch sender {
            case allBtn:
                guestuserMsgLabel.text = "You must be logged in to view this page"
            case followingBtn:
                guestuserMsgLabel.text = "You must be logged in to view this page"
            default:
                guestuserMsgLabel.text = "You must be logged in to view this page"
            }
        }else if UserModel.main.isAdmin{
            guestBtn.isHidden = true
            tumbIcon.image = #imageLiteral(resourceName: "ic_signup_login")
            switch sender {
            case allBtn:
                guestuserMsgLabel.text = "You are login as a Stoke"
            case followingBtn:
                guestuserMsgLabel.text = "You are login as a Stoke"
            default:
                guestuserMsgLabel.text = "You are login as a Stoke"
            }
        }
    }
    
    
    @IBAction func sendTapped(_ sender: Any) {
        guard let t = textView.text?.trimmingCharacters(in: .whitespacesAndNewlines), !t.isEmpty else { return }
        viewModel.addComment(t)
        textView.text = nil
    }
    
    @IBAction func seeNewCommnets(_ sender: AppButton) {
        sender.isHidden = true
        viewModel.currentPage = 1
        viewModel.hitGetComment()
    }
    
    @IBAction func guestLoginTapped(_ sender: Any) {
        UserModel.main = UserModel()
        AppRouter.checkUserFlow()
    }
    
    
    @IBAction func trendingBtnSelection(_ sender: UIButton) {
        guard CommonFunctions.checkForInternet() else {
            return
        }
        manageSelectedState(sender)
    }
    
    @IBAction func reportedCommnetTapped(_ sender: Any) {
        isPopupShown = false
        let vc = ReportedCommnetListVC.instantiate(fromAppStoryboard: .Chat)
        vc.room = room
        vc.delegate = self
        AppRouter.pushViewController(self, vc)
    }
    @IBAction func removeChatRoomTapped(_ sender: Any) {
        isPopupShown = false
        let vc = GenericPopupVC.instantiate(fromAppStoryboard: .Chat)
        vc.delegate = self
        vc.isForDelete = true
        vc.id = room?._id ?? ""
        vc.headingText = "Delete Chatroom?"
        vc.subheadingTxt = "Are you sure you want to delete this chatroom?"
        vc.firstbtnTitle = "Cancel"
        vc.secondbtnTitle = "Delete"
        vc.modalTransitionStyle = .coverVertical
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: false, completion: nil)
    }
    @IBAction func chatroomInfoTapped(_ sender: Any) {
        isDeletePopup = true
        let vc = RoomDetailVC.instantiate(fromAppStoryboard: .Events)
        vc.roomId = room?._id ?? ""
        AppRouter.pushFromTabbar(vc)
        isPopupShown = false
    }
    
    
    override func backButtonTapped() {
        SocketIOManager.instance.emit(with: .didDisConnect, ["chatroomId":room?._id ?? ""])
        viewModel.stopObserving()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.33) { [weak self] in
            self?.pop()
        }
    }
    
    private func manageSelectedState(_ sender:UIButton){
        if CommonFunctions.isGuestLogin || UserModel.main.isAdmin{
            manageGuestuserLabel(sender)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            guard let self = self else { return }
            guard !self.viewModel.trending.data.isEmpty else { return }
            self.trendingTV.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
        switch sender {
        case allBtn:
            if CommonFunctions.isGuestLogin || UserModel.main.isAdmin{
                guestuserView.isHidden = true
            }
            viewModel.getTrending()
            sender.addShadow()
            sender.isSelected = true
            followingBtn.isSelected = false
            myBtn.isSelected = false
            followingBtn.dropShadow()
            myBtn.dropShadow()
        case followingBtn:
            if CommonFunctions.isGuestLogin || UserModel.main.isAdmin{
                guestuserView.isHidden = false
            }
            viewModel.getTrending(.following)
            sender.isSelected = true
            allBtn.isSelected = false
            myBtn.isSelected = false
            sender.addShadow()
            allBtn.dropShadow()
            myBtn.dropShadow()
        default:
            if CommonFunctions.isGuestLogin || UserModel.main.isAdmin{
                guestuserView.isHidden = false
            }
            viewModel.getTrending(.my)
            sender.isSelected = true
            followingBtn.isSelected = false
            allBtn.isSelected = false
            sender.addShadow()
            followingBtn.dropShadow()
            allBtn.dropShadow()
        }
    }
    
    private func presentReplyThread(_ index:Int,isFromTrending:Bool = false){
        let vc = ReplyThreadVC.instantiate(fromAppStoryboard: .Chat)
        vc.roomId = room?._id ?? ""
        vc.room = room
        vc.tempViewModel = viewModel
        vc.isFromTrending = isFromTrending
        if showTrending{
            vc.commentId = viewModel.trending.data[index]._id
            vc.commnet = viewModel.trending.data[index]
        }else{
            vc.commentId = viewModel.dataSource.data[index]._id
            vc.commnet = viewModel.dataSource.data[index]
        }
        vc.delegate = self
        vc.modalTransitionStyle = .coverVertical
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: false, completion: nil)
    }
    
    private func navigationBtn(){
        navButton = UIButton(frame: CGRect(x: 0, y: 0, width: 200, height: 30))
        navButton.setTitle(room?.name ?? "", for: .normal)
        navButton.setImage(#imageLiteral(resourceName: "ic-drop-down-red"), for: .normal)
        navButton.setImage(#imageLiteral(resourceName: "ic-drop-down-red_up"), for: .selected)
        navButton.semanticContentAttribute = .forceRightToLeft
        navButton.titleLabel?.font = AppFonts.Semibold.withSize(18)
        navButton.setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
        navButton.setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: .selected)
        navButton.imageEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 0, right: 0)
        navButton.addTarget(self, action: #selector(toggleBtn(_:)), for: .touchUpInside)
        navigationItem.titleView = navButton
    }
    
    
    
    @objc func toggleBtn(_ sender:UIButton){
        manageSelectedState(allBtn)
        if sender.isSelected{
            sender.isSelected = false
            showTrending = false
        }else{
            sender.isSelected = true
            showTrending = true
        }
    }
    
    deinit {
        printDebug("\(self) -----> Killed")
    }
    
    func returnActionOnLive(_ c:Comment, type:ReationType) -> Bool{
        switch type {
        case .like:
            return !(c.isLiked)
        case .clap:
            return !(c.isClap)
        case .dislike:
            return !(c.isDisliked)
        default:
            return !(c.isLaugh)
        }
    }
    
    private func reload(table: UITableView) {
        UIView.performWithoutAnimation {
            table.reloadData()
            table.beginUpdates()
            table.endUpdates()
        }
    }
}

extension ChatRoomVC : UITextViewDelegate{
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.enableSendBtn = !textView.text.isEmpty
        }
        if text == ""{
            return true
        }else if textView.text.count > 300{
            return false
        }else{
            return true
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        adjustContentSize(tv: textView)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Comment..."
            textView.textColor = UIColor.lightGray
        }
    }
    
    func adjustContentSize(tv: UITextView){
        let deadSpace = tv.bounds.size.height - tv.contentSize.height
        let inset = max(0, deadSpace/2.0)
        tv.contentInset = UIEdgeInsets(top: inset, left: tv.contentInset.left, bottom: inset, right: tv.contentInset.right)
    }
}

extension ChatRoomVC : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView === trendingTV{
            return viewModel != nil ? viewModel.trending.data.count : 0
        }else{
            return viewModel != nil ? viewModel.dataSource.data.count : 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueCell(with: CommnetTVCell.self)
            if tableView === trendingTV{
                cell.populateCell(viewModel.trending.data[indexPath.section],index: viewModel.commnetType == .all ? indexPath.section + 1 : nil)
                cell.openProfileTapped = { [weak self] in
                    CommonFunctions.navigateToUserProfile(self?.viewModel.trending.data[indexPath.section].user.id ?? "",onParent: self)
                }
                cell.doubleTapped = { [weak self] in
                    if UserModel.main.isCelebrity && (self?.viewModel.trending.data[indexPath.section].user.id ?? "" != UserModel.main.userId){
                        guard let self = self else { return }
                        let c = self.viewModel.trending.data[indexPath.section]
                        self.viewModel.approveComment(c._id, type: !c.isApprovedByCelebrity, completion: { c in
                            self.viewModel.trending.data[indexPath.section].celebrity = c
                            self.viewModel.trending.data[indexPath.section].isApprovedByCelebrity = !self.viewModel.trending.data[indexPath.section].isApprovedByCelebrity
                            self.reload(table: tableView)
//                            tableView.reloadData()
                        })
                    }
                }
            }else{
                cell.doubleTapped = { [weak self] in
                    printDebug(UserModel.main.isCelebrity)
                    if UserModel.main.isCelebrity && (self?.viewModel.dataSource.data[indexPath.section].user.id ?? "" != UserModel.main.userId){
                        guard let self = self else { return }
                        let c = self.viewModel.dataSource.data[indexPath.section]
                        self.viewModel.approveComment(c._id, type: !c.isApprovedByCelebrity, completion: { c in
                            self.viewModel.dataSource.data[indexPath.section].celebrity = c
                            self.viewModel.dataSource.data[indexPath.section].isApprovedByCelebrity = !self.viewModel.dataSource.data[indexPath.section].isApprovedByCelebrity
                            self.reload(table: tableView)
//                            tableView.reloadData()
                        })
                    }
                }
                cell.populateCell(viewModel.dataSource.data[indexPath.section])
                cell.openProfileTapped = { [weak self] in
                    CommonFunctions.navigateToUserProfile(self?.viewModel.dataSource.data[indexPath.section].user.id ?? "",onParent: self)
                }
            }
            return cell
        case 1:
            let cell = tableView.dequeueCell(with: ReplyThreadTVCell.self)
            cell.clipsToBounds = true
            if tableView === trendingTV{
                cell.populateCell(viewModel.trending.data[indexPath.section].user_reply.first)
                cell.isIndexing = viewModel.commnetType == .all ? true : nil
                cell.seeThread = { [weak self] in
                    self?.presentReplyThread(indexPath.section,isFromTrending: false)
                }
            }else{
                cell.isIndexing = nil
                cell.populateCell(viewModel.dataSource.data[indexPath.section].user_reply.first)
                cell.seeThread = { [weak self] in
                    self?.presentReplyThread(indexPath.section)
                }
            }
            
            return cell
        default:
            let cell = tableView.dequeueCell(with: CommnetReactionTVCell.self)
            if tableView === trendingTV{
                cell.indexing = viewModel.commnetType == .all ? 1 : nil
                cell.populateCommnetReacts(model: viewModel.trending.data[indexPath.section])
                
                cell.reactionTapped = { [weak self] type in
                    guard let self = self else { return }
                    let c = self.viewModel.trending.data[indexPath.section]
                    self.viewModel.reactOnComment(c._id,action: self.returnActionOnLive(c, type: type), type: type)
                }
            }else{
                cell.indexing = nil
                cell.populateCommnetReacts(model: viewModel.dataSource.data[indexPath.section])
                cell.reactionTapped = { [weak self] type in
                    guard let self = self else { return }
                    let c = self.viewModel.dataSource.data[indexPath.section]
                    self.viewModel.reactOnComment(c._id,action: self.returnActionOnLive(c, type: type), type: type)
                }
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 1{
            if tableView === trendingTV{
                return viewModel.trending.data[indexPath.section].user_reply.isEmpty ? CGFloat.leastNormalMagnitude : UITableView.automaticDimension
            }else{
                return viewModel.dataSource.data[indexPath.section].user_reply.isEmpty ? CGFloat.leastNormalMagnitude : UITableView.automaticDimension
            }
        }else{
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableView.automaticDimension
    }
}


extension ChatRoomVC : UIScrollViewDelegate{
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        printDebug("Size =============>> \(scrollView.contentSize.height)")
        printDebug("Y==================>>> \(scrollView.contentOffset.y + scrollView.bounds.height)")
                    
        if scrollView === tableView{
            if (scrollView.contentOffset.y < 0) && (viewModel.dataSource.nextPage){
                if viewModel.dataSource.isLoaded{
                    self.viewModel.dataSource.isLoaded = false
                    viewModel.currentPage += 1
                    viewModel.hitGetComment()
                }
            }else{
                printDebug("Else.......")
            }
        }
    }
}


extension ChatRoomVC : ThreeBtnPopupDelegate{
    func getUserChoice(_ index:Int,section:Int) {
        if showTrending{
            if viewModel.trending.data[section].user.id == UserModel.main.userId{
                if index == 0{
                    let c = viewModel.trending.data[section]
                    viewModel.hitSaveComment(c._id, action: !c.isCommentSaved) { [weak self]  in
                        self?.viewModel.trending.data[section].isCommentSaved.toggle()
                    }
                }else if index == 1{
                    presentReplyThread(section)
                }else{
                    printDebug("do noting...")
                }
            }else{
                if index == 0{
                    presentReplyThread(section)
                }else if index == 1 {
                    let vc = DeleteChatRoomPopupVC.instantiate(fromAppStoryboard: .Events)
                    vc.heading = "Report Comment"
                    vc.subheading = "Are you sure you want to report this comment?"
                    vc.deleteBtnTitle = "Report"
                    vc.section = section
                    vc.delegate = self
                    vc.modalTransitionStyle = .crossDissolve
                    vc.modalPresentationStyle = .overFullScreen
                    self.present(vc, animated: false, completion: nil)
                }
            }
        }else{
            if viewModel.dataSource.data[section].user.id == UserModel.main.userId{
                if index == 0{
                    let c = viewModel.dataSource.data[section]
                    viewModel.hitSaveComment(c._id, action: !c.isCommentSaved) { [weak self]  in
                        self?.viewModel.dataSource.data[section].isCommentSaved.toggle()
                    }
                }else if index == 1{
                    presentReplyThread(section)
                }else{
                    printDebug("do noting...")
                }
            }else{
                if index == 0{
                    presentReplyThread(section)
                }else if index == 1 {
                    let vc = DeleteChatRoomPopupVC.instantiate(fromAppStoryboard: .Events)
                    vc.heading = "Report Comment"
                    vc.subheading = "Are you sure you want to report this comment?"
                    vc.deleteBtnTitle = "Report"
                    vc.section = section
                    vc.delegate = self
                    vc.modalTransitionStyle = .crossDissolve
                    vc.modalPresentationStyle = .overFullScreen
                    self.present(vc, animated: false, completion: nil)
                }
            }
        }
    }
    
}

extension ChatRoomVC : DeleteChatRoomPopupDelegate {
    func deleteTapped(index:Int) {
        if showTrending{
            viewModel.hitReportComment(viewModel.trending.data[index]._id) { [weak self] in
                guard let self = self else { return }
                self.reload(table: self.tableView)
//                self?.tableView.reloadData()
            }
        }else{
            viewModel.hitReportComment(viewModel.dataSource.data[index]._id) { [weak self] in
                guard let self = self else { return }
                self.reload(table: self.tableView)
//                self?.tableView.reloadData()
            }
        }
    }
}

extension ChatRoomVC : ReplyThreadDelegate {
    
    func reloadData() {
        viewModel.startObserving()
        viewModel.hitGetComment()
    }
}


extension ChatRoomVC : GenericPopupDelegate {
    
    func optionTapped(_ flag: Bool, isDelete: Bool, id: String) {
        if flag{
            CommonFunctions.deleteChatroom(id) {
                AppRouter.goToHome()
            }
        }
    }
}

extension ChatRoomVC : ReportedCommnetDelegate{
    
    func updatedata() {
        viewModel.hitGetComment()
        viewModel.getTrending()
    }
}

extension UIButton{
    
    func addShadow(){
        backgroundColor = .white
        drawShadow(shadowColor: #colorLiteral(red: 0.9294117647, green: 0.1098039216, blue: 0.1529411765, alpha: 0.18), shadowOpacity: 0.6, shadowPath: nil, shadowRadius: 3, cornerRadius: 10, offset: CGSize(width: 0, height: 3))
    }
    
    func dropShadow(){
        backgroundColor = .clear
        layer.shadowOpacity = 0
    }
}

