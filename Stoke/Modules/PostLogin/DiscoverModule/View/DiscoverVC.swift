//
//  DiscoverVC.swift
//  Stoke
//
//  Created by Admin on 17/03/21.
//

import UIKit


class DiscoverVC: BaseVC {
    
    @IBOutlet weak var tableView: UITableView!
    
    var viewModel:DiscoverVM!
    var refreshController = UIRefreshControl()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(scrollToTop), name: NSNotification.Name.scrollTotop, object: nil)
        setNavigationBar(title: "Discover", backButton: false)
        viewModel.hitApiForCategories(loader: false)
        viewModel.hitTodaysEvents()
        viewModel.hitLeaderBoardApi(type: viewModel.type){}
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        StokeAnalytics.shared.setScreenVisitEvent(.visitDiscoverScreen)
        viewModel = DiscoverVM(NetworkLayer())
        viewModel.notify = { [weak self] in
            self?.tableView.reloadData()
        }
        addPullToRefresh()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.scrollTotop, object: self)
    }
    
    override func initalSetup() {
        tableView.registerCell(with: ViewAllHeaderBtnTVCell.self)
        tableView.registerCell(with: HorizontalCollectionViewTVCell.self)
        tableView.registerCell(with: FeaturesTVCell.self)
        tableView.registerCell(with: LeaderboardListTVCell.self)
        tableView.registerCell(with: LeaderBoardHeader.self)
        tableView.registerCell(with: LeaderBordEmptyStateTVCell.self)
        tableView.delegate = self
        tableView.dataSource = self
    }
    private func addPullToRefresh(){
        refreshController.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.refreshControl = refreshController
    }
    
    @objc func refresh(){
        viewModel.hitApiForCategories()
        viewModel.hitTodaysEvents()
        viewModel.hitLeaderBoardApi(type: viewModel.type){}
        tableView.reloadData()
        refreshController.endRefreshing()
    }
    
    
    @IBAction func openSearchVC(_ sender: Any) {
        let vc = SearchVC.instantiate(fromAppStoryboard: .Home)
        AppRouter.pushViewController(self, vc)
    }
    
    
    private func perfornBtnAction(_ section:Int){
        switch section {
        case 0:
            let vc = CategoriesListVC.instantiate(fromAppStoryboard: .Home)
            vc.viewModel = viewModel
            AppRouter.pushViewController(self, vc)
        default:
            let vc = TodaysEventListVC.instantiate(fromAppStoryboard: .Home)
            vc.dataSource = viewModel.events
            vc.todayDate = viewModel.currentDate
            AppRouter.pushViewController(self, vc)
        }
    }
    
    private func viewDetailLeaderBoard(){
        let vc = LeaderboardVC.instantiate(fromAppStoryboard: .Chat)
        AppRouter.pushViewController(self, vc)
    }
    
    @objc func scrollToTop() {
        guard let _ = viewModel,!viewModel.categories.isEmpty else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            guard let _ = self?.viewModel else { return }
            self?.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
}

extension DiscoverVC : UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel == nil ? 0 : 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return viewModel == nil ? 0 : viewModel.categories.isEmpty ? 0 : 2
        case 1:
            if viewModel == nil || viewModel.leaderBoard.isEmpty{
                return 3
            }else{
                if viewModel.leaderBoard.count > 5{
                    return 7
                }else{
                    return viewModel.leaderBoard.count + 2
                }
            }
        default:
            if viewModel == nil || viewModel.events.isEmpty{
                return 0
            }else {
                if viewModel.events.count > 2{
                    return 3
                }else{
                    return viewModel.events.count + 1
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueCell(with: ViewAllHeaderBtnTVCell.self)
                cell.headerLabel.text = "Categories"
                cell.btnAction = { [weak self] in
                    self?.perfornBtnAction(indexPath.section)
                }
                cell.viewAllBtn.isHidden = viewModel.categories.count < 4
                return cell
            default:
                let cell = tableView.dequeueCell(with: HorizontalCollectionViewTVCell.self)
                cell.dataSource = viewModel.categories
                cell.delegate = self
                return cell
            }
        case 1:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueCell(with: ViewAllHeaderBtnTVCell.self)
                cell.headerLabel.text = "Leaderboards"
                cell.btnAction = { [weak self] in
                    self?.viewDetailLeaderBoard()
                }
                cell.viewAllBtn.isHidden = viewModel.leaderBoard.count < 6
                return cell
            case 1:
                let cell = tableView.dequeueCell(with: LeaderBoardHeader.self)
                switch viewModel.type {
                case .like:
                    cell.manageSelectedState(cell.likeBtn)
                case .clap:
                    cell.manageSelectedState(cell.clapbtn)
                default:
                    cell.manageSelectedState(cell.laughBtn)
                }
                cell.selectionMade = { [weak self] (sender,type) in
                    self?.viewModel.type = type
                    self?.viewModel.hitLeaderBoardApi(type: type, cID: "", {
                        cell.manageSelectedState(sender)
                    })
                }
                return cell
            default:
                if viewModel.leaderBoard.isEmpty{
                    let cell = tableView.dequeueCell(with: LeaderBordEmptyStateTVCell.self)
                    if !viewModel.isleaderBoardLoading{
                        cell.type = viewModel.type
                    }else{
                        cell.headingLabel.isHidden = true
                        cell.iconImageView.isHidden = true
                    }
                    return cell
                }else{
                    let cell = tableView.dequeueCell(with: LeaderboardListTVCell.self)
                    cell.openUserProfile = { [weak self] in
                        CommonFunctions.navigateToUserProfile(self?.viewModel.leaderBoard[indexPath.row - 2]._id ?? "",onParent: self)
                    }
                    cell.populateCell(viewModel.leaderBoard[indexPath.row - 2], type: viewModel.type)
                    return cell
                }
            }
        default:
            switch indexPath.row{
            case 0:
                let cell = tableView.dequeueCell(with: ViewAllHeaderBtnTVCell.self)
                cell.headerLabel.text = "Today's Events"
                cell.btnAction = { [weak self] in
                    self?.perfornBtnAction(indexPath.section)
                }
                cell.viewAllBtn.isHidden = viewModel.events.count < 3
                return cell
            default:
                let cell = tableView.dequeueCell(with: FeaturesTVCell.self)
                cell.populateData(viewModel.events[indexPath.item - 1])
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 && indexPath.row != 0{
            guard CommonFunctions.checkForInternet() else { return }
            let vc = EventGroupListVC.instantiate(fromAppStoryboard: .Home)
            vc.event = viewModel.events[indexPath.row - 1]
            AppRouter.pushViewController(self, vc)
        }else if indexPath.section == 1 && indexPath.row != 0 && indexPath.row != 1{
            if !viewModel.leaderBoard.isEmpty{
                let id = viewModel.leaderBoard[indexPath.row - 2]._id
                CommonFunctions.navigateToUserProfile(id, onParent: self)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1{
            switch indexPath.row {
            case 0,1:
                return UITableView.automaticDimension
            default:
                if viewModel.leaderBoard.isEmpty{
                    return 240
                }else{
                    return UITableView.automaticDimension
                }
            }
        }else{
            return UITableView.automaticDimension
        }
    }
}


extension DiscoverVC : HorizontalCollectionViewDelegate {
    func getSelectedCategory(_ category: Categories) {
        let vc = CategoriesEventListVC.instantiate(fromAppStoryboard: .Home)
        vc.category = category
        AppRouter.pushViewController(self, vc)
    }
}


