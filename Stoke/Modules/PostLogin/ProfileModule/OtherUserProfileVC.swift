//
//  OtherUserProfileVC.swift
//  Stoke
//
//  Created by Admin on 17/05/21.
//

import UIKit
import FittedSheets

class OtherUserProfileVC: BaseVC {
    
    
    @IBOutlet weak var tableview: UITableView!
    
    private var viewModel:UserProfileVM!
    var userId:String!
    var refresh = UIRefreshControl()
    var isFromLink:Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
            viewModel = UserProfileVM(NetworkLayer(),userId: userId)
            viewModel.notify = { [weak self] in
                let t = (self?.viewModel.model.fullName.byRemovingLeadingTrailingWhiteSpaces ?? "").isEmpty ? "Profile" : (self?.viewModel.model.fullName.byRemovingLeadingTrailingWhiteSpaces ?? "")
                self?.setNavigationBar(title: t, backButton: true)
                self?.tableview.reloadData()
                self?.checkForScrolling()
            }
            setNavigationBar(title: "Profile", backButton: false)
        viewModel.popToBack = { [weak self] in
            self?.pop()
        }
            refresh.addTarget(self, action: #selector(pullToRefresh(_:)), for: .valueChanged)
        if !CommonFunctions.isGuestLogin && !UserModel.main.isAdmin{
            addRightButtonToNavigation(image: #imageLiteral(resourceName: "more-1"))
        }
    }
    
    override func initalSetup() {
        tableview.delegate = self
        tableview.dataSource = self
        tableview.registerCell(with: ProfileHeaderTVCell.self)
        tableview.registerCell(with: TwoTabsProfileTVCell.self)
        tableview.registerCell(with: ThreeTabsProfileTVCell.self)
        tableview.registerCell(with: ActionOnRequestTVCell.self)
    }
    
    @objc func pullToRefresh(_ sender:UIRefreshControl){
        sender.endRefreshing()
        viewModel.getProfile()
        viewModel.getSavedCommnets()
        viewModel.getSavedTaggs()
        viewModel.getSavedRooms()
    }
    
    override func backButtonTapped() {
        if isFromLink{
            AppRouter.goToHome()
        }else{
            pop()
        }
    }
    
    override func rightBarButtonTapped(_ sender: UIButton) {
        let vc = ProfileActionOtionsVC.instantiate(fromAppStoryboard: .Home)
        vc.modalTransitionStyle = .coverVertical
        vc.modalPresentationStyle = .overFullScreen
        vc.delegate = self
        present(vc, animated: false, completion: nil)
    }
    
    private func showFollowers(_ flag:Bool){
        let vc = FollowFollowingVC.instantiate(fromAppStoryboard: .Home)
        vc.userName = viewModel.model.userName
        vc.showFollowers = flag
        vc.userId = viewModel.model._id
        AppRouter.pushViewController(self, vc)
    }
    
    func showBlockPopup(id:String,name:String) {
        let vc = GenericPopupVC.instantiate(fromAppStoryboard: .Chat)
        vc.delegate = self
        vc.isForDelete = true
        vc.headingText = "Block \(name)?"
        vc.subheadingTxt = "Are you sure you want to block this user?"
        vc.firstbtnTitle = "Cancel"
        vc.secondbtnTitle = "Block"
        vc.id = id
        vc.modalTransitionStyle = .coverVertical
        vc.modalPresentationStyle = .overFullScreen
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
    
    private func showGuestUserPopup(){
        let vc = GuestUserPopupVC.instantiate(fromAppStoryboard: .Home)
        vc.modalTransitionStyle = .coverVertical
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: false, completion: nil)
    }
    
    private func checkForScrolling(){
        guard let cell = tableview.cellForRow(at: IndexPath(row: 2, section: 0)) as? ThreeTabsProfileTVCell else { return }
        let outerY = Int(tableview.contentOffset.y)
        let innerY = Int(tableview.rectForRow(at: IndexPath(row: 2, section: 0)).minY - 1)
        if outerY >= innerY{
            cell.saveCommnetsTV.isScrollEnabled = true
            cell.tagsCV.isScrollEnabled = true
            cell.savedChatroomsCV.isScrollEnabled = true
        }else{
            cell.saveCommnetsTV.isScrollEnabled = false
            cell.tagsCV.isScrollEnabled = false
            cell.savedChatroomsCV.isScrollEnabled = false
        }
       
    }
    
}



extension OtherUserProfileVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel != nil ? 3 : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 1{
            let cell = tableView.dequeueCell(with: ProfileHeaderTVCell.self)
            cell.populateCell(viewModel.model)
            cell.showFollowers = { [weak self] flag in
                self?.showFollowers(flag)
            }
            cell.buttonTapped = { [weak self] in
                guard let self = self else { return }
                if CommonFunctions.isGuestLogin{
//                    self.showGuestUserPopup()
                }else{
                    if self.viewModel.model.isFollow{
                        CommonFunctions.showUnFollowPopup(self.viewModel.model._id, name: self.viewModel.model.fullName) {
                            self.viewModel.followUser(!self.viewModel.model.isFollow, completion: {
                                self.viewModel.getProfile()
                            })
                        }
                    }else{
                        self.viewModel.followUser(!self.viewModel.model.isFollow, completion: {
                            self.viewModel.getProfile()
                        })
                    }
                }
            }
            return cell
        }else if indexPath.row == 2{
            let cell = tableView.dequeueCell(with: ThreeTabsProfileTVCell.self)
            cell.populateCommnetCell(viewModel.savedCommnets)
            cell.populateTags(viewModel.savedTags)
            cell.populateSaveRooms(viewModel.savedRooms)
            cell.isPrivate = viewModel.model.isPrivateAccount
            cell.selectionMade = { [weak self] selection in
                self?.viewModel.currentSection = selection
                self?.tableview.reloadData()
            }
            cell.tapOnChatRooms = { [weak self] room in
                self?.presentDetailpopup(data: room)
            }
            cell.tapOnTags = { [weak self] in
                self?.presentPopupView()
            }
            return cell
        }else{
            let cell = tableview.dequeueCell(with: ActionOnRequestTVCell.self)
            cell.actionOnRequest = { [weak self] action in
                CommonFunctions.actionOnFollowRequest(action ? .accept : .decline, id: self?.viewModel.model._id ?? "") {
                    self?.viewModel.getProfile()
                }
            }
            cell.populate(viewModel.model.userName)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0{
            if viewModel.model != nil{
            return viewModel.model.toUserFollowStatus == .pending ? UITableView.automaticDimension : CGFloat.leastNormalMagnitude
            }else{
                return CGFloat.leastNormalMagnitude
            }
        }else if indexPath.row == 2{
            if viewModel.currentSection == .savedCommnets{
                return tableview.height
            }else{
                return tableview.height
            }
        }else{
            return UITableView.automaticDimension
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        checkForScrolling()
    }
}


extension OtherUserProfileVC : ProfileActionOtionsDelegate{
    
    func getSelectedOption(_ index: Int) {
        switch index {
        case 0:
            showBlockPopup(id: viewModel.model._id, name: viewModel.model.userName)
        case 1:
            let vc = GenericPopupVC.instantiate(fromAppStoryboard: .Chat)
            vc.delegate = self
            vc.isForDelete = false
            vc.headingText = "Report \(viewModel.model.userName)?"
            vc.subheadingTxt = "Are you sure you want to report this user?"
            vc.firstbtnTitle = "Cancel"
            vc.secondbtnTitle = "Report"
            vc.id = viewModel.model._id
            vc.modalTransitionStyle = .coverVertical
            vc.modalPresentationStyle = .overFullScreen
            present(vc, animated: false, completion: nil)
        default:
            UIPasteboard.general.string = viewModel.model.profileLink
            CommonFunctions.showToastWithMessage("Link copied.",theme:.success)
        }
    }
}


extension OtherUserProfileVC : GenericPopupDelegate {
    
    func optionTapped(_ flag: Bool, isDelete: Bool, id: String) {
        if isDelete{
            if flag{
                viewModel.blockUser { [weak self] in
                    CommonFunctions.showToastWithMessage("User blocked successfully.", theme: .success)
                    self?.pop()
                }
            }
        }else{
            if flag{
                viewModel.reportUser { [weak self] in
                    CommonFunctions.showToastWithMessage("User reported successfully.", theme: .success)
                    self?.pop()
                }
            }
        }
    }
}



extension OtherUserProfileVC : SignupSucessDelegate {
    func okTapped() {
        viewModel.getSavedTaggs()
    }
}




extension OtherUserProfileVC {
    
    private func presentDetailpopup(data:ChatRoom){
        if data.isCreatedByMe{
            if data.isLive{
                let param = ["chatroomId":data._id]
                SocketIOManager.instance.emit(with: .joinRoom,param)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    let vc = ChatRoomVC.instantiate(fromAppStoryboard: .Chat)
                    vc.room = data
                    AppRouter.pushFromTabbar(vc)
                }
            }else if data.isConcluded{
                viewRecape(data)
            }else{
                guard CommonFunctions.checkForInternet() else { return }
                presentJoinPopup(data)
            }
        }else{
            guard CommonFunctions.checkForInternet() else { return }
            if data.isLive{
                if data.roomType == ._public || data.requestStatus == .readyToJoin{
                    guard CommonFunctions.checkForInternet() else { return }
                    let param = ["chatroomId":data._id]
                    SocketIOManager.instance.emit(with: .joinRoom,param)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            let vc = ChatRoomVC.instantiate(fromAppStoryboard: .Chat)
                            vc.room = data
                            AppRouter.pushFromTabbar(vc)
                    }
                }else{
                    presentJoinPopup(data)
                }
            }else{
                presentJoinPopup(data)
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
        guard CommonFunctions.checkForInternet() else { return }
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
    
    private func moveToDetailScreen(_ room:ChatRoom){
        let vc = RoomDetailVC.instantiate(fromAppStoryboard: .Events)
        vc.roomId = room._id
        vc.isPending = true
        AppRouter.pushFromTabbar(vc)
    }

}

extension OtherUserProfileVC : GroupDetailDelegate {
    func editRoom(_ room: ChatRoom) {
        printDebug("Not a case....")
    }
    
    func showSaveRoomPopup() {
        presentPopupView()
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
