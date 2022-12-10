//
//  InviteUsersVC.swift
//  Stoke
//
//  Created by Admin on 08/06/21.
//

import UIKit

protocol InviteFriendsDelegate:AnyObject {
    func showPending()
    func updateForEdit()
}

extension InviteFriendsDelegate {
    func updateForEdit(){}
    func showPending(){}
}

class InviteUsersVC: BaseVC {
    
    @IBOutlet weak var inviteAll: UIButton!
    @IBOutlet weak var inviteSelected: AppButton!
    
    @IBOutlet weak var copyUrl: AppButton!
    @IBOutlet weak var copyUrlHeight: NSLayoutConstraint!
    @IBOutlet weak var inviteAllBtnHeight: NSLayoutConstraint!
    
    @IBOutlet weak var followBtn: UIButton!
    @IBOutlet weak var followingBtn: UIButton!
    @IBOutlet weak var sliderContainerView: UIView!
    @IBOutlet weak var slidderView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var followSearchTF: UITextField!
    @IBOutlet weak var followTableView: UITableView!
    @IBOutlet weak var followingSearchTF: UITextField!
    @IBOutlet weak var followingTableView: UITableView!
    
    
    weak var delegate:InviteFriendsDelegate?
    var isSelectAll:Bool = false{
        didSet{
            if isSelectAll{
                if self.isfromDetail{
                    if inviteVm.type == .follow{
                        for i in 0..<inviteVm.followerUserList.data.count{
                            if !inviteVm.followerUserList.data[i].isInvited{
                                self.inviteVm.inviteIds.append(inviteVm.followerUserList.data[i].id)
                            }
                        }
                        followTableView.reloadData()
                    }else{
                        for i in 0..<inviteVm.followingUserList.data.count{
                            if !inviteVm.followingUserList.data[i].isInvited{
                                self.inviteVm.inviteIds.append(inviteVm.followingUserList.data[i].id)
                            }
                        }
                        followingTableView.reloadData()
                    }
                }else{
                    for i in 0..<viewModel.userList.data.count{
                        if !viewModel.userList.data[i].isInvited{
                            self.viewModel.inviteIds.append(viewModel.userList.data[i].id)
                        }
                    }
                    if viewModel.type == .follow{
                        followTableView.reloadData()
                    }else{
                        followingTableView.reloadData()
                    }
                }
            }else{
                if self.isfromDetail{
                    self.inviteVm.inviteIds.removeAll()
                    if inviteVm.type == .follow{
                        followTableView.reloadData()
                    }else{
                        followingTableView.reloadData()
                    }
                }else{
                    self.viewModel.inviteIds.removeAll()
                    if viewModel.type == .follow{
                        followTableView.reloadData()
                    }else{
                        followingTableView.reloadData()
                    }
                }
            }
        }
    }
    
    var viewModel:AddRoomVM!
    var isfromDetail = false
    var inviteVm:InviteVM!
    var roomId:String = ""
    var url:String = ""
    var isFirstTime:Bool = true
    
//    var invitedIds:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        [followSearchTF,followingSearchTF].forEach {
            $0?.delegate = self
            $0?.addTarget(self, action: #selector(textFieldDidChangeCharacters(_:)), for: .editingChanged)
        }
        copyUrl.btnType = .whiteColor
        scrollView.delegate = self
        if isfromDetail{
            setSelectedButton(followBtn)
            inviteVm = InviteVM(NetworkLayer(), eventId: roomId)
            inviteVm.searchQuery = ""
            inviteVm.notifyTOReload = {[weak self] in
                guard let self = self else { return }
                self.inviteAllBtnHeight.constant = (self.inviteVm.followerUserList.data + self.inviteVm.followingUserList.data).isEmpty ? CGFloat.leastNormalMagnitude : 45
                self.followTableView.reloadData()
                self.followingTableView.reloadData()
            }
        }else{
            setSelectedButton(followBtn)
            copyUrlHeight.constant = CGFloat.leastNormalMagnitude
            viewModel.searchQuery = ""
            viewModel.notifyTOReload = { [weak self] in
                guard let self = self else { return }
                self.inviteAllBtnHeight.constant = self.viewModel.userList.data.isEmpty ? CGFloat.leastNormalMagnitude : 45
                self.followTableView.reloadData()
                self.followingTableView.reloadData()
            }
        }
    }
    
    override func initalSetup() {
        [followTableView,followingTableView].forEach{
            $0?.registerCell(with: InviteUserTVCell.self)
            $0?.delegate = self
            $0?.dataSource = self
            $0?.emptyDataSetView { view in
                view.titleLabelString(NSAttributedString(string: "\n\nNo Following User available", attributes: [NSAttributedString.Key.font:AppFonts.Semibold.withSize(16),NSAttributedString.Key.foregroundColor:UIColor.black]))
                    .image(#imageLiteral(resourceName: "no_user"))
                    .didTapDataButton {
                        
                    }
                    .didTapContentView {
                        // Do something
                    }
            }
        }
        followTableView.emptyDataSetView { view in
            view.titleLabelString(NSAttributedString(string: "\n\nWhen people follow you they will appear here!", attributes: [NSAttributedString.Key.font:AppFonts.Semibold.withSize(16),NSAttributedString.Key.foregroundColor:UIColor.black]))
                .image(#imageLiteral(resourceName: "no_user"))
                .didTapDataButton {
                    
                }
                .didTapContentView {
                    // Do something
                }
        }
        followingTableView.emptyDataSetView { view in
            view.titleLabelString(NSAttributedString(string: "\n\nWhen you follow other people they will appear here!", attributes: [NSAttributedString.Key.font:AppFonts.Semibold.withSize(16),NSAttributedString.Key.foregroundColor:UIColor.black]))
                .image(#imageLiteral(resourceName: "no_user"))
                .didTapDataButton {
                    
                }
                .didTapContentView {
                    // Do something
                }
        }
    }
    
    override func setupFounts() {
        inviteSelected.btnType = .themeColor
        setNavigationBar(title: "Invite Friends", backButton: true)
        [followBtn,followingBtn].forEach { $0?.setTitleColor(AppColors.themeColor, for: .selected)
            $0?.setTitleColor(#colorLiteral(red: 0.7882352941, green: 0.7882352941, blue: 0.7882352941, alpha: 1), for: .normal)
            $0?.setTitleColor(AppColors.themeColor, for: .selected)
            $0?.titleLabel?.font = AppFonts.Medium.withSize(16)
        }
        
    }
    
    
    @IBAction func followerTapped(_ sender: Any) {
        setSelectedButton(followBtn)
        scrollView.setContentOffset(CGPoint.zero, animated: true)
    }
    
    @IBAction func followingTapped(_ sender: Any) {
        setSelectedButton(followingBtn)
        self.scrollView.setContentOffset(CGPoint(x: self.view.bounds.width, y: 0), animated: true)
    }
    
    @IBAction func copyRoomSharedURL(_ sender: Any) {
        UIPasteboard.general.string = url
        CommonFunctions.showToastWithMessage("Link copied.", theme: .success)
        
    }
    
    @IBAction func textFieldDidChangeCharacters(_ sender: UITextField) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [unowned self] in
            if self.isfromDetail{
                self.inviteVm.searchQuery = sender.text ?? ""
            }else{
                self.viewModel.searchQuery = sender.text ?? ""
            }
        }
    }
    
    
    @IBAction func inviteSelectedTapped(_ sender: Any) {
        if isfromDetail{
            inviteVm.isInviteAll = false
            guard !inviteVm.inviteIds.isEmpty else {
                CommonFunctions.showToastWithMessage("Please select at least one person.")
                return
            }
            inviteVm.inviteusers { [weak self] in
                self?.delegate?.showPending()
                self?.pop()
            }
        }else{
            guard !viewModel.inviteIds.isEmpty else {
                CommonFunctions.showToastWithMessage("Please select at least one person.")
                return
            }
            viewModel.isInviteAll = false
            self.delegate?.updateForEdit()
            pop()
        }
        
    }
    
    @IBAction func inviteAllTapped(_ sender: Any) {
        isSelectAll = !isSelectAll
//        if isfromDetail{
//            inviteVm.isInviteAll = true
//            inviteVm.inviteusers { [weak self] in
//                self?.delegate?.showPending()
//                self?.pop()
//            }
//        }else{
//            viewModel.isInviteAll = true
//            self.delegate?.updateForEdit()
//            pop()
//        }
    }
    
    private func setSelectedButton(_ sender:UIButton){
        followBtn.isSelected   = sender === followBtn ? true:false
        followingBtn.isSelected   = sender === followingBtn ? true:false
    }
}

extension InviteUsersVC : UITextFieldDelegate {
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        textField.text = nil
        view.endEditing(true)
        if isfromDetail{
            inviteVm.searchQuery = ""
        }else{
            viewModel.searchQuery = ""
        }
        return false
    }
    
}

extension InviteUsersVC : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView === followTableView{
            if isfromDetail{
                return inviteVm.followerUserList.data.count
            }else{
                return viewModel.userList.data.count
            }
        }else{
            if isfromDetail{
                return inviteVm.followingUserList.data.count
            }else{
                return viewModel.userList.data.count
            }
        }
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView === followTableView{
            let cell = tableView.dequeueCell(with: InviteUserTVCell.self)
            if isfromDetail{
                let data = self.inviteVm.followerUserList.data[indexPath.row]
                cell.populateCell(data)
                if inviteVm.inviteIds.contains(data.id){
                    cell.selectionBtn.isSelected = true
                }
                cell.selectionTapped = { [weak self] in
                    guard let self = self else { return }
                    if self.inviteVm.inviteIds.contains(data.id){
                        if let index = self.inviteVm.inviteIds.firstIndex(of: data.id){
                            self.inviteVm.inviteIds.remove(at: index)
                        }
                    }else{
                        self.inviteVm.inviteIds.append(data.id)
                    }
                    tableView.reloadData()
                }
            }else{
                cell.populateCell(viewModel.userList.data[indexPath.row])
                if viewModel.inviteIds.contains(viewModel.userList.data[indexPath.row].id){
                    cell.selectionBtn.isSelected = true
                }
                cell.selectionTapped = { [weak self] in
                    guard let self = self else { return }
                    let id = self.viewModel.userList.data[indexPath.row].id
                    if self.viewModel.inviteIds.contains(id){
                        if let index = self.viewModel.inviteIds.firstIndex(of: id){
                            self.viewModel.inviteIds.remove(at: index)
                        }
                    }else{
                        self.viewModel.inviteIds.append(id)
                    }
                    tableView.reloadData()
                }
            }
            return cell
        }else{
            let cell = tableView.dequeueCell(with: InviteUserTVCell.self)
            if isfromDetail{
                let data = self.inviteVm.followingUserList.data[indexPath.row]
                cell.populateCell(data)
                if inviteVm.inviteIds.contains(data.id){
                    cell.selectionBtn.isSelected = true
                }
                cell.selectionTapped = { [weak self] in
                    guard let self = self else { return }
                    if self.inviteVm.inviteIds.contains(data.id){
                        if let index = self.inviteVm.inviteIds.firstIndex(of: data.id){
                            self.inviteVm.inviteIds.remove(at: index)
                        }
                    }else{
                        self.inviteVm.inviteIds.append(data.id)
                    }
                    tableView.reloadData()
                }
            }else{
                cell.populateCell(viewModel.userList.data[indexPath.row])
                if viewModel.inviteIds.contains(viewModel.userList.data[indexPath.row].id){
                    cell.selectionBtn.isSelected = true
                }
                cell.selectionTapped = { [weak self] in
                    guard let self = self else { return }
                    let id = self.viewModel.userList.data[indexPath.row].id
                    if self.viewModel.inviteIds.contains(id){
                        if let index = self.viewModel.inviteIds.firstIndex(of: id){
                            self.viewModel.inviteIds.remove(at: index)
                        }
                    }else{
                        self.viewModel.inviteIds.append(id)
                    }
                    tableView.reloadData()
                }
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView === followTableView{
            if isfromDetail{
                let data = self.inviteVm.followerUserList.data[indexPath.row]
                if !data.isInvited{
                    let id = data.id
                    if self.inviteVm.inviteIds.contains(id){
                        if let index = self.inviteVm.inviteIds.firstIndex(of: id){
                            self.inviteVm.inviteIds.remove(at: index)
                        }
                    }else{
                        self.inviteVm.inviteIds.append(id)
                    }
                    tableView.reloadData()
                }else{
                    printDebug("Already Invited.....")
                }
            }else{
                if !self.viewModel.userList.data[indexPath.row].isInvited{
                    let id = self.viewModel.userList.data[indexPath.row].id
                    if self.viewModel.inviteIds.contains(id){
                        if let index = self.viewModel.inviteIds.firstIndex(of: id){
                            self.viewModel.inviteIds.remove(at: index)
                        }
                    }else{
                        self.viewModel.inviteIds.append(id)
                    }
                    tableView.reloadData()
                }else{
                    printDebug("Already Invited.....")
                }
            }
        }else{
            if isfromDetail{
                let data = self.inviteVm.followingUserList.data[indexPath.row]
                if !data.isInvited{
                    let id = data.id
                    if self.inviteVm.inviteIds.contains(id){
                        if let index = self.inviteVm.inviteIds.firstIndex(of: id){
                            self.inviteVm.inviteIds.remove(at: index)
                        }
                    }else{
                        self.inviteVm.inviteIds.append(id)
                    }
                    tableView.reloadData()
                }else{
                    printDebug("Already Invited.....")
                }
            }else{
                if !self.viewModel.userList.data[indexPath.row].isInvited{
                    let id = self.viewModel.userList.data[indexPath.row].id
                    if self.viewModel.inviteIds.contains(id){
                        if let index = self.viewModel.inviteIds.firstIndex(of: id){
                            self.viewModel.inviteIds.remove(at: index)
                        }
                    }else{
                        self.viewModel.inviteIds.append(id)
                    }
                    tableView.reloadData()
                }else{
                    printDebug("Already Invited.....")
                }
            }
        }
    }
}


extension InviteUsersVC : UIScrollViewDelegate    {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView)    {
        guard scrollView === self.scrollView else { return }
        let width = scrollView.width/slidderView.width
        let scroll = scrollView.contentOffset.x
        slidderView.transform = CGAffineTransform(translationX: scroll/width, y: 0)
        switch scroll {
        case  0:
            if isfromDetail{
                inviteVm.type = .follow
            }else{
                viewModel.type = .follow
            }
            setSelectedButton(followBtn)
            followTableView.reloadData()
        case  UIDevice.width :
            if isfromDetail{
                inviteVm.type = .following
            }else{
                viewModel.type = .following
            
            }
            setSelectedButton(followingBtn)
            followingTableView.reloadData()
        default :
            break
        }
    }
}
