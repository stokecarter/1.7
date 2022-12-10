//
//  ReplyThreadVC.swift
//  Stoke
//
//  Created by Admin on 20/04/21.
//

import UIKit
import IQKeyboardManagerSwift

protocol ReplyThreadDelegate:AnyObject {
    func reloadData()
}

class ReplyThreadVC: BaseVC {

    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var textViewParentViewHeightConstant: NSLayoutConstraint!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var textViewBottomHeightConstant: NSLayoutConstraint!
    
    var isFirstTime:Bool = true
    
    var enableSendBtn:Bool = false{
        didSet{
            if enableSendBtn{
                sendBtn.alpha = 1.0
                sendBtn.isUserInteractionEnabled = true
            }else{
                sendBtn.alpha = 0.6
                sendBtn.isUserInteractionEnabled = false
            }
        }
    }
    
    var viewModel:ReplyThreadVM!
    weak var delegate:ReplyThreadDelegate?
    var isFromTrending:Bool = false
    var canReply:Bool = true {
        didSet{
            textViewParentViewHeightConstant.constant = canReply ? 55 : CGFloat.leastNormalMagnitude
            view.layoutIfNeeded()
        }
    }
    var commnet:Comment!
    var room:ChatRoom!
    var commentId:String!
    var roomId:String!
    var tempViewModel:ChatRoomVM!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        enableSendBtn = false
        userImageView.setImageWithIndicator(with: URL(string: AppUserDefaults.value(forKey: .profilePicture).stringValue), placeholderImage: #imageLiteral(resourceName: "ic-profile-placeholder"))
        if !isFromTrending{
            tempViewModel.currentCommnet = commnet
            tempViewModel.hitGetReply(commnet._id)
            tempViewModel.upDateComnet = { [weak self] c in
                guard let self = self else { return }
                self.tableView.reloadData()
                self.commnet = c
                guard !self.tempViewModel.replyDataSource.isEmpty else { return }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                }
            }
            tempViewModel.refreshReplyReactions = { [weak self] section in
                guard let self = self else { return }
                guard !self.tempViewModel.replyDataSource.isEmpty else { return }
                self.tableView.reloadRows(at: [IndexPath(row: 1, section: section + 1)], with: .none)
            }
            tempViewModel.reloadReply = { [weak self] in
                self?.tableView.reloadData()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    guard let self = self else { return }
                    guard !self.tempViewModel.replyDataSource.isEmpty else { return }
                    if self.isFirstTime{
                        self.isFirstTime = false
                        self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                    }else{
                        if self.tempViewModel.replyCurrentPage == 1{
                            self.tableView.scrollToRow(at: IndexPath(row: 0, section: self.tempViewModel.replyDataSource.count - 1), at: .top, animated: true)
                        }else{
                            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                        }
                    }
                }
            }
        }else{
            viewModel = ReplyThreadVM(NetworkLayer(), comment: commnet, roomId: roomId ?? "")
            viewModel.hitGetReply(commnet._id)
            viewModel.reload = { [weak self] in
                self?.tableView.reloadData()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    guard let self = self else { return }
                    guard !self.viewModel.dataSource.isEmpty else { return }
                    self.tableView.scrollToRow(at: IndexPath(row: 0, section: self.viewModel.dataSource.count - 1), at: .top, animated: true)
                }
            }
        }
        canReply = !isFromTrending
        if CommonFunctions.isGuestLogin || UserModel.main.isAdmin{
            canReply = false
        }
        outerView.roundCorner([.topLeft,.topRight], radius: 10)
        textView.font = AppFonts.Regular.withSize(14)
        textView.text = "Comment ..."
        textView.textColor = UIColor.lightGray
        tableView.emptyDataSetView { view in
            view.titleLabelString(NSAttributedString(string: "\n\nPost a comment to start a\n discussion.", attributes: [NSAttributedString.Key.font:AppFonts.Semibold.withSize(16),NSAttributedString.Key.foregroundColor:UIColor.black]))
                .image(#imageLiteral(resourceName: "ic-no-chatroom"))
                .didTapDataButton { [weak self] in
                    self?.view.endEditing(true)
                }
                .didTapContentView {
                    // Do something
                }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enable = false
        registerForKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enable = true
        deregisterFromKeyboardNotifications()
    }
    
    
    
    override func initalSetup() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerCell(with: CommnetTVCell.self)
        tableView.registerCell(with: CommnetReactionTVCell.self)
        textView.delegate = self
        textView.autocorrectionType = .yes
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        outerView.roundCorner([.topLeft,.topRight], radius: 10)
        adjustContentSize(tv: textView)
    }
    
    @IBAction func sendTapped(_ sender: Any) {
        guard CommonFunctions.checkForInternet() else {
            return
        }
        guard let t = textView.text, !t.isEmpty else{ return }
        if !t.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty{
            tempViewModel.addReply(comment: t.trimmingCharacters(in: .whitespacesAndNewlines), commentId: commnet._id)
        }
        textView.text = nil
    }
    
    @IBAction func crossTapped(_ sender: Any){
        if !isFromTrending{
            tempViewModel.currentCommnet = nil
            delegate?.reloadData()
        }
        dismiss(animated: false, completion: nil)
    }
    
    deinit {
        printDebug("\(self) ----> Killed")
    }
    

}

extension ReplyThreadVC : UITableViewDelegate,  UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if !isFromTrending{
            return tempViewModel.replyDataSource.count + 1
        }else{
            return viewModel.dataSource.count + 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if !isFromTrending{
            if indexPath.section == 0{
                if indexPath.row == 0{
                    let cell = tableView.dequeueCell(with: CommnetTVCell.self)
                    cell.populateCell(commnet)
                    cell.showSaperatorLine = false
                    cell.doubleTapped = { [weak self] in
                        if UserModel.main.isCelebrity && (self?.tempViewModel.replyDataSource[indexPath.section].user.id ?? "" != UserModel.main.userId){
                            guard let self = self else { return }
                            let c = self.tempViewModel.replyDataSource[indexPath.section]
                            self.tempViewModel.approveComment(c._id, type: !c.isApprovedByCelebrity, completion: {_ in
                                self.commnet.isApprovedByCelebrity = !self.commnet.isApprovedByCelebrity
                                tableView.reloadData()
                            })
                        }
                    }
                    cell.openProfileTapped = { [weak self] in
                        self?.dismiss(animated: false, completion: {
                            CommonFunctions.navigateToUserProfile(self?.commnet.user.id ?? "")
                        })
                        
                    }
                    return cell
                }else{
                    let cell = tableView.dequeueCell(with: CommnetReactionTVCell.self)
                    cell.hideSaperator = false
                    cell.populateCommnetReacts(model: commnet)
                    cell.reactionTapped = { [weak self] type in
                        self?.tempViewModel.reactOnReply(self?.commnet._id ?? "",action: self?.returnCommnetAction(type: type) ?? true, type: type)
                    }
                    return cell
                }
            }else{
                if indexPath.row == 0{
                    let cell = tableView.dequeueCell(with: CommnetTVCell.self)
                    cell.populateReplyCell(tempViewModel.replyDataSource[indexPath.section - 1])
                    cell.openProfileTapped = { [weak self] in
                        self?.dismiss(animated: false, completion: {
                            CommonFunctions.navigateToUserProfile(self?.tempViewModel.replyDataSource[indexPath.section - 1].user.id ?? "")
                        })
                    }
                    cell.doubleTapped = { [weak self] in
                        if UserModel.main.isCelebrity && (self?.tempViewModel.replyDataSource[indexPath.section - 1].user.id ?? "" != UserModel.main.userId){
                            guard let self = self else { return }
                            let c = self.tempViewModel.replyDataSource[indexPath.section - 1]
                            self.tempViewModel.approveComment(c._id, type: !c.isApprovedByCelebrity, completion: {_ in
                                self.tempViewModel.replyDataSource[indexPath.section - 1].isApprovedByCelebrity = !self.tempViewModel.replyDataSource[indexPath.section - 1].isApprovedByCelebrity
                                tableView.reloadData()
                            })
                        }
                    }
                    return cell
                }else{
                    let cell = tableView.dequeueCell(with: CommnetReactionTVCell.self)
                    cell.populateReplyReacts(model: tempViewModel.replyDataSource[indexPath.section - 1])
                    cell.hideSaperator = true
                    cell.reactionTapped = { [weak self] type in
                        
                        self?.tempViewModel.reactOnReply(self?.tempViewModel.replyDataSource[indexPath.section - 1]._id ?? "",action: self?.returnAction(indexPath.section - 1, type: type) ?? true, type: type)
                    }
                    return cell
                }
            }
        }else{
            if indexPath.section == 0{
                if indexPath.row == 0{
                    let cell = tableView.dequeueCell(with: CommnetTVCell.self)
                    cell.populateCell(commnet)
                    cell.openProfileTapped = { [weak self] in
                        self?.dismiss(animated: false, completion: {
                            CommonFunctions.navigateToUserProfile(self?.commnet.user.id ?? "")
                        })
                    }
                    cell.showSaperatorLine = false
                    return cell
                }else{
                    let cell = tableView.dequeueCell(with: CommnetReactionTVCell.self)
                    cell.hideSaperator = false
                    cell.populateCommnetReacts(model: commnet)
                    return cell
                }
            }else{
                if indexPath.row == 0{
                    let cell = tableView.dequeueCell(with: CommnetTVCell.self)
                    cell.populateReplyCell(viewModel.dataSource[indexPath.section - 1])
                    cell.openProfileTapped = { [weak self] in
                        self?.dismiss(animated: false, completion: {
                            CommonFunctions.navigateToUserProfile(self?.viewModel.dataSource[indexPath.section - 1].user.id ?? "")
                        })
                    }
                    return cell
                }else{
                    let cell = tableView.dequeueCell(with: CommnetReactionTVCell.self)
                    cell.populateReplyReacts(model: viewModel.dataSource[indexPath.section - 1])
                    cell.hideSaperator = true
                    return cell
                }
            }
        }
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func returnAction(_ index:Int, type:ReationType) -> Bool{
        switch type {
        case .like:
            return !tempViewModel.replyDataSource[index].isLiked
        case .clap:
            return !tempViewModel.replyDataSource[index].isClap
        case .dislike:
            return !tempViewModel.replyDataSource[index].isDisliked
        default:
            return !tempViewModel.replyDataSource[index].isLaugh
        }
    }
    
    func returnCommnetAction(type:ReationType) -> Bool{
        switch type {
        case .like:
            return !commnet.isLiked
        case .clap:
            return !commnet.isClap
        case .dislike:
            return !commnet.isDisliked
        default:
            return !commnet.isLaugh
        }
    }
}

extension ReplyThreadVC : UIScrollViewDelegate{
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView === tableView{
            if !isFromTrending{
                if (scrollView.contentOffset.y < 0) && (tempViewModel.replyDataSource.count < tempViewModel.totalReply){
                    if tempViewModel.isReplyLoaded{
                        tempViewModel.isReplyLoaded = false
                        tempViewModel.replyCurrentPage += 1
                        tempViewModel.hitGetReply(commnet._id)
                    }
                }
            }
        }
    }
}

extension ReplyThreadVC : UITextViewDelegate{
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.enableSendBtn = !textView.text.isEmpty
        }
        if text == ""{
            return true
        }else if textView.text.count > 300{
            return false
        }else{
            return true
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        adjustContentSize(tv: textView)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Comment ..."
            textView.textColor = UIColor.lightGray
        }
    }
    
    func adjustContentSize(tv: UITextView){
        let deadSpace = tv.bounds.size.height - tv.contentSize.height
        let inset = max(0, deadSpace/2.0)
        tv.contentInset = UIEdgeInsets(top: inset, left: tv.contentInset.left, bottom: inset, right: tv.contentInset.right)
    }
}



extension ReplyThreadVC{
    
    func registerForKeyboardNotifications(){
        //Adding notifies on keyboard appearing
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    func deregisterFromKeyboardNotifications(){
        //Removing notifies on keyboard appearing
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardWasShown(notification: NSNotification){
        //Need to calculate keyboard exact size due to Apple suggestions
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                let keyboardRectangle = keyboardFrame.cgRectValue
                let keyboardHeight = keyboardRectangle.height
            UIView.animate(withDuration: 0.33, delay: 0, options: .curveEaseIn, animations: { [weak self] in
                guard let self = self else { return }
                if DeviceDetail.bottomSafearaHeight > 0{
                    self.textViewBottomHeightConstant.constant = -(keyboardHeight - DeviceDetail.bottomSafearaHeight)
                    self.view.layoutIfNeeded()
                }else{
                    self.textViewBottomHeightConstant.constant = -(keyboardHeight)
                    self.view.layoutIfNeeded()
                }
            }, completion: nil)
            }
        
    }

    @objc func keyboardWillBeHidden(notification: NSNotification){
        UIView.animate(withDuration: 0.33, delay: 0, options: .curveEaseIn, animations: { [weak self] in
            guard let self = self else { return }
            self.textViewBottomHeightConstant.constant =  0.0
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
}
