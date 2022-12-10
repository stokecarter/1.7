//
//  NotificationsListVC.swift
//  Stoke
//
//  Created by Admin on 21/05/21.
//

import UIKit

class NotificationsListVC: BaseVC {
    
    @IBOutlet weak var guestView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noInternetViewHeight: NSLayoutConstraint!

    
    var refresh = UIRefreshControl()
    var notificationIds:Set<String> = []
    var viewModel:NotificationListVM!
    var isFirstVisit = true
    
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
        StokeAnalytics.shared.setScreenVisitEvent(.visitNotifications)
        guestView.isHidden = !CommonFunctions.isGuestLogin
        viewModel = NotificationListVM(NetworkLayer())
        isInternetAvilabel = AppNetworkDetector.sharedInstance.isIntenetOk
        getVisibleIndexpath()
        viewModel.reloadData = { [weak self] in
            self?.viewModel.isLoaded =  true
            if self?.isFirstVisit ?? false{
                self?.isFirstVisit = false
                self?.getVisibleIndexpath()
            }
            self?.setEmptyScreen()
            self?.tableView.reloadData()
        }
        applyTransparentBackgroundToTheNavigationBar(100)
        if CommonFunctions.isGuestLogin{
            printDebug("Do nothing...")
        }else{
            setNavigationBar(title: "Notifications", backButton: false)
        }
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerCell(with: AdminNotificationTVCell.self)
        tableView.registerCell(with: NotificationAcceptTVCell.self)
        tableView.registerCell(with: NotificationTVCell.self)
        tableView.registerCell(with: NewFollowTVCell.self)
        tableView.registerCell(with: NotificationFollowTVCell.self)
        refresh.addTarget(self, action: #selector(pullTorefresh(_:)), for: .valueChanged)
        tableView.refreshControl = refresh
    }
    
    
    @IBAction func guestBtnTapped(_ sender: Any) {
        UserModel.main = UserModel()
        AppRouter.checkUserFlow()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(scrollToTop), name: .scrollTotop, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handelInternetStatus(_:)), name: .internetUpdate, object: nil)
        super.viewWillAppear(animated)
        if let _ = viewModel{
            isFirstVisit = true
            viewModel.getNotificationsList()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: .scrollTotop, object: nil)
        NotificationCenter.default.removeObserver(self, name: .internetUpdate, object: nil)
    }
    
    @objc func pullTorefresh(_ sender:UIRefreshControl){
        sender.endRefreshing()
        viewModel.currentPage = 1
        isFirstVisit = true
        viewModel.getNotificationsList()
    }
    
    private func getVisibleIndexpath(){
        let visibleRect = CGRect(origin: tableView.contentOffset, size: tableView.bounds.size)
        if let visibleIndexPath = tableView.indexPathsForRows(in: visibleRect){
            for i in visibleIndexPath{
                if UserModel.main.isAdmin{
                    if !viewModel.adminModel.data[i.row].isRead{
                        notificationIds.insert(viewModel.adminModel.data[i.row]._id)
                    }
                    if !notificationIds.isEmpty{
                        self.viewModel.readNotification(Array(self.notificationIds)) { [weak self] in
                            guard let self = self else { return }
                            let ar = Array(self.notificationIds)
                            for i in 0..<ar.count{
                                if let index = self.viewModel.adminModel.data.firstIndex(where: { $0._id == ar[i]}){
                                    self.viewModel.adminModel.data[index].isRead = true
                                }
                            }
                            self.notificationIds.removeAll()
                            self.tableView.reloadData()
                        }
                    }
                }else{
                    if !viewModel.model.data[i.row].isRead{
                        notificationIds.insert(viewModel.model.data[i.row]._id)
                    }
                    if !notificationIds.isEmpty{
                        self.viewModel.readNotification(Array(self.notificationIds)) { [weak self] in
                            guard let self = self else { return }
                            let ar = Array(self.notificationIds)
                            for i in 0..<ar.count{
                                if let index = self.viewModel.model.data.firstIndex(where: { $0._id == ar[i]}){
                                    self.viewModel.model.data[index].isRead = true
                                }
                            }
                            self.notificationIds.removeAll()
                            self.tableView.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    private func setEmptyScreen(){
        tableView.emptyDataSetView { view in
            view.titleLabelString(NSAttributedString(string: "\n\nYou don’t have any notifications yet!", attributes: [NSAttributedString.Key.font:AppFonts.Semibold.withSize(16),NSAttributedString.Key.foregroundColor:UIColor.black]))
                .image(#imageLiteral(resourceName: "no_notification"))
                .isScrollAllowed(true)
            
        }
    }
    
    @objc func scrollToTop() {
        guard let _ = viewModel, !viewModel.model.data.isEmpty else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
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

extension NotificationsListVC : UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return UserModel.main.isAdmin ? viewModel.adminModel.data.count : viewModel.model.data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if UserModel.main.isAdmin{
            return returnAdminPushNotificationCell(tableView, cellForRowAt: indexPath)
        }else{
            return returnUserPushNotificationCell(tableView, cellForRowAt: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if UserModel.main.isAdmin{
            let d = viewModel.adminModel.data[indexPath.row]
            switch viewModel.adminModel.data[indexPath.row].type {
            case .commentReported,.newRoomCreated:
                viewModel.getRoomDetail(d.typeId) { (room) in
                    if d.type == .newRoomCreated{
                        NotificationHandler.shared.manageRoom(room)
                    }else{
                        let vc = ReportedCommnetListVC.instantiate(fromAppStoryboard: .Chat)
                        vc.room = room
                        AppRouter.pushFromTabbar(vc)
                    }
                }
            case .userReported:
                printDebug("Do nothing....")
            default:
                printDebug("Do nothing....")
            }
        }else{
            let d = viewModel.model.data[indexPath.row]
            DispatchQueue.main.async {
                NotificationHandler.shared.handelListNotifications(d,onParent: self)
            }
        }
    }
    
    
    
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        let deleteAction = UIContextualAction(style: .normal, title:  "", handler: { [weak self] (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            if !UserModel.main.isAdmin{
                if let id = self?.viewModel.model.data[indexPath.row]._id{
                    self?.viewModel.deleteNotification(id, completion: {
                        self?.viewModel.model.data.remove(at: indexPath.row)
                        self?.tableView.reloadData()
                    })
                }
            }
        })
        deleteAction.backgroundColor = AppColors.themeColor
        deleteAction.image = #imageLiteral(resourceName: "ic_delete")
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}


extension NotificationsListVC : UIScrollViewDelegate{
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        getVisibleIndexpath()
        if UserModel.main.isAdmin{
            if (Int(scrollView.contentOffset.y + scrollView.frame.size.height) >= Int(scrollView.contentSize.height)) && viewModel.adminModel.data.count < viewModel.adminModel.totalCount {
                if viewModel.isLoaded{
                    viewModel.isLoaded = false
                    viewModel.currentPage += 1
                    viewModel.getNotificationsList(true)
                }
            }
        }else{
            if (Int(scrollView.contentOffset.y + scrollView.frame.size.height) >= Int(scrollView.contentSize.height)) && viewModel.model.data.count < viewModel.model.totalCount {
                if viewModel.isLoaded{
                    viewModel.isLoaded = false
                    viewModel.currentPage += 1
                    viewModel.getNotificationsList(true)
                }
            }
        }
    }
}





// MARK:- USER Related Push Notification
extension NotificationsListVC {
    
    func returnUserPushNotificationCell( _ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let d = viewModel.model.data[indexPath.row]
        switch d.notificationType {
        case .adminNotification:
            let cell = tableView.dequeueCell(with: AdminNotificationTVCell.self)
            cell.populateCell(d)
            return cell
        case .newChatroomInvite,.requestToJoin:
            let cell = tableView.dequeueCell(with: NotificationAcceptTVCell.self)
            cell.actionOn = { [weak self] flag in
                guard let self = self else { return }
                if d.notificationType == .newChatroomInvite{
                    if !cell.acceptBtn.isHidden{
                        self.viewModel.actionOnInvitation(flag, id: d.fromUser?.requestId ?? "") {
                            printDebug("Do nothing....")
                        }
                    }
                }else{
                    if !cell.acceptBtn.isHidden{
                        self.viewModel.actiononRequest(id: d.fromUser?.requestId ?? "", flag: flag) { (flag) in
                            printDebug("Do nothing...")
                        }
                    }
                }
            }
            cell.populateInviteType(d)
            return cell
        case .newFollowRequest:
            let cell = tableView.dequeueCell(with: NotificationAcceptTVCell.self)
            cell.actionOn = { [weak self] flag in
                guard let self = self else { return }
                CommonFunctions.actionOnFollowRequest(flag ? .accept : .decline, id: d.userId) {
                    self.viewModel.getNotificationsList()
                }
            }
            cell.populateFollowRequest(d)
            return cell
        case .newFollowRequestAccept:
            let cell = tableView.dequeueCell(with: NotificationAcceptTVCell.self)
            cell.populateFollowRequestStatus(d)
            return cell
        case .requestAccepted:
            let cell = tableView.dequeueCell(with: NotificationAcceptTVCell.self)
            cell.actionOn = { [weak self] flag in
                guard let self = self else { return }
                if d.notificationType == .newChatroomInvite{
                    self.viewModel.actionOnInvitation(flag, id: d.fromUser?.requestId ?? "") {
                        printDebug("Do nothing....")
                    }
                }else{
                    self.viewModel.actiononRequest(id: d.fromUser?.requestId ?? "", flag: flag) { (flag) in
                        printDebug("Do nothing...")
                    }
                }
            }
            cell.populateInviteType(d)
            return cell
        case .newFollow:
            let cell = tableView.dequeueCell(with: NotificationFollowTVCell.self)
            cell.populateCell(d)
            cell.followbtnTapped = { [weak self] in
                if let f = d.fromUser{
                    switch f.followStatus {
                    case .pending:
                        CommonFunctions.actionOnFollowRequest(.cancel, id: d.fromUser?._id ?? "") {[weak self] in
                            guard let self = self else { return }
                            self.viewModel.model.data[indexPath.row].fromUser?.followStatus = .none
                        }
                    case .accepted:
                        CommonFunctions.showUnFollowPopup(d.fromUser?._id ?? "", name: d.fromUser?.name ?? "") {
                            self?.viewModel.unfollowUser(d.fromUser?._id ?? "", completion: { [weak self] in
                                guard let self = self else { return }
                                self.viewModel.model.data[indexPath.row].fromUser?.followStatus = .none
                            })
                        }
                    case .none:
                        self?.viewModel.followUser(d.fromUser?._id ?? "", completion: {[weak self] in
                            guard let self = self else { return }
                            self.viewModel.model.data[indexPath.row].fromUser?.followStatus = .accepted
                        })
                    }
                }
                tableView.reloadData()
            }
            return cell
        case .engagementPoping:
            let cell = tableView.dequeueCell(with: NotificationAcceptTVCell.self)
            cell.populateReply(d)
            return cell
        case .celebrityApprovesCommnets:
            let cell = tableView.dequeueCell(with: NotificationAcceptTVCell.self)
            cell.populateReply(d)
            return cell
        case .chatroomCreatedByFollower:
            let cell = tableView.dequeueCell(with: NotificationAcceptTVCell.self)
            cell.populateNewChatroom(d)
            return cell
        case .replyOnCommnet:
            let cell = tableView.dequeueCell(with: NotificationAcceptTVCell.self)
            cell.populateReply(d)
            return cell
        case .eventReminder:
            let cell = tableView.dequeueCell(with: NotificationAcceptTVCell.self)
            cell.populateTagEventReminder(d)
            return cell
        default:
            let cell = tableView.dequeueCell(with: NotificationTVCell.self)
            cell.populateCell(d)
            return cell
        }
    }
    
}

// MARK:- ADMIN Related ßPush Notification
extension NotificationsListVC {
    func returnAdminPushNotificationCell( _ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let d = viewModel.adminModel.data[indexPath.row]
        switch d.type{
        case .newRoomCreated,.commentReported:
            let cell = tableView.dequeueCell(with: NotificationAcceptTVCell.self)
            cell.populateAdminNotification(d)
            return cell
        default:
            let cell = tableView.dequeueCell(with: AdminNotificationTVCell.self)
            cell.populateAdminNotificationCell(d)
            return cell
        }
    }
}

