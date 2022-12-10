//
//  FollowFollowingVC.swift
//  Stoke
//
//  Created by Admin on 18/05/21.
//

import UIKit

class FollowFollowingVC: BaseVC {
    
    
    @IBOutlet weak var followingBtn: UIButton!
    @IBOutlet weak var followersBtn: UIButton!
    @IBOutlet weak var searchTf: UITextField!
    @IBOutlet weak var slidderView: UIView!
    @IBOutlet weak var followerTableView: UITableView!
    @IBOutlet weak var followingTableView: UITableView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    var viewModel:FollowFollowingVM!
    var userName:String!
    var userId:String!
    var showFollowers:Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = FollowFollowingVM(NetworkLayer(),userId:userId)
        viewModel.type = showFollowers ? .follow : .following
        scrollView.delegate = self
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if self.showFollowers{
                self.setSelectedButton(self.followersBtn)
                self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
            }else{
                self.setSelectedButton(self.followingBtn)
                self.scrollView.setContentOffset(CGPoint(x: UIDevice.width, y: 0), animated: true)
            }
        }
        viewModel.refresh = { [weak self] in
            self?.manageEmptyScreen()
            self?.updateBtnTitle()
            self?.followerTableView.reloadData()
            self?.followingTableView.reloadData()
        }
        [followerTableView,followingTableView].forEach {
            $0?.delegate = self
            $0?.dataSource = self
            $0?.registerCell(with: BlockUserListTVCell.self)
        }
        searchTf.addTarget(self, action: #selector(textFiedChangeEditing(_:)), for: .editingChanged)
        searchTf.delegate = self
        manageEmptyScreen()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let _ = viewModel{
            viewModel.hitFollowList()
            viewModel.hitFollowerList()
        }
    }
    
    override func setupFounts() {
        setNavigationBar(title: userName, backButton: true)
        followersBtn.setTitle("Followers", for: .normal)
        followingBtn.setTitle("Following", for: .normal)
        [followingBtn,followersBtn].forEach {
            $0?.setTitleColor(AppColors.themeColor, for: .selected)
            $0?.setTitleColor(#colorLiteral(red: 0.7882352941, green: 0.7882352941, blue: 0.7882352941, alpha: 1), for: .normal)
            $0?.titleLabel?.font = AppFonts.Medium.withSize(14)
        }
        
    }
    @objc func textFiedChangeEditing(_ textField:UITextField){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [unowned self] in
            self.viewModel.search = textField.text ?? ""
        }
    }
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        if sender === followersBtn{
            scrollView.setContentOffset(CGPoint.zero, animated: true)
        }else{
            self.scrollView.setContentOffset(CGPoint(x: self.view.bounds.width, y: 0), animated: true)
        }
    }
    
    
    private func manageEmptyScreen(){
        followerTableView.emptyDataSetView { view in
            view.titleLabelString(NSAttributedString(string: "\n\nYou don’t have any followers yet!", attributes: [NSAttributedString.Key.font:AppFonts.Semibold.withSize(16),NSAttributedString.Key.foregroundColor:UIColor.black]))
                .image(#imageLiteral(resourceName: "no_user"))
        }
        followingTableView.emptyDataSetView { view in
            view.titleLabelString(NSAttributedString(string: "\n\nYou don’t follow anyone yet!", attributes: [NSAttributedString.Key.font:AppFonts.Semibold.withSize(16),NSAttributedString.Key.foregroundColor:UIColor.black]))
                .image(#imageLiteral(resourceName: "no_user"))
        }
    }
        
    
    
    private func updateBtnTitle(){
        followersBtn.setTitle("Followers(\(viewModel.follow.totalCount))", for: .normal)
        followingBtn.setTitle("Following(\(viewModel.following.totalCount))", for: .normal)
    }
    
    func showFollowPopup(id:String,name:String) {
        let vc = GenericPopupVC.instantiate(fromAppStoryboard: .Chat)
        vc.delegate = self
        vc.isForDelete = true
        vc.headingText = "Follow \(name)?"
        vc.subheadingTxt = "Are you sure you want to follow back this user?"
        vc.firstbtnTitle = "Cancel"
        vc.secondbtnTitle = "Follow"
        vc.id = id
        vc.modalTransitionStyle = .coverVertical
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: false, completion: nil)
    }
    
    func showCancelRequestPopup(id:String,name:String) {
        let vc = GenericPopupVC.instantiate(fromAppStoryboard: .Chat)
        vc.delegate = self
        vc.isForDelete = false
        vc.headingText = "Delete Request?"
        vc.subheadingTxt = "Are you sure you want to delete follow request for this user?"
        vc.firstbtnTitle = "Cancel"
        vc.secondbtnTitle = "Delete"
        vc.id = id
        vc.modalTransitionStyle = .coverVertical
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: false, completion: nil)
    }
    
    func showUnfollowPopup(id:String,name:String) {
        let vc = GenericPopupVC.instantiate(fromAppStoryboard: .Chat)
        vc.delegate = self
        vc.isForDelete = false
        vc.headingText = "Unfollow \(name)?"
        vc.subheadingTxt = "Are you sure you want to unfollow this user?"
        vc.firstbtnTitle = "Cancel"
        vc.secondbtnTitle = "Unfollow"
        vc.id = id
        vc.modalTransitionStyle = .coverVertical
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: false, completion: nil)
    }
    
    private func presentGuestView(){
        let vc = GuestUserPopupVC.instantiate(fromAppStoryboard: .Home)
        vc.modalTransitionStyle = .coverVertical
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: false, completion: nil)
    }
    
    private func setSelectedButton(_ sender:UIButton){
        followersBtn.isSelected   = sender === followersBtn ? true:false
        followingBtn.isSelected   = sender === followingBtn ? true:false
        
    }
}

extension FollowFollowingVC : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView === followerTableView{
            return viewModel.follow.data.count
        }else{
            return viewModel.following.data.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(with: BlockUserListTVCell.self)
        if tableView === followerTableView{
            cell.populateFollower(viewModel.follow.data[indexPath.row])
            cell.tapped = { [weak self] in
                if CommonFunctions.isGuestLogin{
                    //                    self?.presentGuestView()
                }else{
                    if let d = self?.viewModel.follow.data[indexPath.row]{
                        if d.followStatus == .accepted{
                            self?.showUnfollowPopup(id: d.id, name: d.userName)
                        }else if d.followStatus == .pending{
                            self?.showCancelRequestPopup(id: d.id, name: d.userName)
                        } else{
                            self?.viewModel.followUser(d.id) { [weak self] in
                                self?.viewModel.hitFollowList()
                                self?.viewModel.hitFollowerList()
                            }
                        }
                    }
                }
            }
        }else{
            cell.populateFollowing(viewModel.following.data[indexPath.row])
            
            cell.tapped = { [weak self] in
                if UserModel.main.userId == self?.userId{
                    if !CommonFunctions.isGuestLogin{
                        self?.showUnfollowPopup(id: self?.viewModel.following.data[indexPath.row].id ?? "", name: self?.viewModel.following.data[indexPath.row].userName ?? "")
                    }
                }else{
                    if let d = self?.viewModel.following.data[indexPath.row]{
                        if d.followStatus == .accepted{
                            self?.showUnfollowPopup(id: d.id, name: d.userName)
                        }else if d.followStatus == .pending{
                            self?.showCancelRequestPopup(id: d.id, name: d.userName)
                        } else{
                            self?.viewModel.followUser(d.id) { [weak self] in
                                self?.viewModel.hitFollowList()
                                self?.viewModel.hitFollowerList()
                            }
                        }
                    }
                }
            }
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let id = tableView == followerTableView ? viewModel.follow.data[indexPath.row].id : viewModel.following.data[indexPath.row].id
        CommonFunctions.navigateToUserProfile(id,onParent: self)
    }
}

extension FollowFollowingVC : UITextFieldDelegate {
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        textField.text = nil
        view.endEditing(true)
        viewModel.search = ""
        return false
    }
}


extension FollowFollowingVC : GenericPopupDelegate {
    func optionTapped(_ flag: Bool, isDelete: Bool, id: String) {
        if flag{
            if !isDelete{
                if viewModel.type == .follow{
                    if let index = viewModel.follow.data.firstIndex(where: { $0.id == id}){
                        let u = viewModel.follow.data[index]
                        if u.isPrivateAccount{
                            if u.followStatus == .pending{
                                CommonFunctions.actionOnFollowRequest(.cancel, id: id) { [weak self] in
                                    self?.viewModel.hitFollowList()
                                    self?.viewModel.hitFollowerList()
                                }
                            }else if u.followStatus == .accepted{
                                viewModel.unfollowUser(id) { [weak self] in
                                    self?.viewModel.hitFollowList()
                                    self?.viewModel.hitFollowerList()
                                }
                            }else{
                                viewModel.followUser(id) { [weak self] in
                                    self?.viewModel.hitFollowList()
                                    self?.viewModel.hitFollowerList()
                                }
                            }
                        }else{
                            if u.isFollowed{
                                viewModel.unfollowUser(id) { [weak self] in
                                    self?.viewModel.hitFollowList()
                                    self?.viewModel.hitFollowerList()
                                }
                            }else{
                                viewModel.followUser(id) { [weak self] in
                                    self?.viewModel.hitFollowList()
                                    self?.viewModel.hitFollowerList()
                                }
                            }
                        }
                    }else{
                        printDebug("Doom ....")
                    }
                }else{
                    viewModel.unfollowUser(id) { [weak self] in
                        self?.viewModel.hitFollowList()
                        self?.viewModel.hitFollowerList()
                    }
                }
            }else{
                viewModel.followUser(id) { [weak self] in
                    self?.viewModel.hitFollowList()
                    self?.viewModel.hitFollowerList()
                }
            }
        }
    }
}

extension FollowFollowingVC : UIScrollViewDelegate{
    public func scrollViewDidScroll(_ scrollView: UIScrollView)    {
        guard self.scrollView === scrollView else { return }
        let width = scrollView.width/slidderView.width
        let scroll = scrollView.contentOffset.x
        slidderView.transform = CGAffineTransform(translationX: scroll/width, y: 0)
        switch scroll {
        case  0:
            setSelectedButton(followersBtn)
            viewModel.type = .follow
        case  UIDevice.width :
            setSelectedButton(followingBtn)
            viewModel.type = .following
        default :
            break
        }
    }
    
}
