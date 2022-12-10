//
//  NotificationSettingsVC.swift
//  Stoke
//
//  Created by Admin on 19/05/21.
//

import UIKit

class NotificationSettingsVC: BaseVC {

    @IBOutlet weak var tableView: UITableView!
    
    var isAnyUpdate = false
    var viewModel:NotificationSettingsVM!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = NotificationSettingsVM(NetworkLayer())
        viewModel.reloadData = { [weak self] in
            self?.tableView.reloadData()
        }
        setNavigationBar(title: "Notification Settings", backButton: true)
    }
    
    override func initalSetup() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isAnyUpdate{
            viewModel.updateStatus { [weak self] in
                self?.pop()
            }
        }
    }
    
    private func updateToggled(_ flag:Bool, index:Int){
        isAnyUpdate = true
        switch index{
        case 0:
            viewModel.model.mentionInChat = flag
        case 1:
            viewModel.model.newFollower = flag
        case 2:
            viewModel.model.followerActiveInChatroom = flag
        case 3:
            viewModel.model.newChatRoomInvite = flag
        case 4:
            viewModel.model.paymentConfirmations = flag
        case 5:
            viewModel.model.savedChatRoomLive = flag
        case 6:
            viewModel.model.chatRoomCreationByFollower = flag
        case 7:
            viewModel.model.celebrityApprovesComment = flag
        case 8:
            viewModel.model.recapAvailable = flag
        case 9:
            viewModel.model.saveTag = flag
        case 10:
            viewModel.model.savedRoomEvent = flag
        case 11:
            viewModel.model.replyOnComment = flag
        case 12:
            viewModel.model.yourCreatedRoomLive = flag
        case 13:
            viewModel.model.roomRequestAccepted = flag
        case 14:
            viewModel.model.eventReminder = flag
        case 15:
            viewModel.model.recapAvailableForYourCreatedRoom = flag
        default:
            viewModel.model.requestToJoinChatroom = flag
        }
        tableView.reloadData()
    }
}

extension NotificationSettingsVC : UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(with: NotificationSwitchTVCell.self)
        cell.populateCell(viewModel.dataSource[indexPath.row])
        cell.switchToggled = { [weak self] flag in
            self?.updateToggled(flag, index: indexPath.row)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 || indexPath.row == 4 || indexPath.row == 2 || indexPath.row == 7 || indexPath.row == 3{
            return CGFloat.leastNormalMagnitude
        }else{
            return UITableView.automaticDimension
        }
    }
}



class NotificationSwitchTVCell:UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var switchBtn: UISwitch!
    
    var switchToggled:((Bool)->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        switchBtn.setOn(false, animated: false)
    }
    
    @IBAction func switchTapped(_ sender: UISwitch) {
        if let t = switchToggled { t(sender.isOn)}
    }
    
    func populateCell(_ v:(String,Bool)){
        title.text = v.0
        switchBtn.setOn(v.1, animated: true)
    }
    
    
}
