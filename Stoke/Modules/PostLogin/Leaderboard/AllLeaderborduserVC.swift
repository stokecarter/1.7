//
//  AllLeaderborduserVC.swift
//  Stoke
//
//  Created by Admin on 27/04/21.
//

import UIKit

class AllLeaderborduserVC: BaseVC {
        
    @IBOutlet weak var tableView: UITableView!
    
    var dataSource:[LeaderBoard] = []
    var type:LeaderBordType = .like
    
    let refresh = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar(title: "Leaderboard Ranking", backButton: true)
        refresh.addTarget(self, action: #selector(pullToRefresh(_:)), for: .valueChanged)
        tableView.refreshControl = refresh
    }
    
    override func initalSetup() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerCell(with: LeaderboardListTVCell.self)
    }
    
    @objc func pullToRefresh(_ sender:UIRefreshControl){
        sender.endRefreshing()
    }
    
    
}

extension AllLeaderborduserVC : UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(with: LeaderboardListTVCell.self)
        cell.populateCell(dataSource[indexPath.row], type: type)
        cell.openUserProfile = { [weak self] in
            let id = self?.dataSource[indexPath.row]._id ?? ""
            CommonFunctions.navigateToUserProfile(id)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let id = dataSource[indexPath.row]._id
        CommonFunctions.navigateToUserProfile(id,onParent:self)
    }
    
}
