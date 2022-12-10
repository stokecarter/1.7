//
//  GroupDetailVC.swift
//  Stoke
//
//  Created by Admin on 21/03/21.
//

import UIKit

enum ButtonMode{
    case edit
    case invite
    case none
}

protocol GroupDetailDelegate:AnyObject {
    func editRoom(_ room:ChatRoom)
    func showSaveRoomPopup()
    func gotoRoom(_ room:ChatRoom)
    func showReqDenied()
    func goForPayment(_ room:ChatRoom)
    func deleteRoom(_ room:ChatRoom)
    func goForInviteFriend(_ room:ChatRoom)
}

extension GroupDetailDelegate{
    func gotoRoom(_ room:ChatRoom){}
    func showReqDenied(){}
    func goForPayment(_ room:ChatRoom){}
    func deleteRoom(_ room:ChatRoom){}
    func goForInviteFriend(_ room:ChatRoom){}
}

class GroupDetailVC: BaseVC {
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var bgViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var editBtnWidth: NSLayoutConstraint!
    
    
    
    
    
    
    var btnmode:ButtonMode = .none{
        didSet{
            switch btnmode {
            case .edit:
                editBtnWidth.constant = 40
                editBtn.setTitle("Edit", for: .normal)
            case .invite:
                editBtnWidth.constant = 40
                editBtn.setTitle("Invite", for: .normal)
            default:
                editBtnWidth.constant = CGFloat.leastNormalMagnitude
                editBtn.isHidden = true
            }
        }
    }
    var viewModel:GroupDetailVM!
    var room:ChatRoom!
    weak var delegate:GroupDetailDelegate?
    var showdetail:((ChatRoom)->())?
    var showInviteFriend:((ChatRoom)->())?
    var viewRecape:((ChatRoom)->())?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bgView.alpha = 0
        CommonFunctions.showActivityLoader()
        if room.isCreatedByMe{
            if room.isConcluded{
                editBtn.isHidden = true
                btnmode = .none
            }else if !room.isLive{
                editBtn.isHidden = false
                btnmode = .edit
            }else{
                editBtn.isHidden = true
                btnmode = .none
            }
        }else{
            if CommonFunctions.isGuestLogin{
                editBtn.isHidden = true
            }else{
                if room.isConcluded{
                    editBtn.isHidden = true
                    btnmode = .none
                }else{
                    editBtn.isHidden = false
                    btnmode = .invite
                }
            }
        }
        viewModel = GroupDetailVM(NetworkLayer(), id: room._id)
        viewModel.notifyChatSave = { [weak self] in
            self?.dismiss(animated: false) {
                guard let self = self else { return }
                self.delegate?.showSaveRoomPopup()
            }
        }
        viewModel.reload = { [weak self] in
            guard let self = self else { return }
            
            self.view.layoutIfNeeded()
            
            
            self.tableView.reloadData()
            
            
            DispatchQueue.main.async {
                
                self.view.layoutIfNeeded()
                
                var topMargin = self.view.height - ( self.tableView.contentSize.height + 125)                
                if topMargin < 0 {
                    topMargin = 0
                } else if topMargin > self.view.height/6 {
                    topMargin = self.view.height/6
                    
                }
                self.view.layoutIfNeeded()
                
                
                self.bgViewTopConstraint.constant = topMargin
                self.view.layoutIfNeeded()
                
//                } completion: { (falg) in
                CommonFunctions.hideActivityLoader()
                self.bgView.alpha = 1.0
//                }
            }
            
            
//            DispatchQueue.main.asyncAfter(deadline: .now()) {
//
//
//
////                UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut) {
//
//
//            }
            
            
            
        }
        viewModel.requestDeclined = { [weak self] in
            self?.dismiss(animated: false) {
                guard let self = self else { return }
                self.delegate?.showReqDenied()
            }
        }
//        headerView.roundCorner([.topRight,.topLeft], radius: 25)
//        view.layoutIfNeeded()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerView.roundCorner([.topRight,.topLeft], radius: 25)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        CommonFunctions.hideActivityLoader()
    }
    
    override func initalSetup() {
        headerView.roundCorner([.topRight,.topLeft], radius: 25)
        tableView.registerCell(with: ChatroomHeaderTVCell.self)
        tableView.registerCell(with: ChatRoomDetailTVCell.self)
        tableView.registerCell(with: AccesptDeclineTVCell.self)
        tableView.delegate = self
        tableView.dataSource = self
        editBtn.setTitleColor(AppColors.themeColor, for: .normal)
        editBtn.titleLabel?.font = AppFonts.Medium.withSize(14)
    }
    
    @IBAction func edittapped(_ sender: Any) {
        dismiss(animated: false) { [weak self] in
            guard let self = self else { return }
            if let r = self.viewModel.room{
                if r.isCreatedByMe{
                    self.delegate?.editRoom(r)
                }else{
                    self.delegate?.goForInviteFriend(r)
                }
            }
        }
    }
    
    @IBAction func dismissViewController(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
    
    deinit {
        printDebug("\(self) -----> Killed")
    }
    
    private func invitefriend(){
        if let invite = showInviteFriend { invite(room)}
    }
    
    
}


extension GroupDetailVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let _ = viewModel{
            if let _ = viewModel.room{
                return 2
            }else{
                return 0
            }
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueCell(with: ChatroomHeaderTVCell.self)
            guard let r = viewModel.room else { return cell }
            cell.populateCell(r)
            cell.openProfile = { [weak self] in
                self?.dismiss(animated: false, completion: {
                    let id = self?.room.createdBy.id ?? ""
                    CommonFunctions.navigateToUserProfile(id)
                })
            }
            return cell
        default:
            guard let r = viewModel.room else { return UITableViewCell() }
            let cell = tableView.dequeueCell(with: ChatRoomDetailTVCell.self)
            if UserModel.main.isAdmin{
                cell.populateCell(r)
                cell.acceptBtnType = false
                let t = "Delete Room"
                cell.viewPendingbtn.setTitle(t, for: .normal)
                cell.viewPendingbtn.btnType = .whiteColor
                cell.viewPendingbtn.isHidden = r.isConcluded
                cell.viewPending = { [weak self] in
                    guard let self = self else { return }
                    CommonFunctions.deleteChatroom(r._id) {
                        AppRouter.goToHome()
                    }
                }
                let ti = r.isSaved ? "Remove from My Rooms" : "Save to My Rooms"
                cell.joinBtn.setTitle(ti, for: .normal)
                cell.joinBtn.btnType = r.isSaved ? .whiteColor : .themeColor
                cell.joinTapped = { [weak self] in
                    guard let self = self else { return }
                    if r.isSaved{
                        self.viewModel.hitForUnsaveChatRoom { [weak self] in
                            guard let self = self else { return }
                            self.viewModel.room?.isSaved = false
                            self.tableView.reloadData()
                        }
                    }else{
                        self.viewModel.hitForUnsaveChatRoom { [weak self] in
                            guard let self = self else { return }
                            self.viewModel.hitForSaveChatRoom()
                        }
                    }
                }
            }else{
                if r.roomType == ._private && r.requestStatus == .requestedByCreatoe && !r.isCreatedByMe{
                    if r.isInvitedByCreator{
                        cell.populateCell(r)
                        cell.acceptBtnType = true
                        cell.isAccepted = { [weak self] flag in
                            self?.viewModel.actionOnrequest(flag, completion: { [weak self] in
                                if flag{
                                    self?.dismiss(animated: false) {
                                        guard let self = self else { return }
                                        self.delegate?.showSaveRoomPopup()
                                    }
                                }else{
                                    self?.viewModel.hitRoomDetail()
                                }
                            })
                        }
                    }else{
                        cell.populateCell(r)
                        cell.joinBtn.setTitle("Request to Join", for: .normal)
                        cell.joinBtn.btnType = .themeColor
                        cell.joinTapped = { [weak self] in
                            guard let self = self else { return }
                            self.viewModel.hitJoinrequest { (id) in
                                self.viewModel.room?.requestId = id
                                self.viewModel.room?.requestStatus = .requestedByMe
                                tableView.reloadData()
                            }
                        }
                        let t = r.isSaved ? "Remove from My Rooms" : "Save to My Rooms"
                        cell.viewPendingbtn.setTitle(t, for: .normal)
                        cell.viewPendingbtn.btnType = r.isSaved ? .whiteColor : .themeColor
                        cell.viewPending = { [weak self] in
                            guard let self = self else { return }
                            if r.isSaved{
                                self.viewModel.hitForUnsaveChatRoom { [weak self] in
                                    guard let self = self else { return }
                                    self.viewModel.room?.isSaved = false
                                    self.tableView.reloadData()
                                }
                            }else{
                                self.viewModel.hitForUnsaveChatRoom { [weak self] in
                                    guard let self = self else { return }
                                    self.viewModel.hitForSaveChatRoom()
                                }
                            }
                        }
                        cell.viewPendingbtn.isHidden = true
                    }
                }else{
                    cell.populateCell(r)
                    cell.acceptBtnType = false
                    if CommonFunctions.isGuestLogin{
                        cell.joinBtn.isHidden = true
                        cell.viewPendingbtn.isHidden = true
                    }else if !r.isFree{
                        if r.isConcluded{
                            cell.joinBtn.isHidden = true
                            cell.viewPendingbtn.isHidden = true
                        }else{
                            let t = r.isSaved ? "Remove from My Rooms" : "Save to My Rooms"
                            cell.joinBtn.setTitle(t, for: .normal)
                            cell.joinBtn.btnType = r.isSaved ? .whiteColor : .themeColor
                            cell.joinTapped = { [weak self] in
                                guard let self = self else { return }
                                if r.isSaved{
                                    self.viewModel.hitForUnsaveChatRoom { [weak self] in
                                        guard let self = self else { return }
                                        self.viewModel.room?.isSaved = false
                                        self.tableView.reloadData()
                                    }
                                }else{
                                    self.viewModel.hitForUnsaveChatRoom { [weak self] in
                                        guard let self = self else { return }
                                        self.viewModel.hitForSaveChatRoom()
                                    }
                                }
                            }
                            if r.paymentStatus == .pending{
                                cell.viewPendingbtn.setTitle("In Progress", for: .normal)
                                cell.viewPendingbtn.isUserInteractionEnabled = false
                            }else{
                                cell.viewPendingbtn.setTitle("Purchase Room", for: .normal)
                            }
                            cell.viewPendingbtn.isHidden = r.paymentStatus == .success
                            cell.viewPendingbtn.btnType = .whiteColor
                            cell.viewPending = { [weak self] in
                                self?.dismiss(animated: false, completion: {
                                    self?.delegate?.goForPayment(r)
                                })
                            }
                        }
                    }else if r.isCreatedByMe{
                        if r.isConcluded{
                            cell.joinBtn.setTitle("View Recap", for: .normal)
                            cell.viewPendingbtn.isHidden = true
                            cell.joinBtn.btnType = .themeColor
                            cell.joinTapped = { [weak self] in
                                if let recape = self?.viewRecape { recape(r)}
                            }
                        }else if r.roomType == ._private{
                            cell.joinBtn.setTitle("Room Management", for: .normal)
                            cell.viewPendingbtn.isHidden = true
                            cell.joinBtn.btnType = .themeColor
                            cell.joinTapped = { [weak self] in
                                guard let self = self else { return }
                                if let show = self.showdetail { show(r)}
                            }
                        }else{
                            cell.joinBtn.setTitle("Room Management", for: .normal)
                            cell.viewPendingbtn.isHidden = true
                            cell.joinBtn.btnType = .themeColor
                            cell.joinTapped = { [weak self] in
                                guard let self = self else { return }
                                if let show = self.showdetail { show(r)}
                            }
                            //                        cell.joinBtn.setTitle("View Pending", for: .normal)
                            cell.viewPendingbtn.setTitle("Invite Friends", for: .normal)
                            //                        cell.joinBtn.btnType = .themeColor
                            cell.viewPendingbtn.btnType = .themeColor
                            //                        cell.joinTapped = { [weak self] in
                            //                            guard let self = self else { return }
                            //                            if let show = self.showdetail { show(r)}
                            //                        }
                            cell.viewPending = { [weak self] in
                                guard let self = self else { return }
                                self.invitefriend()
                            }
                        }
                    }else{
                        if r.roomType == ._private{
                            if r.isLive{
                                if r.requestStatus == .none{
                                    cell.joinBtn.setTitle("Request to Join", for: .normal)
                                    cell.joinBtn.btnType = .themeColor
                                    cell.joinTapped = { [weak self] in
                                        guard let self = self else { return }
                                        self.viewModel.hitJoinrequest { (id) in
                                            self.viewModel.room?.requestId = id
                                            self.viewModel.room?.requestStatus = .requestedByMe
                                            tableView.reloadData()
                                        }
                                    }
//                                    let t = r.isSaved ? "Remove from My Rooms" : "Save to My Rooms"
//                                    cell.viewPendingbtn.setTitle(t, for: .normal)
//                                    cell.viewPendingbtn.btnType = r.isSaved ? .whiteColor : .themeColor
//                                    cell.viewPending = { [weak self] in
//                                        guard let self = self else { return }
//                                        if r.isSaved{
//                                            self.viewModel.hitForUnsaveChatRoom { [weak self] in
//                                                guard let self = self else { return }
//                                                self.viewModel.room?.isSaved = false
//                                                self.tableView.reloadData()
//                                            }
//                                        }else{
//                                            self.viewModel.hitForUnsaveChatRoom { [weak self] in
//                                                guard let self = self else { return }
//                                                self.viewModel.hitForSaveChatRoom()
//                                            }
//                                        }
//                                    }
                                    cell.viewPendingbtn.isHidden = true
                                }else if r.requestStatus == .requestedByMe{
                                    cell.joinBtn.setTitle("Cancel Join Request", for: .normal)
                                    cell.joinBtn.btnType = .whiteColor
                                    cell.joinTapped = { [weak self] in
                                        guard let self = self else { return }
                                        self.viewModel.cancelAlreadyJoinedrequest {
                                            self.viewModel.room?.requestStatus = .none
                                            tableView.reloadData()
                                        }
                                    }
                                    cell.viewPendingbtn.isHidden = true
                                }else if r.requestStatus == .readyToJoin{
                                    let t = r.isSaved ? "Remove from My Rooms" : "Save to My Rooms"
                                    cell.joinBtn.setTitle(t, for: .normal)
                                    cell.joinBtn.btnType = r.isSaved ? .whiteColor : .themeColor
                                    cell.joinTapped = { [weak self] in
                                        guard let self = self else { return }
                                        if r.isSaved{
                                            self.viewModel.hitForUnsaveChatRoom { [weak self] in
                                                guard let self = self else { return }
                                                self.viewModel.room?.isSaved = false
                                                self.tableView.reloadData()
                                            }
                                        }else{
                                            self.viewModel.hitForUnsaveChatRoom { [weak self] in
                                                guard let self = self else { return }
                                                self.viewModel.hitForSaveChatRoom()
                                            }
                                        }
                                    }
                                    cell.viewPendingbtn.isHidden = true
                                }
                            }else{
                                if r.isConcluded{
                                    if r.requestStatus == .readyToJoin{
                                        cell.joinBtn.setTitle("View Recap", for: .normal)
                                        cell.viewPendingbtn.isHidden = true
                                        cell.joinBtn.btnType = .themeColor
                                        cell.joinTapped = { [weak self] in
                                            if let recape = self?.viewRecape { recape(r)}
                                        }
                                        cell.viewPendingbtn.isHidden = true
                                    }else{
                                        cell.joinBtn.isHidden = true
                                        cell.viewPendingbtn.isHidden = true
                                    }
                                }else if r.requestStatus == .none{
                                    cell.joinBtn.setTitle("Request to Join", for: .normal)
                                    cell.joinTapped = { [weak self] in
                                        guard let self = self else { return }
                                        self.viewModel.hitJoinrequest { (id) in
                                            self.viewModel.room?.requestId = id
                                            self.viewModel.room?.requestStatus = .requestedByMe
                                            tableView.reloadData()
                                        }
                                    }
                                    cell.joinBtn.btnType = .themeColor
                                    cell.viewPendingbtn.isHidden = true
                                }else if r.requestStatus == .requestedByMe{
                                    cell.joinBtn.setTitle("Cancel Join Request", for: .normal)
                                    cell.joinBtn.btnType = .whiteColor
                                    cell.joinTapped = { [weak self] in
                                        guard let self = self else { return }
                                        self.viewModel.cancelAlreadyJoinedrequest {
                                            self.viewModel.room?.requestStatus = .none
                                            tableView.reloadData()
                                        }
                                    }
                                    cell.viewPendingbtn.isHidden = true
                                }else{
                                    let t = r.isSaved ? "Remove from My Rooms" : "Save to My Rooms"
                                    cell.joinBtn.setTitle(t, for: .normal)
                                    cell.joinBtn.btnType = r.isSaved ? .whiteColor : .themeColor
                                    cell.joinTapped = { [weak self] in
                                        guard let self = self else { return }
                                        if r.isSaved{
                                            self.viewModel.hitForUnsaveChatRoom { [weak self] in
                                                guard let self = self else { return }
                                                self.viewModel.room?.isSaved = false
                                                self.tableView.reloadData()
                                            }
                                        }else{
                                            self.viewModel.hitForUnsaveChatRoom { [weak self] in
                                                guard let self = self else { return }
                                                self.viewModel.hitForSaveChatRoom()
                                            }
                                        }
                                    }
                                    cell.viewPendingbtn.isHidden = true
                                }
                            }
                        }else{
                            if r.isConcluded{
                                if r.requestStatus == .readyToJoin{
                                    cell.joinBtn.setTitle("View Recap", for: .normal)
                                    cell.viewPendingbtn.isHidden = true
                                    cell.joinBtn.btnType = .themeColor
                                    cell.joinTapped = { [weak self] in
                                        if let recape = self?.viewRecape { recape(r)}
                                    }
                                    cell.viewPendingbtn.isHidden = true
                                }else{
                                    cell.joinBtn.isHidden = true
                                    cell.viewPendingbtn.isHidden = true
                                }
                            }else if r.isSaved{
                                cell.joinBtn.setTitle("Remove from My Rooms", for: .normal)
                                cell.joinBtn.btnType = .whiteColor
                                cell.joinTapped = { [weak self] in
                                    self?.viewModel.hitForUnsaveChatRoom { [weak self] in
                                        guard let self = self else { return }
                                        self.viewModel.room?.isSaved = false
                                        self.tableView.reloadData()
                                    }
                                }
                                cell.viewPendingbtn.isHidden = true
                            }else{
                                cell.joinBtn.setTitle("Save to My Rooms", for: .normal)
                                cell.joinBtn.btnType = .themeColor
                                cell.joinTapped = { [weak self] in
                                    guard let self = self else { return }
                                    self.viewModel.hitForSaveChatRoom()
                                }
                                cell.viewPendingbtn.isHidden = true
                            }
                        }
                    }
                }
            }
            return cell
            
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
}

