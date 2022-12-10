//
//  RoomDetailVC.swift
//  Stoke
//
//  Created by Admin on 13/04/21.
//

import UIKit

class RoomDetailVC: BaseVC {
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var addFriendBtn: UIButton!
    @IBOutlet weak var saveRoomBtn: UIButton!
    
    
    var isPopupShown:Bool = false{
        didSet{
            popupView.isHidden = !isPopupShown
        }
    }
    
    var refresh:UIRefreshControl!
    
    var roomId:String = ""
    var room:ChatRoom! = nil{
        didSet{
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.isPopupShown = false
                if !CommonFunctions.isGuestLogin && !self.room.isConcluded{
                    self.addRightButtonToNavigation(image: #imageLiteral(resourceName: "more"))
                }
                let t = self.room.isSaved ? "Remove Room" : "Save Room"
                self.saveRoomBtn.setTitle(t, for: .normal)
                self.tableView.reloadData()
            }
        }
    }
    
    var isPending:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if UserModel.main.isAdmin{
            addFriendBtn.setTitle("Delete Room", for: .normal)
        }
        isPopupShown = false
        setNavigationBar(title: "Details", backButton: true)
        hitDetailRoom()
        popupView.drawShadow(shadowColor: #colorLiteral(red: 0.368627451, green: 0.368627451, blue: 0.368627451, alpha: 0.35), shadowOpacity: 6, shadowRadius: 4, cornerRadius: 8, offset: CGSize.zero)
        refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(pullToRefresh(_:)), for: .valueChanged)
        tableView.refreshControl = refresh
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        popupView.drawShadow(shadowColor: #colorLiteral(red: 0.368627451, green: 0.368627451, blue: 0.368627451, alpha: 0.35), shadowOpacity: 6, shadowRadius: 4, cornerRadius: 8, offset: CGSize.zero)
    }
    
    
    override func initalSetup() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerCell(with: ChatroomHeaderTVCell.self)
        tableView.registerCell(with: ChatRoomDetailTVCell.self)
        tableView.registerCell(with: TwoTabsTVCell.self)
        tableView.registerCell(with: ThreeTabsTVCell.self)
    }
    
    @objc func pullToRefresh(_ sender:UIRefreshControl){
        sender.endRefreshing()
        hitDetailRoom()
    }
    
    @IBAction func saveRoomTapped(_ sender: Any) {
        if room.isSaved{
            hitForUnsaveChatRoom { [weak self] in
                self?.hitDetailRoom()
            }
        }else{
            hitForSaveChatRoom { [weak self] in
                self?.hitDetailRoom()
            }
        }
    }
    
    @IBAction func addFriendTapped(_ sender: Any) {
        if UserModel.main.isAdmin{
            let vc = GenericPopupVC.instantiate(fromAppStoryboard: .Chat)
            vc.delegate = self
            vc.isForDelete = true
            vc.headingText = "Delete Chatroom?"
            vc.subheadingTxt = "Are you sure you want to delet this chatroom?"
            vc.firstbtnTitle = "Cancel"
            vc.secondbtnTitle = "Delete"
            vc.modalTransitionStyle = .coverVertical
            vc.modalPresentationStyle = .overFullScreen
            present(vc, animated: false, completion: nil)
        }else{
            isPopupShown = false
            let vc = InviteUsersVC.instantiate(fromAppStoryboard: .Events)
            vc.isfromDetail = true
            vc.url = room.inviteString
            vc.roomId = room._id
            vc.delegate = self
            AppRouter.pushViewController(self, vc)
        }
        
    }
    
    
    
    override func rightBarButtonTapped(_ sender: UIButton) {
        printDebug(room.inviteString)
        if room.isCreatedByMe{
            let vc = InviteUsersVC.instantiate(fromAppStoryboard: .Events)
            vc.isfromDetail = true
            vc.url = room.inviteString
            vc.roomId = room._id
            vc.delegate = self
            AppRouter.pushViewController(self, vc)
        }else{
            if isPopupShown{
                isPopupShown = false
            }else{
                isPopupShown = true
            }
        }
    }
    
    func hitDetailRoom(){
        let url = WebService.getChatRooms.path + "/\(roomId)"
        let param:JSONDictionary = ["chatroomId":roomId]
        NetworkLayer().requestString(from: url, param: param, method: .GET, header: [:], loader: true) { (data, err) in
            if let e = err{
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            }else{
                guard let d = data else { return }
                Parser.shared.getJSONData(data: d) { [weak self](json) in
                    DispatchQueue.main.async {
                        self?.room = ChatRoom(json[ApiKey.data])
                    }
                } failure: { (e) in
                    CommonFunctions.showToastWithMessage(e.localizedDescription)
                }
            }
        }
    }
    
    func hitForUnsaveChatRoom(completion:@escaping (()->())){
        let url = WebService.saveChatRoom.path + "/" + roomId
        NetworkLayer().requestString(from: url, param: [:], method: .DELETE, header: [:], loader: true) { (data, er) in
            if let e = er{
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            }else{
                guard let d = data else { return }
                Parser.shared.getJSONData(data: d) { (json) in
                    DispatchQueue.main.async {
                        completion()
                    }
                } failure: { (e) in
                    CommonFunctions.showToastWithMessage(e.localizedDescription)
                }
            }
        }
    }
    
    func hitForSaveChatRoom(completion:@escaping (()->())){
        let param:JSONDictionary = ["chatroomId":roomId]
        NetworkLayer().request(from: WebService.saveChatRoom, param: param, method: .POST, header: [:], loader: true) { (data, er) in
            if let e = er{
                CommonFunctions.showToastWithMessage(e.localizedDescription)
            }else{
                guard let d = data else { return }
                Parser.shared.getJSONData(data: d) { (json) in
                    DispatchQueue.main.async {
                        completion()
                    }
                } failure: { (e) in
                    CommonFunctions.showToastWithMessage(e.localizedDescription)
                }
            }
        }
    }
    
    private func openUserProfile(_ id:String){
        CommonFunctions.navigateToUserProfile(id, onParent: self)
    }
}


extension RoomDetailVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return room != nil ? 3 : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueCell(with: ChatroomHeaderTVCell.self)
            cell.populateCell(room)
            cell.openProfile = { [weak self] in
                let id = self?.room.createdBy.id ?? ""
                CommonFunctions.navigateToUserProfile(id)
            }
            return cell
        case 1:
            let cell = tableView.dequeueCell(with: ChatRoomDetailTVCell.self)
            cell.populateCell(room)
            cell.shouldHideAllBtn = true
            return cell
        default:
            if room.roomType == ._private && room.isCreatedByMe{
                let cell = tableView.dequeueCell(with: ThreeTabsTVCell.self)
                cell.populateCell(room)
                cell.isPending = self.isPending
                return cell
            }else{
                let cell = tableView.dequeueCell(with: TwoTabsTVCell.self)
                cell.populateCell(room)
                cell.openUserProfile = { [weak self] id in
                    self?.openUserProfile(id)
                }
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == 2 ? view.bounds.height - 70 : UITableView.automaticDimension
    }
}


extension RoomDetailVC : InviteFriendsDelegate {
    func showPending() {
        if room.roomType == ._private && room.isCreatedByMe{
            isPending = true
            tableView.reloadData()
        }
    }
}


extension RoomDetailVC : GenericPopupDelegate {
    
    func optionTapped(_ flag: Bool, isDelete: Bool, id: String) {
        if flag{
            CommonFunctions.deleteChatroom(room._id) { [weak self] in
                AppRouter.goToHome()
            }
        }
    }
}
