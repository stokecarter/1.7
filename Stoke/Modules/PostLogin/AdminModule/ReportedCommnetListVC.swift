//
//  ReportedCommnetListVC.swift
//  Stoke
//
//  Created by Admin on 27/05/21.
//

import UIKit

protocol ReportedCommnetDelegate:AnyObject {
    func updatedata()
}

class ReportedCommnetListVC: BaseVC {
    
    @IBOutlet weak var tableView: UITableView!
    
    var refresh = UIRefreshControl()
    weak var delegate:ReportedCommnetDelegate?
    var viewModel:AdminVM!
    var room:ChatRoom!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = AdminVM(NetworkLayer(), room: room)
        viewModel.reload = { [weak self] in
            self?.updateheader()
            self?.tableView.reloadData()
        }
        viewModel.updateTitle = { [weak self] in
            self?.updateheader()
        }
        setNavigationBar(title: "Reported Comments", backButton: true)
        addButtonsOnNavigationBar()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerCell(with: ReportCommnetTVCell.self)
        tableView.registerCell(with: ReplyThreadTVCell.self)
        tableView.registerCell(with: CommnetReactionTVCell.self)
        tableView.emptyDataSetView { view in
                view.titleLabelString(NSAttributedString(string: "\n\nNo Reported Comments Available", attributes: [NSAttributedString.Key.font:AppFonts.Semibold.withSize(16),NSAttributedString.Key.foregroundColor:UIColor.black]))
                    .image(#imageLiteral(resourceName: "ic-no-chatroom"))
                    .isScrollAllowed(true)
            }
        refresh.addTarget(self, action: #selector(pullToRefresh(_:)), for: .valueChanged)
        tableView.refreshControl = refresh
    }
    
    
    @objc func pullToRefresh(_ sender:UIRefreshControl){
        sender.endRefreshing()
        viewModel.getReportedCommnetList()
    }
    
    private func updateheader(){
        let count = viewModel.selectedCommnet.count
        let t = count < 1 ? "Reported Comments" : "\(count) Selected"
        setNavigationBar(title: t, backButton: true)
    }
    
    private func addButtonsOnNavigationBar(){
        let dc = UIButton(type: .custom)
        dc.setImage(#imageLiteral(resourceName: "remove-chatroom"), for: .normal)
        dc.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        
        let uc = UIButton(type: .custom)
        uc.setImage(#imageLiteral(resourceName: "remove-user"), for: .normal)
        uc.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        
        let deleteCommnet   = UIBarButtonItem(customView: dc)
        let deleteUser = UIBarButtonItem(customView: uc)
        dc.addTarget(self, action: #selector(didTapDeleteCommnetButton(sender:)), for: .touchDragInside)
        uc.addTarget(self, action: #selector(didTapDeleteuserButton(sender:)), for: .touchDragInside)
        deleteCommnet.tintColor = AppColors.themeColor
        deleteUser.tintColor = AppColors.themeColor
        navigationItem.rightBarButtonItems = [deleteCommnet, deleteUser]
    }
    
    @objc func didTapDeleteCommnetButton(sender: AnyObject){
        guard !viewModel.selectedCommnet.isEmpty else { CommonFunctions.showToastWithMessage("Please select comments first", theme: .info)
            return
        }
        let vc = GenericPopupVC.instantiate(fromAppStoryboard: .Chat)
        vc.delegate = self
        vc.isForDelete = true
        vc.headingText = "Remove Comments?"
        vc.subheadingTxt = "Are you sure you want to remove comment?"
        vc.firstbtnTitle = "Cancel"
        vc.secondbtnTitle = "Remove"
        vc.modalTransitionStyle = .coverVertical
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: false, completion: nil)
    }
    
    @objc func didTapDeleteuserButton(sender: AnyObject){
        guard !viewModel.selectedCommnet.isEmpty else { CommonFunctions.showToastWithMessage("Please select comments first", theme: .info)
            return
        }
        let vc = GenericPopupVC.instantiate(fromAppStoryboard: .Chat)
        vc.delegate = self
        vc.isForDelete = false
        vc.headingText = "Remove Users?"
        vc.subheadingTxt = "Are you sure you want to remove these users?"
        vc.firstbtnTitle = "Cancel"
        vc.secondbtnTitle = "Remove"
        vc.modalTransitionStyle = .coverVertical
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: false, completion: nil)
    }
    
    override func backButtonTapped() {
        delegate?.updatedata()
        pop()
    }
    
}


extension ReportedCommnetListVC : UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.dataSource.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let d = viewModel.dataSource[indexPath.section]
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueCell(with: ReportCommnetTVCell.self)
            cell.populateCell(d, selected: viewModel.selectedCommnet.contains(d._id))
            cell.isCommnetSelected = viewModel.selectedCommnet.contains(d._id)
            return cell
        case 1:
            let cell = tableView.dequeueCell(with: ReplyThreadTVCell.self)
            cell.populateCell(d.user_reply.first)
            cell.isCommnetSelected = viewModel.selectedCommnet.contains(d._id)
            return cell
        default:
            let cell = tableView.dequeueCell(with: CommnetReactionTVCell.self)
            cell.populateCommnetReacts(model: d)
            cell.isCommnetSelected = viewModel.selectedCommnet.contains(d._id)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 1{
            return viewModel.dataSource[indexPath.section].user_reply.isEmpty ? CGFloat.leastNormalMagnitude : UITableView.automaticDimension
        }else{
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let id = viewModel.dataSource[indexPath.section]._id
        if viewModel.selectedCommnet.contains(id){
            viewModel.selectedCommnet.remove(id)
        }else{
            viewModel.selectedCommnet.insert(id)
        }
        tableView.reloadData()
    }
}


extension ReportedCommnetListVC : GenericPopupDelegate {
    
    func optionTapped(_ flag: Bool, isDelete: Bool, id: String) {
        if isDelete{
            if flag{
                viewModel.deleteReportedCommnets { [weak self] in
                    self?.viewModel.selectedCommnet = []
                    self?.viewModel.getReportedCommnetList()
                }
            }
        }else{
            if flag{
                viewModel.deleteReportedUsers { [weak self] in
                    self?.viewModel.selectedCommnet = []
                    self?.viewModel.getReportedCommnetList()
                }
            }
        }
    }
}
