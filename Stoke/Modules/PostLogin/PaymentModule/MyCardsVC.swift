//
//  MyCardsVC.swift
//  Stoke
//
//  Created by Admin on 12/05/21.
//

import UIKit

class MyCardsVC: BaseVC {

    @IBOutlet weak var tableView: UITableView!
    
    var viewModel:MyCardsVM!
    var primeCardIndex = 0
    var showSaveCards:Bool = false
    var refresh = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = MyCardsVM(NetworkLayer())
        viewModel.reloadData = { [weak self] in
            self?.showSaveCards = !(self?.viewModel.cards.isEmpty ?? false)
            self?.tableView.reloadData()
        }
        refresh.addTarget(self, action: #selector(refreshControll(_:)), for: .valueChanged)
    }
    
    override func initalSetup() {
        setNavigationBar(title: "My Cards", backButton: true)
        applyTransparentBackgroundToTheNavigationBar(100)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerCell(with: DropdownHeaderTVCell.self)
        tableView.registerCell(with: MyDefaultTVCell.self)
        tableView.registerCell(with: MyOthersCardsTVCell.self)
    }
    
    private func hitForMakeDefault(_ id:String){
        viewModel.markDefault(id)
    }
    @objc func refreshControll(_ sender:UIRefreshControl){
        sender.endRefreshing()
        viewModel.getCards()
    }
    
    private func hitForDeleteCard(_ id:String){
        let vc = GenericPopupVC.instantiate(fromAppStoryboard: .Chat)
        vc.delegate = self
        vc.isForDelete = true
        vc.headingText = "Delete Card?"
        vc.subheadingTxt = "Are you sure you want to delete this card?"
        vc.firstbtnTitle = "Cancel"
        vc.secondbtnTitle = "Delete"
        vc.id = id
        vc.modalTransitionStyle = .coverVertical
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: false, completion: nil)
    }

}

extension MyCardsVC : UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel != nil ? (showSaveCards ? viewModel.cards.count + 1 : 1) : 0
            
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueCell(with: DropdownHeaderTVCell.self)
            cell.heading.text = "Saved Cards"
            cell.isExpanded = showSaveCards
            return cell
        default:
            let d = viewModel.cards[indexPath.row - 1]
            if d.isDefault{
                let cell = tableView.dequeueCell(with: MyDefaultTVCell.self)
                cell.populateData(d)
                return cell
            }else{
                let cell = tableView.dequeueCell(with: MyOthersCardsTVCell.self)
                cell.populateData(d)
                cell.action = { [weak self] flag in
                    if flag{
                        self?.hitForMakeDefault(d.id)
                    }else{
                        self?.hitForDeleteCard(d.id)
                    }
                }
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0{
            showSaveCards = !showSaveCards
            tableView.reloadData()
        }
    }
}


extension MyCardsVC : GenericPopupDelegate {
    func optionTapped(_ flag: Bool, isDelete: Bool, id: String) {
        if isDelete{
            if flag{
                viewModel.deleteCard(id)
            }
        }else{
            if flag{
                viewModel.markDefault(id)
            }
        }
    }
}
