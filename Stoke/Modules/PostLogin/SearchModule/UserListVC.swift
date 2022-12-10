//
//  UserListVC.swift
//  Stoke
//
//  Created by Admin on 17/03/21.
//

import UIKit
import SwiftyJSON
import EmptyDataSet_Swift

class UserListVC: BaseVC {

    @IBOutlet weak var tableView: UITableView!
    var viewModel:SearchVM!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func initalSetup() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func updateEmptyScreen(){
        tableView.emptyDataSetView { view in
            view.titleLabelString(NSAttributedString(string: "\n\nNo Users Found", attributes: [NSAttributedString.Key.font:AppFonts.Semibold.withSize(16),NSAttributedString.Key.foregroundColor:UIColor.black]))
                .image(#imageLiteral(resourceName: "no_user"))
                .didTapDataButton {
                    
                }
                .didTapContentView {
                    // Do something
                }
        }
    }
}

extension UserListVC : UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.userList.data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(with: UserListTVCell.self)
        cell.populateCell(viewModel.userList.data[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        CommonFunctions.navigateToUserProfile(viewModel.userList.data[indexPath.row].id, onParent: self)
    }
}




class UserListTVCell:UITableViewCell{
    
    
    
    
    @IBOutlet weak var trustedBadge: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imView: UIImageView!
    
    var isTrusted:Bool = false{
        didSet{
            trustedBadge.isHidden = !isTrusted
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imView.round()
        initialSetup()
        isTrusted = false
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imView.image = nil
    }
    
    private func initialSetup(){
        userNameLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        nameLabel.textColor = AppColors.labelColor
        imView.backgroundColor = .clear
    }
    
    func populateCell(_ user:User){
        isTrusted = user.isTrusted
        userNameLabel.text = user.userName
        nameLabel.text = user.firstName + " " + user.lastName
        if user.image.isEmpty {
            imView.image = #imageLiteral(resourceName: "ic-profile-placeholder")
        } else {
            imView.setImageWithIndicator(with: URL(string: user.image), placeholderImage: #imageLiteral(resourceName: "ic-profile-placeholder"))
        }
        
    }
    
    
    

}
