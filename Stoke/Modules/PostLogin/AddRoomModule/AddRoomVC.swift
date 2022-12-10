//
//  AddRoomVC.swift
//  Stoke
//
//  Created by Admin on 21/03/21.
//

import UIKit
import Mantis


protocol AddRoomDelegate:AnyObject {
    func roomCreatedSucess()
}

class AddRoomVC: BaseVC {

    
    @IBOutlet weak var tableview: UITableView!
    
    var isEditingMode:Bool = false
    var room:ChatRoom!
    var event:Event?
    var viewModel:AddRoomVM!
    var enableSaveBtn = false
    var isFromMyRooms = false
    weak var delegate:AddRoomDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = AddRoomVM(NetworkLayer(), eventId: event?.id)
        if isEditingMode{
            viewModel.room = room
            addRightButtonToNavigation(title: "Delete")
        }
        viewModel.notifyTOReload  = { [weak self] in
            self?.tableview.reloadData()
        }
        tableview.dataSource = self
        tableview.delegate = self
        viewModel.roomCreated = { [weak self] in
            DispatchQueue.main.async {
                self?.presentPopupView()
            }
        }
        viewModel.roomUpdated = { [weak self] msg in
            DispatchQueue.main.async {
                CommonFunctions.showToastWithMessage("Room updated successfully.", theme: .success)
                self?.delegate?.roomCreatedSucess()
                self?.pop()
            }
            
        }
        viewModel.roomDeleted = { [weak self] in
            DispatchQueue.main.async {
                self?.pop()
            }
            
        }
        viewModel.didEnableSaveBtn = { [weak self] flag in
            self?.enableSaveBtn = flag
            self?.tableview.reloadRows(at: [IndexPath(row: 6, section: 0)], with: .none)
        }
        
        viewModel.notifyLimitreached = { [weak self] flag in
            if !flag{
                CommonFunctions.showToastWithMessage("Room name already exists.", theme: .info)
            }else{
                CommonFunctions.showToastWithMessage("Chatroom already exist for this event.", theme: .info)
                self?.pop()
            }
        }
        
    }
    
    override func initalSetup() {
        let t = isEditingMode ? "Edit Room" : "Add Room"
        setNavigationBar(title: t, backButton: true)
        tableview.registerCell(with: AddImageTVCell.self)
        tableview.registerCell(with: AppTFTVCell.self)
        tableview.registerCell(with: DescriptionTVCell.self)
        tableview.registerCell(with: RadioBtnTVCell.self)
        tableview.registerCell(with: AppThemeBtnTVCell.self)
        tableview.registerCell(with: TwoButtonsTVCell.self)
        
    }
    
    override func rightBarButtonTapped(_ sender: UIButton) {
        let vc = DeleteChatRoomPopupVC.instantiate(fromAppStoryboard: .Events)
        vc.delegate = self
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: false, completion: nil)
    }
    
    private func showPopup(){
        let vc = ThreeBtnPopup.instantiate(fromAppStoryboard: .Home)
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overFullScreen
        vc.delagate = self
        vc.btn1Title = "Camera Roll"
        vc.btn2Title = "Use Event Image"
        vc.btn3Title = "Cancel"
        present(vc, animated: false, completion: nil)
    }
    
    private func pushToInviteFriends(){
        let vc = InviteUsersVC.instantiate(fromAppStoryboard: .Events)
        vc.viewModel = viewModel
        vc.delegate = self
        AppRouter.pushViewController(self, vc)
    }

}

extension AddRoomVC : UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableview.dequeueCell(with: AddImageTVCell.self)
            if let img = viewModel.dummyImage{
                cell.profileIMView.image = img
            }else{
                cell.populateImage(viewModel.image)
            }
            cell.tapOnIMView = { [weak self] in
                self?.showPopup()
            }
            return cell
        case 1:
            let cell = tableview.dequeueCell(with: AppTFTVCell.self)
            cell.clipsToBounds = true
            cell.chatroomNameTF.setupAs = .eventname
            cell.chatroomNameTF.isUserInteractionEnabled = false
            cell.chatroomNameTF.text = viewModel.eventName
            cell.chatroomNameTF.editingChange = { [weak self] in
                self?.viewModel.eventName = cell.chatroomNameTF.text ?? ""
            }
            return cell
        case 2:
            let cell = tableview.dequeueCell(with: AppTFTVCell.self)
            cell.chatroomNameTF.text = viewModel.chatRoomName
            cell.chatroomNameTF.editingChange = { [weak self] in
                self?.viewModel.chatRoomName = cell.chatroomNameTF.text ?? ""
            }
            return cell
        case 3:
            let cell = tableview.dequeueCell(with: DescriptionTVCell.self)
            cell.descTextView.text = viewModel.roomDesc
            cell.descriptionText = { [weak self] desc in
                self?.viewModel.roomDesc = desc
            }
            return cell
        case 4:
            let cell = tableview.dequeueCell(with: RadioBtnTVCell.self)
            cell.isPublic = viewModel.roomType  == ._public
            if viewModel.roomType  == ._private && isEditingMode{
                cell.btn1.isUserInteractionEnabled = false
                cell.btn2.isUserInteractionEnabled = false
            }else{
                cell.btn1.isUserInteractionEnabled = true
                cell.btn2.isUserInteractionEnabled = true
            }
            cell.isPublicSelected = { [weak self] falg in
                guard let self = self else { return }
                self.tableview.beginUpdates()
                self.viewModel.roomType = falg ? ._public : ._private
                self.tableview.endUpdates()
                if self.isEditingMode{
                    self.enableSaveBtn = true
                    self.tableview.reloadData()
                }
            }
            return cell
        case 5:
            let cell = tableview.dequeueCell(with: AppThemeBtnTVCell.self)
            cell.createRoom = { [weak self] in
                self?.pushToInviteFriends()
            }
            cell.clipsToBounds = true
            return cell
        default:
            let cell = tableview.dequeueCell(with: TwoButtonsTVCell.self)
            let tit = isEditingMode ? "Update" : "Save"
            cell.saveBtn.setTitle(tit, for: .normal)
            cell.enableBtn = enableSaveBtn
            cell.isSaveGroup = { [weak self] flag in
                guard let self = self else { return }
                if flag{
                    if self.isEditingMode{
                        self.viewModel.editroom()
                    }else{
                        self.viewModel.createRoom()
                    }
                }else{
                    self.pop()
                }
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 && isFromMyRooms{
            let vc = SelectEventListVC.instantiate(fromAppStoryboard: .Events)
            vc.delegate = self
            AppRouter.pushViewController(self, vc)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 1{
            return isFromMyRooms ? UITableView.automaticDimension : CGFloat.leastNormalMagnitude
        }else if indexPath.row == 5 && viewModel != nil{
            if viewModel.roomType == ._public{
                return CGFloat.leastNormalMagnitude
            }else{
                return UITableView.automaticDimension
            }
        }else{
            return UITableView.automaticDimension
        }
    }
    
    private func presentPopupView(msg:String = "Chat room created successfully"){
//        let vc = RoomCreatedSuccessVC.instantiate(fromAppStoryboard: .Events)
//        vc.delegate = self
//        vc.heading = "Success!"
//        vc.okBtntitle = "OK"
//        vc.subheading = msg
//        vc.modalTransitionStyle = .crossDissolve
//        vc.modalPresentationStyle = .overFullScreen
//        self.present(vc, animated: false, completion: nil)
        CommonFunctions.showToastWithMessage("Room created successfully.", theme: .success)
        delegate?.roomCreatedSucess()
        pop()
    }
}

extension AddRoomVC : SignupSucessDelegate {
    func okTapped() {
        delegate?.roomCreatedSucess()
        pop()
    }
}

extension AddRoomVC : DeleteChatRoomPopupDelegate {
    func deleteTapped(index:Int) {
        viewModel.deleteChatRooms()
    }
}

extension AddRoomVC : ThreeBtnPopupDelegate{
    func getUserChoice(_ index:Int,section:Int) {
        if index == 0{
            captureImage(delegate: self, photoGallery: true, camera: false)
        }else if index == 1 {
            guard let e = event else { CommonFunctions.showToastWithMessage("Please select the event first.",theme: .info)
                return
            }
            enableSaveBtn = true
            viewModel.image = e.image
            viewModel.dummyImage = nil
            
            tableview.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
            
            
//            tableview.reloadData()
        }
    }
}

extension AddRoomVC : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            return
        }
        picker.dismiss(animated: true, completion: nil)
        var config = Mantis.Config()
        config.showRotationDial = false
        config.addCustomRatio(byVerticalWidth: 1, andVerticalHeight: 2)
        let vc = Mantis.cropViewController(image: image, config: config)
        vc.config.presetFixedRatioType = .alwaysUsingOnePresetFixedRatio(ratio: 16.0 / 9.0)
        vc.delegate = self
        present(vc, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension AddRoomVC : CropViewControllerDelegate {
    func cropViewControllerDidCrop(_ cropViewController: CropViewController, cropped: UIImage, transformation: Transformation) {
        cropViewController.dismiss(animated: false, completion: nil)
        viewModel.isUploading = true
        viewModel.dummyImage = cropped
        tableview.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none) //reloadData()
        CommonFunctions.showActivityLoader()
        AWSController.uploadImage(cropped, success: { [weak self](flag, url) in
            self?.viewModel.image = url
            self?.viewModel.isUploading = false
            if (self?.isEditingMode ?? false){
                DispatchQueue.main.async {
                    self?.enableSaveBtn = true
                    self?.tableview.reloadData()
                }
            }
            CommonFunctions.hideActivityLoader()
            printDebug(url)
            }, progress: { (progress) in
                printDebug(progress)
        }) { [weak self](e) in
            self?.viewModel.isUploading = false
            CommonFunctions.hideActivityLoader()
            CommonFunctions.showToastWithMessage(e.localizedDescription)
        }
    }
    
    func cropViewControllerDidCancel(_ cropViewController: CropViewController, original: UIImage) {
        cropViewController.dismiss(animated: false, completion: nil)
    }
    
    
}


extension AddRoomVC : OutofRoomsDelegate {
    func popNow(){
        pop()
    }
}


extension AddRoomVC  : SelectEventListDelegate {
    
    func getSelectedEvent(_ event: Event) {
        self.event = event
        viewModel.eventName = event.name
        viewModel.eventId = event.id
        tableview.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .none)
//        tableview.reloadData()
    }
}


extension AddRoomVC : InviteFriendsDelegate{
    func updateForEdit() {
        if isEditingMode{
            enableSaveBtn = true
            tableview.reloadData()
        }
    }
}
