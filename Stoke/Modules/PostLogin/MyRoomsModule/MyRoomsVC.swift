//
//  MyRoomsVC.swift
//  Stoke
//
//  Created by Admin on 05/04/21.
//

import UIKit
import FittedSheets

class MyRoomsVC: BaseVC {
    
    @IBOutlet weak var savedBtn: UIButton!
    @IBOutlet weak var createdBtn: UIButton!
    @IBOutlet weak var sliderContainerView: UIView!
    @IBOutlet weak var slidderView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var savedCollectionView: UICollectionView!
    @IBOutlet weak var ccreatedCollectionView: UICollectionView!
    @IBOutlet weak var guestUserView: UIView!
    @IBOutlet weak var guestuserTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var thumbIcon: UIImageView!
    @IBOutlet weak var thumbMessage: UILabel!
    @IBOutlet weak var logoutBtn: AppButton!
    @IBOutlet weak var noInternetViewHeight: NSLayoutConstraint!
    
    
    var viewModel:MyRoomVM!
    var sheet:SheetViewController!
    var isVisited:Bool = false
    var isInternetAvilabel:Bool = true{
        didSet{
            if isInternetAvilabel{
                noInternetViewHeight.constant = CGFloat.leastNormalMagnitude
                viewModel.getSavedRooms(false)
            }else{
                noInternetViewHeight.constant = 25
                if let v = viewModel{
                    v.fetchOfflineData()
                }
            }
        }
    }
    
    var cReferesh = UIRefreshControl()
    var sReferesh = UIRefreshControl()


    var currentRoom:ChatRoom!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        applyTransparentBackgroundToTheNavigationBar(100)
        viewModel.notify = { [weak self] in
            self?.setupEmptyScreens()
            self?.savedCollectionView.reloadData()
            self?.ccreatedCollectionView.reloadData()
        }
        cReferesh.addTarget(self, action: #selector(refreshCreated(_:)), for: .valueChanged)
        sReferesh.addTarget(self, action: #selector(refreshSaved(_:)), for: .valueChanged)
        savedCollectionView.refreshControl = sReferesh
        ccreatedCollectionView.refreshControl = cReferesh
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: .scrollTotop, object: nil)
    }
    
    
    override func initalSetup() {
        StokeAnalytics.shared.setScreenVisitEvent(.visitMyRooms)
        viewModel = MyRoomVM(NetworkLayer())
        [savedCollectionView,ccreatedCollectionView].forEach {
            $0?.delegate = self
            $0?.dataSource = self
            $0?.registerCell(with: GroupCVCell.self)
            $0?.contentInset = UIEdgeInsets(top: -5, left: 0, bottom: 0, right: 0)
            $0?.register(SectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SectionHeaderView")
        }
        
    }
    
    @objc func refreshCreated(_ sender:UIRefreshControl){
        sender.endRefreshing()
        viewModel.getCreatedRooms()
    }
    
    @objc func refreshSaved(_ sender:UIRefreshControl){
        sender.endRefreshing()
        viewModel.getSavedRooms(false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(handelInternetStatus(_:)), name: .internetUpdate, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handelInternetStatus(_:)), name: .internetUpdate, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(scrollToTop), name: NSNotification.Name.scrollTotop, object: nil)
        if let _ = viewModel{
            isInternetAvilabel = AppNetworkDetector.sharedInstance.isIntenetOk
        }
        isVisited = false
        SocketIOManager.instance.listenSocket(.joinRoom) { [weak self](val) in
            guard let self = self else { return }
            
        }
    }
    
    @objc func scrollToTop() {
        scrollView.setContentOffset(CGPoint.zero, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            guard let vm = self?.viewModel else { return }
            if !(vm.savedRooms?.liveRoom.isEmpty ?? true){
                self?.savedCollectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .centeredHorizontally, animated: true)
            }else if !(vm.savedRooms?.upcoming.isEmpty ?? true){
                self?.savedCollectionView.scrollToItem(at: IndexPath(item: 0, section: 1), at: .centeredHorizontally, animated: true)
            }else if !(vm.savedRooms?.ended.isEmpty ?? true){
                self?.savedCollectionView.scrollToItem(at: IndexPath(item: 0, section: 2), at: .centeredHorizontally, animated: true)
            }
        }
    }
    
    @IBAction func guestUserTapped(_ sender: Any) {
        UserModel.main = UserModel()
        AppRouter.checkUserFlow()
    }
    
    
    override func setupFounts() {
        savedBtn.isSelected = true
        [savedBtn,createdBtn].forEach {
            $0?.setTitleColor(AppColors.themeColor, for: .selected)
            $0?.setTitleColor(#colorLiteral(red: 0.7882352941, green: 0.7882352941, blue: 0.7882352941, alpha: 1), for: .normal)
            $0?.titleLabel?.font = AppFonts.Medium.withSize(16)
        }
    }
    
    override func rightBarButtonTapped(_ sender: UIButton) {
        let vc = AddRoomVC.instantiate(fromAppStoryboard: .Events)
        vc.isEditingMode = false
        vc.isFromMyRooms = true
        vc.delegate = self
        AppRouter.pushFromTabbar(vc)
    }
    
    private func setSelectedButton(_ sender:UIButton){
        savedBtn.isSelected   = sender === savedBtn ? true:false
        createdBtn.isSelected   = sender === createdBtn ? true:false
        
    }
    
    // Mark:- IBActions
    
    @IBAction func savedTapped(_ sender: UIButton) {
        setSelectedButton(sender)
        scrollView.setContentOffset(CGPoint.zero, animated: true)
        guestUserView.isHidden = true

    }
    
    @IBAction func createdTapped(_ sender: UIButton) {
        self.setSelectedButton(sender)
        if UserModel.main.isAdmin{
            guestUserView.isHidden = false
        }
        self.scrollView.setContentOffset(CGPoint(x: self.view.bounds.width, y: 0), animated: true)
    }
    
    private func setupView(){
        if CommonFunctions.isGuestLogin{
            guestUserView.isHidden = false
            thumbIcon.image = #imageLiteral(resourceName: "ic_following_chatroom_graphic")
            thumbMessage.text = "You must be logged in to view this page"
            logoutBtn.setTitle("Log In / Sign Up", for: .normal)
        }else if UserModel.main.isAdmin{
            setNavigationBar(title: "My Rooms", backButton: false)
            guestuserTopConstraint.constant = 50
            guestUserView.isHidden = savedBtn.isSelected
            thumbIcon.image = #imageLiteral(resourceName: "ic_signup_login")
            thumbMessage.text = "You are login as a admin"
            logoutBtn.isHidden = true
            view.layoutIfNeeded()
        }else{
            addRightButtonToNavigation(image: #imageLiteral(resourceName: "ic_add_room"))
            setNavigationBar(title: "My Rooms", backButton: false)
            guestUserView.isHidden = true
        }
    }
    
    private func setupEmptyScreens(){
        var saveMsg = ""
        var saveImg = UIImage()
        var createdmsg = ""
        var createdImage = UIImage()
        if savedBtn.isSelected{
            saveMsg = "\n\nWhen you save Rooms they will appear here!"
            saveImg = #imageLiteral(resourceName: "ic-no-chatroom")
            createdImage = UIImage()
            createdmsg = ""
        }else{
            createdImage = #imageLiteral(resourceName: "ic-no-chatroom")
            saveImg = UIImage()
            saveMsg = ""
            createdmsg = "\n\nWhen you create Rooms they will appear here!"
        }
        savedCollectionView.emptyDataSetView { view in
            view.titleLabelString(NSAttributedString(string: saveMsg, attributes: [NSAttributedString.Key.font:AppFonts.Semibold.withSize(16),NSAttributedString.Key.foregroundColor:UIColor.black]))
                .image(saveImg)
        }
        ccreatedCollectionView.emptyDataSetView { view in
            view.titleLabelString(NSAttributedString(string: createdmsg, attributes: [NSAttributedString.Key.font:AppFonts.Semibold.withSize(16),NSAttributedString.Key.foregroundColor:UIColor.black]))
                .image(createdImage)
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

extension MyRoomsVC : UIScrollViewDelegate{
    public func scrollViewDidScroll(_ scrollView: UIScrollView)    {
        guard self.scrollView === scrollView else { return }
        let width = scrollView.width/slidderView.width
        let scroll = scrollView.contentOffset.x
        slidderView.transform = CGAffineTransform(translationX: scroll/width, y: 0)
        switch scroll {
        case  0:
            setSelectedButton(savedBtn)
            viewModel.getSavedRooms(false)
        case  UIDevice.width :
            if UserModel.main.isAdmin{
                guestUserView.isHidden = false
            }
            setSelectedButton(createdBtn)
            viewModel.getCreatedRooms(false)
        default :
            break
        }
    }
    
    private func moveToDetailScreen(_ room:ChatRoom){
        let vc = RoomDetailVC.instantiate(fromAppStoryboard: .Events)
        vc.roomId = room._id
        vc.isPending = true
        AppRouter.pushFromTabbar(vc)
    }
    
    private func presentPopupView(){
//        let vc = RoomCreatedSuccessVC.instantiate(fromAppStoryboard: .Events)
//        vc.heading = "Chatroom Saved"
//        vc.subheading = "You have successfully saved the chat room\nWe will notify once the chatroom is live"
//        vc.okBtntitle = "OK"
//        vc.modalTransitionStyle = .crossDissolve
//        vc.modalPresentationStyle = .overFullScreen
//        self.present(vc, animated: false, completion: nil)
    }
    
    private func presentDetailpopup(data:ChatRoom){
        if data.isCreatedByMe{
            if data.isLive{
                currentRoom = data
//                guard CommonFunctions.checkForInternet() else { return }
                let param = ["chatroomId":data._id]
                SocketIOManager.instance.emit(with: .joinRoom,param)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if self.currentRoom != nil{
                        let vc = ChatRoomVC.instantiate(fromAppStoryboard: .Chat)
                        printDebug(self.currentRoom.description)
                        vc.room = self.currentRoom
                        AppRouter.pushFromTabbar(vc)
                    }else{
                        printDebug("Dublicate........")
                    }
                }
            }else if data.isConcluded{
                viewRecape(data)
            }else{
                guard CommonFunctions.checkForInternet() else { return }
                presentJoinPopup(data)
            }
        }else{
            
            if data.paidType.lowercased() != "paid" {
                
                if data.isLive{
                    if data.roomType == ._public || data.requestStatus == .readyToJoin{
                        currentRoom = data
    //                    guard CommonFunctions.checkForInternet() else { return }
                        let param = ["chatroomId":data._id]
                        SocketIOManager.instance.emit(with: .joinRoom,param)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            if self.currentRoom != nil{
                                let vc = ChatRoomVC.instantiate(fromAppStoryboard: .Chat)
                                printDebug(self.currentRoom.description)
                                vc.room = self.currentRoom
                                AppRouter.pushFromTabbar(vc)
                            }else{
                                printDebug("Dublicate........")
                            }
                        }
                    }else{
                        presentJoinPopup(data)
                    }
                }else{
                    presentJoinPopup(data)
                }
            } else {
                if data.paymentStatus == .success {
                    if data.isLive{
                        if data.roomType == ._public || data.requestStatus == .readyToJoin{
                            currentRoom = data
        //                    guard CommonFunctions.checkForInternet() else { return }
                            let param = ["chatroomId":data._id]
                            SocketIOManager.instance.emit(with: .joinRoom,param)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                if self.currentRoom != nil{
                                    let vc = ChatRoomVC.instantiate(fromAppStoryboard: .Chat)
                                    printDebug(self.currentRoom.description)
                                    vc.room = self.currentRoom
                                    AppRouter.pushFromTabbar(vc)
                                }else{
                                    printDebug("Dublicate........")
                                }
                            }
                        }else{
                            presentJoinPopup(data)
                        }
                    }else{
                        presentJoinPopup(data)
                    }
                } else {
                    presentSheet(data)
                }
            }
        }
    }
    
    private func viewRecape(_ room:ChatRoom){
        let vc = RecapVC.instantiate(fromAppStoryboard: .Chat)
        vc.room = room
        AppRouter.pushViewController(self, vc)
    }
    
    
    private func presentSheet(_ data:ChatRoom){
        let vc = GroupDetailVC.instantiate(fromAppStoryboard: .Events)
        vc.room = data
        vc.delegate = self
        let sheet = SheetViewController(controller: vc, sizes: [.fullscreen])
        vc.showdetail = { [weak self] room in
            sheet.dismiss(animated: true) {
                self?.moveToDetailScreen(room)
            }
        }
        vc.viewRecape = { [weak self] room in
            sheet.dismiss(animated: true) {
                self?.viewRecape(room)
            }
        }
        sheet.gripSize = .zero
        sheet.gripColor = .clear
        sheet.minimumSpaceAbovePullBar = 0
        sheet.cornerRadius = 0
        sheet.contentBackgroundColor = .clear
        sheet.overlayColor = UIColor.black.withAlphaComponent(0.15)
        sheet.pullBarBackgroundColor = .clear
        self.present(sheet, animated: false, completion: nil)
    }
    
    
    private func presentJoinPopup(_ data:ChatRoom){
        if data.isConcluded && ((data.roomType == ._private && data.requestStatus == .readyToJoin) || data.roomType == ._public){
            if data.isFree{
                viewRecape(data)
            }else{
                if data.paymentStatus == .success{
                    viewRecape(data)
                }else{
                    presentSheet(data)
                }
            }
        }else{
            presentSheet(data)
        }
    }
}


extension MyRoomsVC : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView === savedCollectionView{
            if let _ = viewModel.savedRooms{
                return 3
            }else{
                return 0
            }
        }else{
            if let _ = viewModel.createdRooms{
                return 3
            }else{
                return 0
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView === savedCollectionView{
            if let v = viewModel.savedRooms{
                switch section {
                case 0:
                    return v.liveRoom.count
                case 1:
                    return v.upcoming.count
                default:
                    return v.ended.count
                }
            }else{
                return 0
            }
        }else{
            if let v = viewModel.createdRooms{
                switch section {
                case 0:
                    return v.liveRoom.count
                case 1:
                    return v.upcoming.count
                default:
                    return v.ended.count
                }
            }else{
                return 0
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueCell(with: GroupCVCell.self, indexPath: indexPath)
        if collectionView === savedCollectionView{
            switch indexPath.section {
            case 0:
                if let r = viewModel.savedRooms?.liveRoom[indexPath.row]{
                    cell.populatecell(r)
                    cell.viewDetailTapped = { [weak self] in
                        self?.presentDetailpopup(data:r)
                    }
                }
            case 1:
                if let r = viewModel.savedRooms?.upcoming[indexPath.row]{
                    cell.populatecell(r)
                    cell.viewDetailTapped = { [weak self] in
                        self?.presentDetailpopup(data:r)
                    }
                }
            default:
                if let r = viewModel.savedRooms?.ended[indexPath.row]{
                    cell.populatecell(r)
                    cell.viewDetailTapped = { [weak self] in
                        self?.presentDetailpopup(data:r)
                    }
                }
            }
        }else{
            switch indexPath.section {
            case 0:
                if let r = viewModel.createdRooms?.liveRoom[indexPath.row]{
                    cell.populatecell(r)
                    cell.viewDetailTapped = { [weak self] in
                        self?.presentDetailpopup(data:r)
                    }
                }
            case 1:
                if let r = viewModel.createdRooms?.upcoming[indexPath.row]{
                    cell.populatecell(r)
                    cell.viewDetailTapped = { [weak self] in
                        self?.presentDetailpopup(data:r)
                    }
                }
            default:
                if let r = viewModel.createdRooms?.ended[indexPath.row]{
                    cell.populatecell(r)
                    cell.viewDetailTapped = { [weak self] in
                        self?.presentDetailpopup(data:r)
                    }
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            if let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionHeaderView", for: indexPath) as? SectionHeaderView {
                switch indexPath.section {
                case 0:
                    sectionHeader.label.text = ""
                case 1:
                    sectionHeader.label.text = "Upcoming"
                default:
                    sectionHeader.label.text = "Ended"
                }
                 return sectionHeader
            }else{
                return UICollectionReusableView()
            }
        } else { //No footer in this case but can add option for that
             return UICollectionReusableView()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0{
            return CGSize(width: collectionView.frame.width, height: 10)
        }else{
            if collectionView === savedCollectionView{
                switch section {
                case 0: return CGSize(width: collectionView.frame.width, height: 10)
                case 1:
                    return (viewModel.savedRooms?.upcoming.isEmpty ?? false) ? CGSize.zero : CGSize(width: collectionView.frame.width, height: 30)
                default:
                    return (viewModel.savedRooms?.ended.isEmpty ?? false) ? CGSize.zero : CGSize(width: collectionView.frame.width, height: 30)
                }
            }else{
                switch section {
                case 0: return CGSize(width: collectionView.frame.width, height: 10)
                case 1:
                    return (viewModel.createdRooms?.upcoming.isEmpty ?? false) ? CGSize.zero : CGSize(width: collectionView.frame.width, height: 30)
                default:
                    return (viewModel.createdRooms?.ended.isEmpty ?? false) ? CGSize.zero : CGSize(width: collectionView.frame.width, height: 30)
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 20)/2
        return CGSize(width: width, height: 208)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView === savedCollectionView{
            switch indexPath.section {
            case 0:
                if let r = viewModel.savedRooms?.liveRoom[indexPath.row] {
                    presentDetailpopup(data:r)
                }
            case 1:
                if let r = viewModel.savedRooms?.upcoming[indexPath.row]{
                    presentDetailpopup(data:r)
                }
            default:
                if let r = viewModel.savedRooms?.ended[indexPath.row]{
                    presentDetailpopup(data:r)
                }
            }
        }else{
            switch indexPath.section {
            case 0:
                if let r = viewModel.createdRooms?.liveRoom[indexPath.row]{
                    presentDetailpopup(data:r)
                }
            case 1:
                if let r = viewModel.createdRooms?.upcoming[indexPath.row]{
                    presentDetailpopup(data:r)
                }
            default:
                if let r = viewModel.createdRooms?.ended[indexPath.row]{
                    presentDetailpopup(data:r)
                }
            }
        }
    }
}


extension MyRoomsVC : GroupDetailDelegate {
    func editRoom(_ room: ChatRoom) {
        let vc = AddRoomVC.instantiate(fromAppStoryboard: .Events)
        vc.event = room.event
        vc.room = room
        vc.isEditingMode = true
        AppRouter.pushFromTabbar(vc)
    }
    
    func showSaveRoomPopup() {
        presentPopupView()
    }
    
    func goForInviteFriend(_ room: ChatRoom) {
        let vc = InviteUsersVC.instantiate(fromAppStoryboard: .Events)
        vc.isfromDetail = true
        vc.url = room.inviteString
        vc.roomId = room._id
        AppRouter.pushViewController(self, vc)
    }
    
    func showReqDenied() {
        let vc = DeleteChatRoomPopupVC.instantiate(fromAppStoryboard: .Events)
        vc.heading = "Request Declined"
        vc.msg = "Your request has been declined by the creator"
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: false, completion: nil)
    }
    
    func goForPayment(_ room: ChatRoom) {
        let vc = PaymentVC.instantiate(fromAppStoryboard: .Chat)
        vc.room = room
        AppRouter.pushFromTabbar(vc)
    }
}

extension MyRoomsVC : AddRoomDelegate {
    func roomCreatedSucess() {
        viewModel.getCreatedRooms()
        self.scrollView.setContentOffset(CGPoint(x: self.view.bounds.width, y: 0), animated: true)
    }
}
