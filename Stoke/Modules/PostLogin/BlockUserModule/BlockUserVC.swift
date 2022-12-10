//
//  BlockUserVC.swift
//  Stoke
//
//  Created by Admin on 18/05/21.
//

import UIKit

class BlockUserVC: BaseVC {

    @IBOutlet weak var tableView: UITableView!
    var refresh = UIRefreshControl()
    
    var viewModel:BlockUserVM!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = BlockUserVM(NetworkLayer())
        viewModel.notify = { [weak self] in
            self?.tableView.reloadData()
        }
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerCell(with: BlockUserListTVCell.self)
        setNavigationBar(title: "Blocked Users", backButton: true)
        tableView.emptyDataSetView { view in
            view.titleLabelString(NSAttributedString(string: "\n\nNo Blocked Users", attributes: [NSAttributedString.Key.font:AppFonts.Semibold.withSize(16),NSAttributedString.Key.foregroundColor:UIColor.black]))
                .image(#imageLiteral(resourceName: "block-user-1"))
                .didTapDataButton {
                    
                }
                .didTapContentView {
                    // Do something
                }
        }
        refresh.addTarget(self, action: #selector(pullToRefresh(_:)), for: .valueChanged)
    }
    
    @objc func pullToRefresh(_ sender:UIRefreshControl){
        sender.endRefreshing()
        viewModel.getList()
    }
    
    func showRemovePopup(id:String,name:String) {
        let vc = GenericPopupVC.instantiate(fromAppStoryboard: .Chat)
        vc.delegate = self
        vc.isForDelete = true
        vc.headingText = "Unblock \(name)?"
        vc.subheadingTxt = "Are you sure you want to unblock this user?"
        vc.firstbtnTitle = "Cancel"
        vc.secondbtnTitle = "Unblock"
        vc.id = id
        vc.modalTransitionStyle = .coverVertical
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: false, completion: nil)
    }

}


extension BlockUserVC : UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(with: BlockUserListTVCell.self)
        cell.populateBlockCell(viewModel.data[indexPath.row])
        cell.tapped = { [weak self] in
            guard let self = self else { return }
            self.showRemovePopup(id: self.viewModel.data[indexPath.row].id, name: self.viewModel.data[indexPath.row].userName)
        }
        return cell
    }
}

extension BlockUserVC : GenericPopupDelegate {
    
    func optionTapped(_ flag: Bool, isDelete: Bool, id: String) {
        if flag{
            self.viewModel.unblockUser(id) {
                self.viewModel.getList()
            }
        }
    }
}
