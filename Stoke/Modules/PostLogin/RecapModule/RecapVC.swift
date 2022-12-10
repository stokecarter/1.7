//
//  RecapVC.swift
//  Stoke
//
//  Created by Admin on 26/04/21.
//

import UIKit
import AudioToolbox

class RecapVC: BaseVC {
    
    @IBOutlet weak var recapTV: UITableView!
    @IBOutlet weak var allBtn: UIButton!
    @IBOutlet weak var followingBtn: UIButton!
    @IBOutlet weak var myBtn: UIButton!
    @IBOutlet weak var recapTitle: UILabel!
    @IBOutlet weak var guestUserPlaceHolder: UIView!
    @IBOutlet weak var guestUserMsgLabel: UILabel!
    @IBOutlet weak var guestBtn: AppButton!
    @IBOutlet weak var tumbIcon: UIImageView!
    
    var isFromNotification:Bool = false
    var room:ChatRoom?
    var viewModel:RecapVM!
    var isInternetAvilabel:Bool = true{
        didSet{
            if let _ = viewModel{
                viewModel.type = .all
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar(title: room?.name ?? "", backButton: true)
        viewModel = RecapVM(NetworkLayer(), roomId: room?._id ?? "")
        viewModel.reloadTrending = { [weak self] in
            self?.setupemptyScreen()
            self?.recapTV.reloadData()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                guard let self = self else { return }
                guard !self.viewModel.recape.data.isEmpty else { return }
                self.recapTV.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            }
        }
        manageSelectedState(allBtn)
    }
    
    override func initalSetup() {
        recapTV.delegate = self
        recapTV.dataSource = self
        recapTV.registerCell(with: CommnetTVCell.self)
        recapTV.registerCell(with: ReplyThreadTVCell.self)
        recapTV.registerCell(with: CommnetReactionTVCell.self)
        addRightButtonToNavigation(image: #imageLiteral(resourceName: "more-1"))
        setupLongPressGesture()
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isFromNotification{
            navigationController?.setNavigationBarHidden(false, animated: true)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(handelInternetStatus(_:)), name: .internetUpdate, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isFromNotification{
            navigationController?.setNavigationBarHidden(true, animated: true)
        }
        NotificationCenter.default.removeObserver(self, name: .internetUpdate, object: nil)
    }
    
    func setupLongPressGesture() {
        let longPressGesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress))
        longPressGesture.minimumPressDuration = 0.5
        longPressGesture.delegate = self
        self.recapTV.addGestureRecognizer(longPressGesture)
    }
    
    override func rightBarButtonTapped(_ sender: UIButton) {
        let vc = RoomDetailVC.instantiate(fromAppStoryboard: .Events)
        vc.roomId = room?._id ?? ""
        AppRouter.pushFromTabbar(vc)
    }
    
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer){
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        if gestureRecognizer.state == .began {
            let touchPoint = gestureRecognizer.location(in: recapTV)
            if let indexPath = recapTV.indexPathForRow(at: touchPoint) {
                showPopup(index: indexPath.section)
            }
        }
    }
    
    private func showPopup(index:Int){
        if viewModel.recape.data[index].user.id == UserModel.main.userId{
            let vc = TwoBtnPopup.instantiate(fromAppStoryboard: .Home)
            let t = !viewModel.recape.data[index].isCommentSaved ? "Save" : "Unsave"
            vc.btn1Title = t
            vc.btn2Title = "Cancel"
            vc.section = index
            vc.modalPresentationStyle = .overFullScreen
            vc.modalTransitionStyle = .coverVertical
            vc.delagate = self
            present(vc, animated: false, completion: nil)
        }
    }
    
    private func setupemptyScreen(){
        var msg = ""
        switch viewModel.type {
        case .all:
            msg = "\n\nNo Chat Available"
        case .following:
            msg = "\n\nNo one you follow commented"
        case .my:
            msg = "\n\nWe want to hear from you next time!"
        }
        recapTV.emptyDataSetView { view in
            view.titleLabelString(NSAttributedString(string: msg, attributes: [NSAttributedString.Key.font:AppFonts.Semibold.withSize(16),NSAttributedString.Key.foregroundColor:UIColor.black]))
                .image(#imageLiteral(resourceName: "ic-no-chatroom"))
                .didTapDataButton {
                    
                }
                .didTapContentView {
                    // Do something
                }
        }
    }
    
    override func setupFounts() {
        [allBtn,followingBtn,myBtn].forEach {
            $0?.setTitleColor(AppColors.labelColor, for: .normal)
            $0?.setTitleColor(AppColors.themeColor, for: .selected)
            $0?.titleLabel?.font = AppFonts.Medium.withSize(14)
        }
        recapTitle.font = AppFonts.Semibold.withSize(14)
    }
    
    @IBAction func trendingBtnSelection(_ sender: UIButton) {
        manageSelectedState(sender)
    }
    
    @IBAction func guestLoginTapped(_ sender: Any) {
        UserModel.main = UserModel()
        AppRouter.checkUserFlow()
    }
    
    
    private func manageSelectedState(_ sender:UIButton){
        if CommonFunctions.isGuestLogin || UserModel.main.isAdmin{
            manageGuestuserLabel(sender)
        }
        switch sender {
        case allBtn:
            if CommonFunctions.isGuestLogin || UserModel.main.isAdmin{
                guestUserPlaceHolder.isHidden = true
            }
            viewModel.type = .all
            sender.addShadow()
            sender.isSelected = true
            followingBtn.isSelected = false
            myBtn.isSelected = false
            followingBtn.dropShadow()
            myBtn.dropShadow()
        case followingBtn:
            if CommonFunctions.isGuestLogin || UserModel.main.isAdmin{
                guestUserPlaceHolder.isHidden = false
            }
            viewModel.type = .following
            sender.isSelected = true
            allBtn.isSelected = false
            myBtn.isSelected = false
            sender.addShadow()
            allBtn.dropShadow()
            myBtn.dropShadow()
        default:
            if CommonFunctions.isGuestLogin || UserModel.main.isAdmin{
                guestUserPlaceHolder.isHidden = false
            }
            viewModel.type = .my
            sender.isSelected = true
            followingBtn.isSelected = false
            allBtn.isSelected = false
            sender.addShadow()
            followingBtn.dropShadow()
            allBtn.dropShadow()
        }
    }
    
    private func manageGuestuserLabel(_ sender:UIButton){
        if CommonFunctions.isGuestLogin{
            switch sender {
            case allBtn:
                guestUserMsgLabel.text = "You must be logged in to view this page"
            case followingBtn:
                guestUserMsgLabel.text = "You must be logged in to view this page"
            default:
                guestUserMsgLabel.text = "You must be logged in to view this page"
            }
        }else if UserModel.main.isAdmin{
            guestBtn.isHidden = true
            tumbIcon.image = #imageLiteral(resourceName: "ic_signup_login")
            switch sender {
            case allBtn:
                guestUserMsgLabel.text = "You are login as a Stoke"
            case followingBtn:
                guestUserMsgLabel.text = "You are login as a Stoke"
            default:
                guestUserMsgLabel.text = "You are login as a Stoke"
            }
        }
    }
    
    private func presentReplyThread(_ index:Int,isFromTrending:Bool = false){
        let vc = ReplyThreadVC.instantiate(fromAppStoryboard: .Chat)
        vc.roomId = room?._id ?? ""
        vc.isFromTrending = isFromTrending
        vc.commentId = viewModel.recape.data[index]._id
        vc.commnet = viewModel.recape.data[index]
        vc.modalTransitionStyle = .coverVertical
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: false, completion: nil)
    }
    
    @objc func handelInternetStatus(_ sender:NSNotification){
        if let dict =  sender.object as? [String:Bool]{
            if let status = dict["status"]{
                isInternetAvilabel = status
            }
        }
    }
}


extension RecapVC : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel != nil ? viewModel.recape.data.count : 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueCell(with: CommnetTVCell.self)
            cell.openProfileTapped = { [weak self] in
                CommonFunctions.navigateToUserProfile(self?.viewModel.recape.data[indexPath.section].user.id ?? "",onParent: self)
            }
            cell.populateCell(viewModel.recape.data[indexPath.section],index: viewModel.type == .all ? indexPath.section + 1 : nil)
            return cell
        case 1:
            let cell = tableView.dequeueCell(with: ReplyThreadTVCell.self)
            cell.clipsToBounds = true
            cell.populateCell(viewModel.recape.data[indexPath.section].user_reply.first)
            cell.seeThread = { [weak self] in
                self?.presentReplyThread(indexPath.section,isFromTrending: true)
            }
            cell.isIndexing = viewModel.type == .all ? true : nil
            return cell
        default:
            let cell = tableView.dequeueCell(with: CommnetReactionTVCell.self)
            cell.populateCommnetReacts(model: viewModel.recape.data[indexPath.section])
            cell.indexing = viewModel.type == .all ? 1 : nil
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 1{
            return viewModel.recape.data[indexPath.section].user_reply.isEmpty ? CGFloat.leastNormalMagnitude : UITableView.automaticDimension
        }else{
            return UITableView.automaticDimension
        }
    }
}



extension RecapVC : ThreeBtnPopupDelegate{
    func getUserChoice(_ index:Int,section:Int) {
        
        if viewModel.recape.data[section].user.id == UserModel.main.userId{
            if index == 0{
                let c = viewModel.recape.data[section]
                viewModel.hitSaveComment(c._id, action: !c.isCommentSaved) { [weak self] in
                    self?.viewModel.recape.data[section].isCommentSaved.toggle()
                }
            }else{
                printDebug("do noting...")
            }
        }
    }
    
}

extension RecapVC : DeleteChatRoomPopupDelegate {
    func deleteTapped(index:Int) {
        viewModel.hitReportComment(viewModel.recape.data[index]._id) { [weak self] in
            self?.recapTV.reloadData()
        }
    }
}
