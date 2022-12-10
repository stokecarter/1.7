//
//  EventGroupListVC.swift
//  Stoke
//
//  Created by Admin on 21/03/21.
//

import UIKit
import EmptyDataSet_Swift
import FittedSheets

class EventGroupListVC: BaseVC {
    
//    @IBOutlet weak var trendingBtn: UIButton!
//    @IBOutlet weak var followingBtn: UIButton!
//    @IBOutlet weak var sliderContainerView: UIView!
//    @IBOutlet weak var slidderView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var trendingCollectionView: UICollectionView!
    @IBOutlet weak var followingCollectionView: UICollectionView!
    @IBOutlet weak var guestUserView: UIView!
//    @IBOutlet weak var headerButtonHeight: NSLayoutConstraint!
    
    @IBOutlet weak var thumbIcon: UIImageView!
    @IBOutlet weak var thumbMessage: UILabel!
    @IBOutlet weak var logoutBtn: AppButton!
    
    var iSFromHistory:Bool = false
    var event:Event!
    var viewModel:EventGroupListVM!
    var isVisited:Bool = false
    
    var currentRoom:ChatRoom!
    
    var refreshController : UIRefreshControl  = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        scrollView.delegate = self
        viewModel = EventGroupListVM(NetworkLayer(), eventId: event.id)
        viewModel.notifyUpdate = { [weak self] in
            self?.updateEmptyScreen()
            self?.trendingCollectionView.reloadData()
            self?.followingCollectionView.reloadData()
        }
        if iSFromHistory || event.isEventConcluded || UserModel.main.isAdmin{
            hideRightBtn()
        }else{
            showRightBtn()
        }
    }
    
    private func setupView(){
        if CommonFunctions.isGuestLogin{
//            guestUserView.isHidden = trendingBtn.isSelected
            thumbIcon.image = #imageLiteral(resourceName: "ic_following_chatroom_graphic")
            thumbMessage.text = "You must be logged in to view this page"
            logoutBtn.setTitle("Log In / Sign Up", for: .normal)
        }else if UserModel.main.isAdmin{
//            guestUserView.isHidden = trendingBtn.isSelected
            thumbIcon.image = #imageLiteral(resourceName: "ic_signup_login")
            thumbMessage.text = "You are login as a Stoke"
            logoutBtn.isHidden = true
            view.layoutIfNeeded()
        }else{
            guestUserView.isHidden = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.isVisited = false
        CommonFunctions.navigationTitleImageView.isHidden = true
        viewModel.getAllTrendingChatRooms(type: .trending)
        SocketIOManager.instance.listenSocket(.joinRoom) { [weak self](val) in
            guard let self = self else { return }
            
        }
    }
    
    override func initalSetup() {
        trendingCollectionView.contentInset = UIEdgeInsets(top: -5, left: 0, bottom: 0, right: 0)
        followingCollectionView.contentInset = UIEdgeInsets(top: -5, left: 0, bottom: 0, right: 0)
        setNavigationBar(title: event.name, backButton: true)
        if Date().isGreaterThan(event.endDate) && !event.isEventExtendedIndefinately{
            printDebug("To don cases.....")
        }else{
            if !CommonFunctions.isGuestLogin{
                addRightButtonToNavigation(image: #imageLiteral(resourceName: "ic_add_room"))
            }
            
        }
        [trendingCollectionView,followingCollectionView].forEach {
            $0?.delegate = self
            $0?.dataSource = self
            $0?.registerCell(with: GroupCVCell.self)
            $0?.register(RoomsCVHeading.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "RoomsCVHeading")
        }
        
    }
    
    private func updateEmptyScreen(){
        let trendingMsg = viewModel.type == .trending ? "\n\nNo Rooms Available" : ""
        trendingCollectionView.emptyDataSetView { view in
            view.titleLabelString(NSAttributedString(string: trendingMsg, attributes: [NSAttributedString.Key.font:AppFonts.Semibold.withSize(16),NSAttributedString.Key.foregroundColor:UIColor.black]))
                .image(#imageLiteral(resourceName: "ic-no-chatroom"))
                .didTapDataButton {
                }
                .didTapContentView {
                }
        }
        let followingMsg = viewModel.type == .following ? "\n\nNo Rooms Available Associated With People You Follow" : ""
        followingCollectionView.emptyDataSetView { view in
            view.titleLabelString(NSAttributedString(string: followingMsg, attributes: [NSAttributedString.Key.font:AppFonts.Semibold.withSize(16),NSAttributedString.Key.foregroundColor:UIColor.black]))
                .image(#imageLiteral(resourceName: "ic-no-chatroom"))
                .didTapDataButton {
                    
                }
                .didTapContentView {
                    
                }
        }
    }
    
//    override func setupFounts() {
//        trendingBtn.isSelected = true
//        [trendingBtn,followingBtn].forEach { $0?.setTitleColor(AppColors.themeColor, for: .selected)
//            $0?.setTitleColor(#colorLiteral(red: 0.7882352941, green: 0.7882352941, blue: 0.7882352941, alpha: 1), for: .normal)
//            $0?.titleLabel?.font = AppFonts.Medium.withSize(16)
//        }
//    }
    
    override func rightBarButtonTapped(_ sender: UIButton) {
        CommonFunctions.checkChatroom(event.id) { [weak self] flag in
            guard let self = self else { return }
            if flag{
                let vc = AddRoomVC.instantiate(fromAppStoryboard: .Events)
                vc.event = self.event
                vc.isEditingMode = false
                AppRouter.pushFromTabbar(vc)
            }else{
                CommonFunctions.showToastWithMessage("You can only create 1 Room per Event.", theme: .info)
            }
        }
    }
    
    
    // Mark:- IBActions
    
//    @IBAction func trendingTapped(_ sender: UIButton) {
//        setSelectedButton(sender)
//        guestUserView.isHidden = true
//        scrollView.setContentOffset(CGPoint.zero, animated: true)
//    }
    
//    @IBAction func followingTapped(_ sender: UIButton) {
//        self.setSelectedButton(sender)
//        guestUserView.isHidden = (!CommonFunctions.isGuestLogin && !UserModel.main.isAdmin)
//        self.scrollView.setContentOffset(CGPoint(x: self.view.bounds.width, y: 0), animated: true)
//    }
    
    
    @IBAction func guestUserLoginTapped(_ sender: Any) {
        UserModel.main = UserModel()
        AppRouter.checkUserFlow()
    }
    
    
    
//    private func setSelectedButton(_ sender:UIButton){
        
//        trendingBtn.isSelected   = sender === trendingBtn ? true:false
//        followingBtn.isSelected   = sender === followingBtn ? true:false
        
//    }
    
    private func moveToInvitecreen(_ room:ChatRoom){
        let vc = InviteUsersVC.instantiate(fromAppStoryboard: .Events)
        vc.isfromDetail = true
        vc.roomId = room._id
        AppRouter.pushViewController(self, vc)
    }
    
    private func moveToDetailScreen(_ room:ChatRoom){
        let vc = RoomDetailVC.instantiate(fromAppStoryboard: .Events)
        vc.roomId = room._id
        vc.isPending = true
        AppRouter.pushFromTabbar(vc)
    }
    
    private func presentDetail(_ chat:ChatRoom){
        viewModel.groupDetail(chat._id) { [weak self](data) in
            guard let self = self else { return }
            self.currentRoom = data
            DispatchQueue.main.async {
                if UserModel.main.isAdmin{
                    if data.isLive{
                        let param = ["chatroomId":chat._id]
                        SocketIOManager.instance.emit(with: .joinRoom,param )
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
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
                        self.viewRecape(data)
                    }else{
                        self.self.presentPopupDetail(data)
                    }
                }else if data.roomType == ._public{
                    if data.isLive{
                        if data.isFree{
                            let param = ["chatroomId":chat._id]
                            SocketIOManager.instance.emit(with: .joinRoom,param )
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                                if self.currentRoom != nil{
//                                    let vc = ChatRoomVC.instantiate(fromAppStoryboard: .Chat)
//                                    printDebug(self.currentRoom.description)
//                                    vc.room = self.currentRoom
//                                    AppRouter.pushFromTabbar(vc)
//                                }else{
//                                    printDebug("Dublicate........")
//                                }
//                            }
                            
                            
                            if self.currentRoom != nil{
                                let vc = ChatRoomVC.instantiate(fromAppStoryboard: .Chat)
                                printDebug(self.currentRoom.description)
                                vc.room = self.currentRoom
                                AppRouter.pushFromTabbar(vc)
                            }else{
                                printDebug("Dublicate........")
                            }
                            
                        }else{
                            if data.paymentStatus == .success{
                                let param = ["chatroomId":chat._id]
                                SocketIOManager.instance.emit(with: .joinRoom,param )
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    if self.currentRoom != nil{
                                        let vc = ChatRoomVC.instantiate(fromAppStoryboard: .Chat)
                                        vc.room = self.currentRoom
                                        AppRouter.pushFromTabbar(vc)
                                    }else{
                                        printDebug("Dublicate........")
                                    }
                                }
                            }else if data.paymentStatus == .pending{
                                CommonFunctions.showToastWithMessage("Your Payment is in process. Please try after some time.")
                                return
                            }else{
                                self.presentPopupDetail(data)
                            }
                        }
                    }else{
                        
                        self.presentPopupDetail(data)
                    }
                }else{
                    if data.isLive && data.isCreatedByMe{
                        let param = ["chatroomId":chat._id]
                        SocketIOManager.instance.emit(with: .joinRoom,param )
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            if self.currentRoom != nil{
                                let vc = ChatRoomVC.instantiate(fromAppStoryboard: .Chat)
                                printDebug(self.currentRoom.description)
                                vc.room = self.currentRoom
                                AppRouter.pushFromTabbar(vc)
                            }else{
                                printDebug("Dublicate........")
                            }
                        }
                    }else if data.isLive && data.requestStatus == .readyToJoin{
                        if data.isFree{
                            let param = ["chatroomId":chat._id]
                            SocketIOManager.instance.emit(with: .joinRoom,param )
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
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
                            let param = ["chatroomId":chat._id]
                            SocketIOManager.instance.emit(with: .joinRoom,param )
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                if self.currentRoom != nil{
                                    let vc = ChatRoomVC.instantiate(fromAppStoryboard: .Chat)
                                    printDebug(self.currentRoom.description)
                                    vc.room = self.currentRoom
                                    AppRouter.pushFromTabbar(vc)
                                }else{
                                    printDebug("Dublicate........")
                                }
                            }
                        }
                    }else if data.isConcluded && data.isCreatedByMe{
                        self.viewRecape(data)
                    }else{
                        self.presentPopupDetail(data)
                    }
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
        vc.showInviteFriend = { [weak self] room in
            sheet.dismiss(animated: true) {
                self?.moveToInvitecreen(room)
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
    
    private func presentPopupDetail(_ data:ChatRoom){
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
    
    private func addPullToRefresh(){
        refreshController.addTarget(self, action: #selector(refresh), for: .valueChanged)
        trendingCollectionView.refreshControl = refreshController
        followingCollectionView.refreshControl = refreshController
    }
    
    @objc func refresh(){
        trendingCollectionView.reloadData()
        followingCollectionView.reloadData()
        refreshController.endRefreshing()
    }
    
    private func presentPopupView(){
        CommonFunctions.showToastWithMessage("Saved to your Rooms.", theme: .success)
    }
}

// Mark:- UIScrollView

//extension EventGroupListVC : UIScrollViewDelegate    {
    
//    public func scrollViewDidScroll(_ scrollView: UIScrollView)    {
//        guard scrollView != trendingCollectionView else { return }
//        guard scrollView != followingCollectionView else { return }
////        let width = scrollView.width/slidderView.width
//        let scroll = scrollView.contentOffset.x
////        slidderView.transform = CGAffineTransform(translationX: scroll/width, y: 0)
//        switch scroll {
//        case  0:
//            viewModel.type = .trending
//            viewModel.getAllTrendingChatRooms(type: .trending)
////            setSelectedButton(trendingBtn)
//            guestUserView.isHidden = true
//        case  UIDevice.width :
//            viewModel.type = .following
//            viewModel.getAllTrendingChatRooms(type: .following)
////            setSelectedButton(followingBtn)
//            guestUserView.isHidden = (!CommonFunctions.isGuestLogin && !UserModel.main.isAdmin)
//        default :
//            break
//        }
//    }
//}


extension EventGroupListVC : UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView === trendingCollectionView{
            return viewModel != nil ? viewModel.trendingChatRooms.chatRooms.count : 0
        }else{
            return viewModel != nil ? viewModel.followingChatRooms.chatRooms.count : 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueCell(with: GroupCVCell.self, indexPath: indexPath)
        if collectionView === trendingCollectionView{
            cell.populatecell(viewModel.trendingChatRooms.chatRooms[indexPath.row])
            cell.viewDetailTapped = { [weak self] in
                guard let self = self else { return }
                self.presentDetail(self.viewModel.trendingChatRooms.chatRooms[indexPath.row])
            }
        }else{
            cell.populatecell(viewModel.followingChatRooms.chatRooms[indexPath.row])
            cell.viewDetailTapped = { [weak self] in
                guard let self = self else { return }
                self.presentDetail(self.viewModel.trendingChatRooms.chatRooms[indexPath.row])
            }
        }
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "RoomsCVHeading", for: indexPath) as! RoomsCVHeading
            sectionHeader.label.text = "Rooms"
            return sectionHeader
        } else {
             return UICollectionReusableView()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if collectionView === trendingCollectionView{
            if viewModel != nil{
                if viewModel.trendingChatRooms.chatRooms.isEmpty{
                    return CGSize.zero
                }else{
                    return CGSize(width: collectionView.frame.width, height: 30)
                }
            }else{
                return CGSize.zero
            }
            
        }else{
            if viewModel != nil{
                if viewModel.followingChatRooms.chatRooms.isEmpty{
                    return CGSize.zero
                }else{
                    return CGSize(width: collectionView.frame.width, height: 30)
                }
            }else{
                return CGSize.zero
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 20)/2
//        let height:CGFloat = UIScreen.main.bounds.width == 414 ? 220 : 208
        return CGSize(width: width, height: 212)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard !iSFromHistory else { return }
        if collectionView === trendingCollectionView{
            presentDetail(viewModel.trendingChatRooms.chatRooms[indexPath.row])
        }else{
            presentDetail(viewModel.followingChatRooms.chatRooms[indexPath.row])
        }
    }
}


extension EventGroupListVC : GroupDetailDelegate {
    func editRoom(_ room: ChatRoom) {
        let vc = AddRoomVC.instantiate(fromAppStoryboard: .Events)
        vc.event = event
        vc.room = room
        vc.isEditingMode = true
        AppRouter.pushFromTabbar(vc)
    }
    
    func showSaveRoomPopup() {
//        presentPopupView()
    }
    
    func gotoRoom(_ room: ChatRoom) {
        let vc = ChatRoomVC.instantiate(fromAppStoryboard: .Chat)
        vc.room = room
        AppRouter.pushFromTabbar(vc)
    }
    
    func showReqDenied() {
        let vc = DeleteChatRoomPopupVC.instantiate(fromAppStoryboard: .Events)
        vc.heading = "Request Declined"
        vc.subheading = "Your request has been declined by the creator"
        vc.hideDeleteBtn = true
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: false, completion: nil)
    }
    
    func goForPayment(_ room: ChatRoom) {
        let vc = PaymentVC.instantiate(fromAppStoryboard: .Chat)
        vc.room = room
        AppRouter.pushFromTabbar(vc)
    }
    
    func goForInviteFriend(_ room: ChatRoom) {
        let vc = InviteUsersVC.instantiate(fromAppStoryboard: .Events)
        vc.isfromDetail = true
        vc.url = room.inviteString
        vc.roomId = room._id
        AppRouter.pushViewController(self, vc)
    }
    
    func deleteRoom(_ room: ChatRoom) {
        
    }
}


extension EventGroupListVC : SignupSucessDelegate {
    func okTapped() {
        printDebug("Do nothing.....")
//        AppRouter.goToMyrooms()
    }
}


