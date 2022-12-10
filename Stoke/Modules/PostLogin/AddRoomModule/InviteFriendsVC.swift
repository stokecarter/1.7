//
//  InviteFriendsVC.swift
//  Stoke
//
//  Created by Admin on 24/03/21.
//

import UIKit


class InviteFriendsVC: BaseVC {
    /*
    
    @IBOutlet weak var inviteAll: UIButton!
    @IBOutlet weak var inviteSelected: AppButton!
    @IBOutlet weak var searchTF: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var copyUrl: AppButton!
    @IBOutlet weak var copyUrlHeight: NSLayoutConstraint!
    @IBOutlet weak var inviteAllBtnHeight: NSLayoutConstraint!
    
    weak var delegate:InviteFriendsDelegate?
    var viewModel:AddRoomVM!
    var isfromDetail = false
    var inviteVm:InviteVM!
    var roomId:String = ""
    var url:String = ""
    var isFirstTime:Bool = true
    
    var invitedIds:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTF.delegate = self
        copyUrl.btnType = .whiteColor
        if isfromDetail{
            inviteVm = InviteVM(NetworkLayer(), eventId: roomId)
            inviteVm.notifyTOReload = {[weak self] in
                guard let self = self else { return }
                if self.isFirstTime{
                    self.invitedIds = self.inviteVm.followerUserList.data.filter { $0.isInvited}.map { $0.id} + self.inviteVm.followingUserList.data.filter { $0.isInvited}.map { $0.id}
                    self.isFirstTime = false
                }
                let t = self.inviteVm.inviteIds
                self.inviteVm.inviteIds = self.inviteVm.followerUserList.data.filter{ $0.isInvited}.map { $0.id} + self.inviteVm.followingUserList.data.filter{ $0.isInvited}.map { $0.id}
                t.forEach {
                    if !self.inviteVm.inviteIds.contains($0){
                        self.inviteVm.inviteIds.append($0)
                    }
                }
                self.inviteAllBtnHeight.constant = (self.inviteVm.followerUserList.data + self.inviteVm.followingUserList.data).isEmpty ? CGFloat.leastNormalMagnitude : 45
                self.tableView.reloadData()
            }
        }else{
            copyUrlHeight.constant = CGFloat.leastNormalMagnitude
            viewModel.searchQuery = ""
            viewModel.notifyTOReload = { [weak self] in
                guard let self = self else { return }
                if self.isFirstTime{
                    self.invitedIds = self.viewModel.userList.data.filter { $0.isInvited}.map { $0.id} ?? []
                    self.isFirstTime = false
                }
                let t = self.viewModel.inviteIds
                self.viewModel.inviteIds = self.viewModel.userList.data.filter{ $0.isInvited}.map { $0.id}
                t.forEach {
                    if !self.viewModel.inviteIds.contains($0){
                        self.viewModel.inviteIds.append($0)
                    }
                }
                self.inviteAllBtnHeight.constant = self.viewModel.userList.data.isEmpty ? CGFloat.leastNormalMagnitude : 45
                self.tableView.reloadData()
            }
        }
    }
    
    override func initalSetup() {
        tableView.registerCell(with: InviteUserTVCell.self)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.emptyDataSetView { view in
            view.titleLabelString(NSAttributedString(string: "\n\nNo Following User available", attributes: [NSAttributedString.Key.font:AppFonts.Semibold.withSize(16),NSAttributedString.Key.foregroundColor:UIColor.black]))
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

    }
    
    
    @IBAction func copyRoomSharedURL(_ sender: Any) {
        UIPasteboard.general.string = url
        CommonFunctions.showToastWithMessage("Link Copied!", theme: .info)

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
                CommonFunctions.showToastWithMessage("Please select user first")
                return
            }
            inviteVm.inviteusers { [weak self] in
                self?.delegate?.showPending()
                self?.pop()
            }
        }else{
            guard !viewModel.inviteIds.isEmpty else {
                CommonFunctions.showToastWithMessage("Please select user first")
                return
            }
            viewModel.isInviteAll = false
            viewModel.inviteIds = viewModel.userList.data.filter { $0.isInvited}.map { $0.id}
            self.delegate?.updateForEdit()
            pop()
        }
        
    }
    
    @IBAction func inviteAllTapped(_ sender: Any) {
        if isfromDetail{
            inviteVm.isInviteAll = true
            inviteVm.inviteusers { [weak self] in
                self?.delegate?.showPending()
                self?.pop()
            }
        }else{
            viewModel.isInviteAll = true
            self.delegate?.updateForEdit()
            pop()
        }
    }
}

extension InviteFriendsVC : UITextFieldDelegate {
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

extension InviteFriendsVC : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isfromDetail{
            return inviteVm.userList.data.count
        }else{
            return viewModel.userList.data.count
        }
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(with: InviteUserTVCell.self)
        if isfromDetail{
            cell.populateCell(inviteVm.userList.data[indexPath.row])
            if inviteVm.inviteIds.contains(inviteVm.userList.data[indexPath.row].id){
                cell.selectionBtn.isSelected = true
            }
            if self.invitedIds.contains(inviteVm.userList.data[indexPath.row].id){
                cell.selectionBtn.isUserInteractionEnabled = false
            }else{
                cell.selectionBtn.isUserInteractionEnabled = true
            }
            cell.selectionTapped = { [weak self] in
                guard let self = self else { return }
                let id = self.inviteVm.userList.data[indexPath.row].id
                if self.inviteVm.inviteIds.contains(id){
                    if let index = self.inviteVm.inviteIds.firstIndex(of: id){
                        self.inviteVm.inviteIds.remove(at: index)
                        self.inviteVm.userList.data[indexPath.row].isInvited = false
                    }
                }else{
                    self.inviteVm.inviteIds.append(id)
                    self.inviteVm.userList.data[indexPath.row].isInvited = true
                }
                self.tableView.reloadData()
            }
        }else{
            cell.populateCell(viewModel.userList.data[indexPath.row])
            if viewModel.inviteIds.contains(viewModel.userList.data[indexPath.row].id){
                cell.selectionBtn.isSelected = true
            }
            if self.invitedIds.contains(viewModel.userList.data[indexPath.row].id){
                cell.selectionBtn.isUserInteractionEnabled = false
            }else{
                cell.selectionBtn.isUserInteractionEnabled = true
            }
            cell.selectionTapped = { [weak self] in
                guard let self = self else { return }
                let id = self.viewModel.userList.data[indexPath.row].id
                if self.viewModel.inviteIds.contains(id){
                    if let index = self.viewModel.inviteIds.firstIndex(of: id){
                        self.viewModel.inviteIds.remove(at: index)
                        self.viewModel.userList.data[indexPath.row].isInvited = false
                    }
                }else{
                    self.viewModel.inviteIds.append(id)
                    self.viewModel.userList.data[indexPath.row].isInvited = true
                }
                self.tableView.reloadData()
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isfromDetail{
            let id = self.inviteVm.userList.data[indexPath.row].id
            if self.inviteVm.inviteIds.contains(id){
                if let index = self.inviteVm.inviteIds.firstIndex(of: id){
                    self.inviteVm.inviteIds.remove(at: index)
                    self.inviteVm.userList.data[indexPath.row].isInvited = false
                }
            }else{
                self.inviteVm.inviteIds.append(id)
                self.inviteVm.userList.data[indexPath.row].isInvited = true
            }
            self.tableView.reloadData()
        }else{
            let id = self.viewModel.userList.data[indexPath.row].id
            if self.viewModel.inviteIds.contains(id){
                if let index = self.viewModel.inviteIds.firstIndex(of: id){
                    self.viewModel.inviteIds.remove(at: index)
                    self.viewModel.userList.data[indexPath.row].isInvited = false
                }
            }else{
                self.viewModel.inviteIds.append(id)
                self.viewModel.userList.data[indexPath.row].isInvited = true
            }
            self.tableView.reloadData()
        }
    }
 */
}
