//
//  EditProfileVC.swift
//  Stoke
//
//  Created by Admin on 17/05/21.
//

import UIKit
import Mantis

class EditProfileVC: BaseVC {

    @IBOutlet weak var tableView: UITableView!
    
    
    var model:UserProfileModel!
    var viewModel:EditProfileVM!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = EditProfileVM(NetworkLayer(), u: model)
        viewModel.verified = { [weak self] (flag,msg) in
            if !flag{
                CommonFunctions.showToastWithMessage(msg)
            }
            if let cell = self?.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? EditProfileFieldsTVCell {
                cell.userNameTF.startAnimating = false
                cell.userNameTF.isUserInteractionEnabled = true
            }
        }
        viewModel.editSuccess = { [weak self] in
            self?.pop()
        }
        setNavigationBar(title: "Edit Profile", backButton: true)
        addRightButtonToNavigation(image: nil, title: "Save")
    }
    
    override func initalSetup() {
        tableView.registerCell(with: EditProfileImageTVCell.self)
        tableView.registerCell(with: EditProfileFieldsTVCell.self)
        tableView.registerCell(with: EditToggleTVCell.self)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func openGallery(){
        captureImage(delegate: self)
    }
    
    override func rightBarButtonTapped(_ sender: UIButton) {
        viewModel.hitUpdateProfile()
    }

}

extension EditProfileVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueCell(with: EditProfileImageTVCell.self)
            cell.imgUrl = viewModel.profilePicture
            cell.openGalery = { [weak self] in
                self?.openGallery()
            }
            return cell
        case 1:
            let cell = tableView.dequeueCell(with: EditProfileFieldsTVCell.self)
            cell.nameTF.text = viewModel.fullName
            cell.userNameTF.text = viewModel.userName
            cell.bioTextView.text = viewModel.bio
            cell.userNameTF.editingBegain = {
                cell.userNameTF.startAnimating = false
            }
            cell.userNameTF.editingEnd = { [weak self] in
                if let un = cell.userNameTF.text, !un.isEmpty{
                    cell.userNameTF.startAnimating = true
                    cell.userNameTF.isUserInteractionEnabled = false
                    self?.viewModel.verifyUsername()
                }
            }
            cell.nameTF.editingChange = { [weak self] in
                self?.viewModel.fullName = cell.nameTF.text ?? ""
            }
            cell.userNameTF.editingChange = { [weak self] in
                self?.viewModel.userName = cell.userNameTF.text ?? ""
            }
            cell.getBio = { [weak self] bio in
                self?.viewModel.bio = bio
            }
            return cell
        default:
            let cell = tableView.dequeueCell(with: EditToggleTVCell.self)
            cell.engagementSwitch.setOn(viewModel.isHideEngagementStats, animated: true)
            cell.privateAccountSwitch.setOn(viewModel.isPrivateAccount, animated: true)
            cell.setPrivateStatus = { [weak self] flag in
                self?.viewModel.isPrivateAccount = flag
            }
            cell.setEngagemnet = { [weak self] flag in
                self?.viewModel.isHideEngagementStats = flag
            }
            return cell
        }
    }
}


extension EditProfileVC : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            return
        }
        picker.dismiss(animated: true, completion: nil)
        var config = Mantis.Config()
        config.showRotationDial = false
        config.addCustomRatio(byVerticalWidth: 1, andVerticalHeight: 1)
        let vc = Mantis.cropViewController(image: image, config: config)
        vc.config.presetFixedRatioType = .alwaysUsingOnePresetFixedRatio(ratio: 1/1)
        vc.config.cropShapeType = .ellipse(maskOnly: true)
        vc.delegate = self
        present(vc, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension EditProfileVC : CropViewControllerDelegate {
    func cropViewControllerDidCrop(_ cropViewController: CropViewController, cropped: UIImage, transformation: Transformation) {
        cropViewController.dismiss(animated: false, completion: nil)
        viewModel.isUploading = true
        viewModel.dummyImage = cropped
        tableView.reloadData()
        CommonFunctions.showActivityLoader()
        AWSController.uploadImage(cropped, success: { [weak self](flag, url) in
            DispatchQueue.main.async {
                self?.viewModel.profilePicture = url
                self?.viewModel.isUploading = false
                self?.tableView.reloadData()
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
