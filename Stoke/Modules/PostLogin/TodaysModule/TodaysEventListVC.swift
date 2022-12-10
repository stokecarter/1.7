//
//  TodaysEventListVC.swift
//  Stoke
//
//  Created by Admin on 18/03/21.
//

import UIKit

class TodaysEventListVC: BaseVC {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var refreshController = UIRefreshControl()
    var viewModel:DayEventsListVM!
    var type:EventType = .upcoming
    var sort:SortingBy = .time
    var category:Categories?
    var startDate:Double?
    var isTodays:Bool = true
    var dayString:String = ""
    var dataSource:[Event] = []
    var isFeatured:Bool = false
    var todayDate:EventCalendar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerCell(with: FeaturesTVCell.self)
        tableView.registerCell(with: ViewAllHeaderBtnTVCell.self)
        viewModel = DayEventsListVM(NetworkLayer(), isTodays: isTodays, sd: startDate)
        viewModel.category = category
        viewModel.sort = sort
        viewModel.type = type
        viewModel.todayDate = todayDate
        viewModel.isFeatured = isFeatured
        if isTodays{
            viewModel.hitTodaysEvents()
        }else{
            viewModel.hitForSpecificDay()
            
        }
        viewModel.notify = { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    override func initalSetup() {
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        var t = ""
        if isTodays{
            t = "Today’s Events"
        }else{
            t = dayString
        }
        setNavigationBar(title: t, backButton: true)
        addRightButtonToNavigation()
    }
    
    override func rightBarButtonTapped(_ sender: UIButton) {
        let vc = EventFilterVC.instantiate(fromAppStoryboard: .Home)
        vc.modalTransitionStyle = .coverVertical
        vc.sortedBy = sort
        vc.modalPresentationStyle = .overFullScreen
        vc.delegate = self
        present(vc, animated: false, completion: nil)
    }
    
    private func addPullToRefresh(){
        refreshController.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.refreshControl = refreshController
    }
    
    @objc func refresh(){
        tableView.reloadData()
        refreshController.endRefreshing()
    }
    
    private func viewDetail(_ e:Event){
        let vc = EventGroupListVC.instantiate(fromAppStoryboard: .Home)
        vc.event = e
        AppRouter.pushViewController(self, vc)
    }
    
    
    
}


extension TodaysEventListVC : UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return viewModel.dataSource.liveEvents.count
        case 1:
            return (viewModel.dataSource.upcoming.count > 0 ? viewModel.dataSource.upcoming.count + 1 : 0)
        default:
            return (viewModel.dataSource.ended.count > 0 ? viewModel.dataSource.ended.count + 1 : 0)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueCell(with: FeaturesTVCell.self)
            cell.populateData(viewModel.dataSource.liveEvents[indexPath.row])
            return cell
        case 1:
            if indexPath.row == 0{
                let cell = tableView.dequeueCell(with: ViewAllHeaderBtnTVCell.self)
                cell.headerLabel.text = "Upcoming"
                cell.viewAllBtn.isHidden = true
                return cell
            }else{
                let cell = tableView.dequeueCell(with: FeaturesTVCell.self)
                cell.populateData(viewModel.dataSource.upcoming[indexPath.row - 1])
                return cell
            }
        default:
            if indexPath.row == 0{
                let cell = tableView.dequeueCell(with: ViewAllHeaderBtnTVCell.self)
                cell.headerLabel.text = "Ended"
                cell.viewAllBtn.isHidden = true
                return cell
            }else{
                let cell = tableView.dequeueCell(with: FeaturesTVCell.self)
                cell.populateData(viewModel.dataSource.ended[indexPath.row - 1])
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            viewDetail(viewModel.dataSource.liveEvents[indexPath.row])
        case 1:
            if indexPath.row != 0{
                viewDetail(viewModel.dataSource.upcoming[indexPath.row - 1])
            }
        default:
            if indexPath.row != 0{
                viewDetail(viewModel.dataSource.ended[indexPath.row - 1])
            }
        }
    }
}

extension TodaysEventListVC : EventFilterDelegate{
    func getFilterType(_ type: SortingBy) {
        sort = type
        viewModel.sort = sort
        if isTodays{
            viewModel.hitTodaysEvents()
        }else{
            viewModel.hitForSpecificDay()
        }
    }
}
