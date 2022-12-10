//
//  TwoTabsTVCell.swift
//  Stoke
//
//  Created by Admin on 13/04/21.
//

import UIKit

class TwoTabsTVCell: UITableViewCell {
    
    
    @IBOutlet weak var allUsersBtn: UIButton!
    @IBOutlet weak var followingBtn: UIButton!
    @IBOutlet weak var allusersearchTF: UITextField!
    @IBOutlet weak var alluserTableView: UITableView!
    @IBOutlet weak var followingSearchTF: UITextField!
    @IBOutlet weak var followingTV: UITableView!
    @IBOutlet weak var sliderContainerView: UIView!
    @IBOutlet weak var slidderView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var loginBtn: AppButton!
    @IBOutlet weak var guestThumb: UIImageView!
    @IBOutlet weak var guestUsermsglabel: UILabel!
    @IBOutlet weak var guestview: UIView!
    var viewModel:TwoTabsVM!
    
    var openUserProfile:((String)->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
        allUsersBtn.isSelected = true
        scrollView.delegate = self
        setupFounts()
        [alluserTableView,followingTV].forEach {
            $0?.delegate = self
            $0?.dataSource = self
            $0?.registerCell(with: AllUsersTVCell.self)
        }
        [allusersearchTF,followingSearchTF].forEach {
            $0?.delegate = self
            $0?.addTarget(self, action: #selector(editingChanged(_:)), for: .editingChanged)
        }
        alluserTableView.emptyDataSetView { view in
            view.titleLabelString(NSAttributedString(string: "\n\nNo one is here yet. Invite your friends!", attributes: [NSAttributedString.Key.font:AppFonts.Semibold.withSize(16),NSAttributedString.Key.foregroundColor:UIColor.black]))
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
        manageGuestUserMsg(sender: allUsersBtn)
    }
    
    
    private func setupView(){
        if CommonFunctions.isGuestLogin{
            guestview.isHidden = false
        }else if UserModel.main.isAdmin{
            guestview.isHidden = !allUsersBtn.isSelected
        }else{
            guestview.isHidden = true
        }
    }
    
    @IBAction func alUsersTapped(_ sender: UIButton) {
        setSelectedButton(sender)
        scrollView.setContentOffset(CGPoint.zero, animated: true)
    }
    
    @IBAction func followingTapped(_ sender: UIButton) {
        setSelectedButton(sender)
        scrollView.setContentOffset(CGPoint(x: self.contentView.bounds.width, y: 0), animated: true)
    }
    
    @objc func editingChanged(_ textField:UITextField){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            if textField === self?.allusersearchTF{
                self?.viewModel.hitAllUserList(search: textField.text ?? "", type: .all)
            }else{
                self?.viewModel.hitAllUserList(search: textField.text ?? "", type: .following)
            }
        }
    }
    
    private func manageGuestUserMsg(sender:UIButton){
        if CommonFunctions.isGuestLogin{
            if sender === allUsersBtn{
                guestUsermsglabel.text = "You must be logged in to view this page"
            }else{
                guestUsermsglabel.text = "You must be logged in to view this page"
            }
        }else if UserModel.main.isAdmin{
            guestThumb.image = #imageLiteral(resourceName: "ic_signup_login")
            loginBtn.isHidden  = true
            if sender === allUsersBtn{
                guestview.isHidden = true
            }else{
                guestview.isHidden = false
                guestUsermsglabel.text = "You are login as a admin"
            }
        }
        
    }
    
    private func setupFounts() {
        allUsersBtn.isSelected = true
        setBtnTitle()
        [allUsersBtn,followingBtn].forEach { $0?.setTitleColor(AppColors.themeColor, for: .selected)
            $0?.setTitleColor(#colorLiteral(red: 0.7882352941, green: 0.7882352941, blue: 0.7882352941, alpha: 1), for: .normal)
            $0?.titleLabel?.font = AppFonts.Semibold.withSize(14)
        }
    }
    
    func populateCell(_ room:ChatRoom){
        viewModel = TwoTabsVM(NetworkLayer(), room: room)
        viewModel.notify = { [weak self] in
            self?.updateCounts()
            self?.followingTV.reloadData()
            self?.alluserTableView.reloadData()
        }
        
    }
    
    private func updateCounts(){
        setBtnTitle(allUsers: viewModel.allusers.totalCount, allFollowers: viewModel.following.totalCount)
    }
    
    private func setSelectedButton(_ sender:UIButton){
        manageGuestUserMsg(sender: sender)
        allUsersBtn.isSelected   = sender === allUsersBtn ? true:false
        followingBtn.isSelected   = sender === followingBtn ? true:false
    }
    
    private func setBtnTitle(allUsers:Int? = nil, allFollowers:Int? = nil){
//        let t1 = allUsers != nil ? "All Users (\(allUsers!))" : "All Users"
//        let t2 = allFollowers != nil ? "Following (\(allFollowers!))" : "Following"
        allUsersBtn.setTitle("All Users", for: .normal)
        followingBtn.setTitle("Following", for: .normal)
    }
    
    @IBAction func guestviewTapped(_ sender: Any) {
        UserModel.main = UserModel()
        AppRouter.checkUserFlow()
    }
    
}

extension TwoTabsTVCell : UITextFieldDelegate {
    
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

extension TwoTabsTVCell : UIScrollViewDelegate {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView)    {
        guard self.scrollView === scrollView else {
            return
        }
        let width = scrollView.width/slidderView.width
        let scroll = scrollView.contentOffset.x
        slidderView.transform = CGAffineTransform(translationX: scroll/width, y: 0)
        switch scroll {
        case  0:
            setSelectedButton(allUsersBtn)
        case  UIDevice.width :
            setSelectedButton(followingBtn)
        default :
            break
        }
    }
}


extension TwoTabsTVCell : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView === alluserTableView{
            guard viewModel != nil else{ return 0}
            return viewModel.allusers.data.count
        }else{
            guard viewModel != nil else{ return 0}
            return viewModel.following.data.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(with: AllUsersTVCell.self)
        if tableView === alluserTableView{
            guard viewModel.allusers.data.count > indexPath.row else {
                return cell
            }
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
                        CommonFunctions.showUnFollowPopup(d.id, name: d.name) {
                            self.viewModel.actionOnFollowUnfollow(useID: d.id, action: d.isFollowed ? .unfollow : .follow) { (action) in
                                self.viewModel.allusers.data[indexPath.row].followStatus = .none
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
                        self.viewModel.actionOnFollowUnfollow(useID: d.id, action: .follow ) { (action) in
                            self.viewModel.allusers.data[indexPath.row].followStatus = .accepted
                        }
                    }
                }
                tableView.reloadData()
            }
        }else{
            guard viewModel.following.data.count > indexPath.row else {
                return cell
            }
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
        }
        return cell

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView === alluserTableView{
            let d = viewModel.allusers.data[indexPath.row]
            if !d.isGuest{
                if let t = openUserProfile { t(d.id)}
            }
        }else{
            let d = viewModel.following.data[indexPath.row]
            if !d.isGuest{
                if let t = openUserProfile { t(d.id)}
            }
        }
    }
}
