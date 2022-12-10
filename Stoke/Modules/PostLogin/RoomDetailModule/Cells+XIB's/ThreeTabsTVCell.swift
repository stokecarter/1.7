//
//  ThreeTabsTVCell.swift
//  Stoke
//
//  Created by Admin on 13/04/21.
//

import UIKit

class ThreeTabsTVCell: UITableViewCell {

    @IBOutlet weak var allUsersBtn: UIButton!
    @IBOutlet weak var followingBtn: UIButton!
    @IBOutlet weak var pendingBtn: UIButton!
    @IBOutlet weak var allusersearchTF: UITextField!
    @IBOutlet weak var followingSearchTF: UITextField!
    @IBOutlet weak var pendingSearchTF: UITextField!
    @IBOutlet weak var followingTV: UITableView!
    @IBOutlet weak var alluserTableView: UITableView!
    @IBOutlet weak var pendingTableView: UITableView!
    @IBOutlet weak var sliderContainerView: UIView!
    @IBOutlet weak var slidderView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var invitationBtn: UIButton!
    @IBOutlet weak var requestBtn: UIButton!
    
    @IBOutlet weak var guestUserView: UIView!
    var viewModel:ThreeTabsVM!
    
    var isPending:Bool = false{
        didSet{
            if isPending{
                allUsersBtn.isSelected = false
                followingBtn.isSelected = false
                pendingBtn.isSelected = true
                type = .sent
                viewModel.reqType = .sent
                viewModel.initationsListing(type: .sent)
                setupBtn(invitationBtn)
                scrollView.setContentOffset(CGPoint(x: self.contentView.bounds.width * 2, y: 0), animated: true)
            }
        }
    }

    
    var type:RequestType = .sent
    
    override func awakeFromNib() {
        super.awakeFromNib()
        guestUserView.isHidden = !CommonFunctions.isGuestLogin
        scrollView.delegate = self
        setupFounts()
        [alluserTableView,followingTV].forEach {
            $0?.delegate = self
            $0?.dataSource = self
            $0?.registerCell(with: AllUsersTVCell.self)
        }
        pendingTableView.delegate = self
        pendingTableView.dataSource = self
        pendingTableView.registerCell(with: AcceptPendingTVCell.self)
        [allusersearchTF,followingSearchTF,pendingSearchTF].forEach {
            $0?.delegate = self
            $0?.addTarget(self, action: #selector(editingChanged(_:)), for: .editingChanged)
        }
        invitationBtn.isSelected = true
        invitationBtn.backgroundColor = AppColors.themeColor
        [requestBtn,invitationBtn].forEach {
            $0?.setTitleColor(AppColors.labelColor, for: .normal)
            $0?.setTitleColor(.white, for: .selected)
            $0?.titleLabel?.font = AppFonts.Medium.withSize(14)
        }
        
        alluserTableView.emptyDataSetView { view in
            view.titleLabelString(NSAttributedString(string: "\n\nNo Users", attributes: [NSAttributedString.Key.font:AppFonts.Semibold.withSize(16),NSAttributedString.Key.foregroundColor:UIColor.black]))
                .image(#imageLiteral(resourceName: "no_user"))
                .didTapDataButton {
                    
                }
                .didTapContentView {
                    // Do something
                }
        }
        followingTV.emptyDataSetView { view in
            view.titleLabelString(NSAttributedString(string: "\n\nNo one you follow is here yet. Invite your friends!", attributes: [NSAttributedString.Key.font:AppFonts.Semibold.withSize(16),NSAttributedString.Key.foregroundColor:UIColor.black]))
                .image(#imageLiteral(resourceName: "no_user"))
                .didTapDataButton {
                    
                }
                .didTapContentView {
                    // Do something
                }
        }
        setupEmptyScreens()
        
    }
    
    @IBAction func alUsersTapped(_ sender: UIButton) {
        setSelectedButton(sender)
        scrollView.setContentOffset(CGPoint.zero, animated: true)
    }
    
    @IBAction func followingTapped(_ sender: UIButton) {
        setSelectedButton(sender)
        scrollView.setContentOffset(CGPoint(x: self.contentView.bounds.width, y: 0), animated: true)
    }
    
    @IBAction func pendingTapped(_ sender: UIButton) {
        type = .sent
        viewModel.reqType = .sent
        setupBtn(invitationBtn)
        setSelectedButton(sender)
        viewModel.initationsListing(type: .sent)
        scrollView.setContentOffset(CGPoint(x: self.contentView.bounds.width * 2, y: 0), animated: true)
    }
    
    @IBAction func invitationTapped(_ sender: UIButton) {
        viewModel.reqType = .sent
        type = .sent
        viewModel.initationsListing(type: .sent)
        setupBtn(sender)
    }
    
    @IBAction func requestedTapped(_ sender: UIButton) {
        viewModel.reqType = .received
        type = .received
        viewModel.initationsListing(type: .received)
        setupBtn(sender)
    }
    
    
    @IBAction func guestuserTapped(_ sender: Any) {
        UserModel.main = UserModel()
        AppRouter.checkUserFlow()
    }
    
    private func setupBtn(_ sender:UIButton){
        sender.isSelected = true
        if sender == invitationBtn{
            requestBtn.isSelected = false
            sender.backgroundColor = AppColors.themeColor
            requestBtn.backgroundColor = .clear
        }else{
            invitationBtn.isSelected = false
            sender.backgroundColor = AppColors.themeColor
            invitationBtn.backgroundColor = .clear
        }
    }
    
    @objc func editingChanged(_ textField:UITextField){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            if textField === self?.allusersearchTF{
                self?.viewModel.hitAllUserList(search: textField.text ?? "", type: .all)
            }else if textField === self?.followingSearchTF{
                self?.viewModel.hitAllUserList(search: textField.text ?? "", type: .following)
            }else{
                self?.viewModel.initationsListing(search: textField.text ?? "", type: self?.type ?? .sent)
            }
        }
    }
    
    private func setupEmptyScreens(){
        guard let _ = viewModel else { return }
        let msg = viewModel .reqType == .sent ? "\n\nNo invites sent. Go invite your friends!" : "\n\nNo Pending Requests"
        pendingTableView.emptyDataSetView { view in
            view.titleLabelString(NSAttributedString(string: msg, attributes: [NSAttributedString.Key.font:AppFonts.Semibold.withSize(16),NSAttributedString.Key.foregroundColor:UIColor.black]))
                .image(#imageLiteral(resourceName: "no_user"))
                .didTapDataButton {
                    
                }
                .didTapContentView {
                    // Do something
                }
        }
    }
    
    private func setupFounts() {
        allUsersBtn.isSelected = true
        setBtnTitle()
        [allUsersBtn,followingBtn,pendingBtn].forEach { $0?.setTitleColor(AppColors.themeColor, for: .selected)
            $0?.setTitleColor(#colorLiteral(red: 0.7882352941, green: 0.7882352941, blue: 0.7882352941, alpha: 1), for: .normal)
            $0?.titleLabel?.font = AppFonts.Semibold.withSize(14)
        }
    }
    
    func populateCell(_ room:ChatRoom){
        viewModel = ThreeTabsVM(NetworkLayer(), room: room)
        if isPending {
            pendingBtn.isSelected = true
            scrollView.setContentOffset(CGPoint(x: self.contentView.bounds.width * 2, y: 0), animated: true)
        }else{
            allUsersBtn.isSelected = true
        }
        viewModel.notify = { [weak self] in
            self?.updateCounts()
            self?.followingTV.reloadData()
            self?.alluserTableView.reloadData()
            self?.setupEmptyScreens()
            self?.pendingTableView.reloadData()
        }
        
    }
    
    private func setSelectedButton(_ sender:UIButton){
        allUsersBtn.isSelected   = sender === allUsersBtn ? true:false
        followingBtn.isSelected   = sender === followingBtn ? true:false
        pendingBtn.isSelected = sender === pendingBtn ? true : false
    }
    
    private func updateCounts(){
        setBtnTitle(allUsers: viewModel.allusers.totalCount, allFollowers: viewModel.following.totalCount)
    }
    
    private func setBtnTitle(allUsers:Int? = nil, allFollowers:Int? = nil){
//        let t1 = allUsers != nil ? "All Users (\(allUsers!))" : "All Users"
//        let t2 = allFollowers != nil ? "Following (\(allFollowers!))" : "Following"
//        let t3 = "Pending"
        allUsersBtn.setTitle("All Users", for: .normal)
        followingBtn.setTitle("Following", for: .normal)
        pendingBtn.setTitle("Pending", for: .normal)
    }
    
    
}

extension ThreeTabsTVCell : UITextFieldDelegate {
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        textField.text = nil
        if textField === allusersearchTF {
            viewModel.hitAllUserList()
        }else{
            viewModel.hitAllUserList(search: "", type: .following)
        }
        endEditing(true)
        return false
    }
}

extension ThreeTabsTVCell : UIScrollViewDelegate {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView)    {
        guard self.scrollView === scrollView else {
            return
        }
        let width = scrollView.width/slidderView.width
        let scroll = scrollView.contentOffset.x
        slidderView.transform = CGAffineTransform(translationX: scroll/width, y: 0)
        switch scroll {
        case  0:
            viewModel.hitAllUserList()
            setSelectedButton(allUsersBtn)
        case  UIDevice.width :
            viewModel.hitAllUserList(search: "", type: .following)
            setSelectedButton(followingBtn)
        case UIDevice.width*2:
            viewModel.reqType = .sent
            viewModel.initationsListing(type: .sent)
            setSelectedButton(pendingBtn)
        default :
            break
        }
    }
}


extension ThreeTabsTVCell : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView === alluserTableView{
            guard viewModel != nil else{ return 0}
            return viewModel.allusers.data.count
        }else if tableView === followingTV{
            guard viewModel != nil else{ return 0}
            return viewModel.following.data.count
        }else{
            guard viewModel != nil else{ return 0}
            if type == .sent{
                guard viewModel != nil else{ return 0}
                return viewModel.sentRequest.data.count
            }else{
                guard viewModel != nil else{ return 0}
                return viewModel.pendingRequest.data.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView === alluserTableView{
            let cell = tableView.dequeueCell(with: AllUsersTVCell.self)
            guard viewModel.allusers.data.count > indexPath.row else { return cell }
            let d = viewModel.allusers.data[indexPath.row]
            cell.followBtn.isHidden = (d.id == UserModel.main.userId || d.isGuest)
            cell.populateCell(d)
            cell.btnTapped = { [weak self] in
                guard let self = self else { return }
                let u = self.viewModel.allusers.data[indexPath.row]
                if u.isPrivateAccount{
                    switch u.followStatus {
                    case .none:
                        self.viewModel.actionOnFollowUnfollow(useID: d.id, action: d.isFollowed ? .unfollow : .follow) { (action) in
                            self.viewModel.allusers.data[indexPath.row].followStatus = .accepted
                        }
                    case .pending:
                        CommonFunctions.actionOnFollowRequest(.cancel, id: d.id) {
                            self.viewModel.allusers.data[indexPath.row].followStatus = .none
                        }
                    case .accepted:
                        if d.isFollowed{
                            CommonFunctions.showUnFollowPopup(d.id, name: d.name) {
                                self.viewModel.actionOnFollowUnfollow(useID: d.id, action: .unfollow ) { (action) in
                                    self.viewModel.allusers.data[indexPath.row].followStatus = .none
                                }
                            }
                        }else{
                            self.viewModel.actionOnFollowUnfollow(useID: d.id, action: .follow) { (action) in
                                self.viewModel.allusers.data[indexPath.row].followStatus = .accepted
                            }
                        }
                    }
                }else{
                    if d.isFollowed{
                        CommonFunctions.showUnFollowPopup(d.id, name: d.name) {
                            self.viewModel.actionOnFollowUnfollow(useID: d.id, action: .unfollow ) { (action) in
                                self.viewModel.allusers.data[indexPath.row].followStatus = .none
                            }
                        }
                    }else{
                        self.viewModel.actionOnFollowUnfollow(useID: d.id, action: .follow) { (action) in
                            self.viewModel.allusers.data[indexPath.row].followStatus = .accepted
                        }
                    }
                }
                tableView.reloadData()
            }
            return cell
        }else if tableView === followingTV{
            let cell = tableView.dequeueCell(with: AllUsersTVCell.self)
            guard viewModel.following.data.count > indexPath.row else { return cell }
            let d = viewModel.following.data[indexPath.row]
            cell.followBtn.isHidden = (d.id == UserModel.main.userId || d.isGuest)
            cell.populateCell(d)
            cell.btnTapped = { [weak self] in
                guard let self = self else { return }
                CommonFunctions.showUnFollowPopup(d.id, name: d.name) {
                    self.viewModel.actionOnFollowUnfollow(useID: d.id, action: d.isFollowed ? .unfollow : .follow) { (action) in
                        self.viewModel.following.data.remove(at: indexPath.row)
                        self.viewModel.following.totalCount -= 1
                        self.updateCounts()
                        tableView.reloadData()
                    }
                }
            }
            return cell
        }else{
            let cell = tableView.dequeueCell(with: AcceptPendingTVCell.self)
            if viewModel.reqType == .sent{
                guard viewModel.sentRequest.data.count > indexPath.row else{ return cell}
            }else{
                guard viewModel.pendingRequest.data.count > indexPath.row else{ return cell}
            }
            let d = viewModel.reqType == .sent ? viewModel.sentRequest.data[indexPath.row] : viewModel.pendingRequest.data[indexPath.row]
            
            if viewModel.reqType == .sent{
                cell.showtwoBtn = false
            }else{
                cell.showtwoBtn = viewModel.pendingRequest.data[indexPath.row].status == .pending
                cell.isAccepted = { [weak self] flag in
                    self?.viewModel.actiononRequest(id: self?.viewModel.pendingRequest.data[indexPath.row].requestId ?? "", flag: flag, completion: { (action) in
                        self?.viewModel.initationsListing(search: "", type: self?.type ?? .sent)
                    })
                }
            }
            cell.populatecell(d)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var id = ""
        if tableView === alluserTableView{
            let d = viewModel.allusers.data[indexPath.row]
            if !d.isGuest{
                CommonFunctions.navigateToUserProfile(d.id)
            }else{
                return
            }
        }else if tableView === followingTV{
            id = viewModel.following.data[indexPath.row].id
        }else{
            if viewModel.reqType == .sent{
                id =  viewModel.sentRequest.data[indexPath.row].id
            }else{
                id =  viewModel.pendingRequest.data[indexPath.row].id
            }
        }
        CommonFunctions.navigateToUserProfile(id)
    }
}
