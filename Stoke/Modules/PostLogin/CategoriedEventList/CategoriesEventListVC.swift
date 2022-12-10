//
//  CategoriesEventListVC.swift
//  Stoke
//
//  Created by Admin on 19/03/21.
//

import UIKit

class CategoriesEventListVC: BaseVC {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var calenderCollectionView: UICollectionView!
    
    var category:Categories!
    var calender = AppCalendar.shared.returnFullCalender(false)
    var viewModel:CategoriesEventList!
    var refresh = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = CategoriesEventList(NetworkLayer(), categoryId: category.id)
        addEmptyScreen()
        viewModel.getEvent(date: calender[3], loader: true)
        viewModel.notifyUpdate = { [weak self] in
            self?.addEmptyScreen()
        }
        viewModel.updateCalender = { [weak self] flag in
            guard let self = self else { return }
            if let d = self.calender.filter ({ $0.isCurrent }).first{
                var index = 0
                self.calender = AppCalendar.shared.returnFullCalender(flag)
                for i in 0..<self.calender.count{
                    if self.calender[i].isOngoing && self.calender[i].toShowDate == d.toShowDate{
                        self.calender[i].isCurrent = true
                        index = i
                    }else if self.calender[i].date == d.date{
                        self.calender[i].isCurrent = true
                        index = i
                    }else{
                        self.calender[i].isCurrent = false
                    }
                }
                if index != self.calender.count - 1{
                    self.calenderCollectionView.reloadData()
                }
                self.scrollFeaturelistToTop()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    if index == self.calender.count - 2{
                        self.calenderCollectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: true)
                    }else if index == self.calender.count - 1{
                        self.calenderCollectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .left, animated: true)
                    }else{
                        self.calenderCollectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: true)
                    }
                    
                }
            }else{
                printDebug("Error.....")
            }
        }
        if let flowLayout = calenderCollectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = CGSize(width: 65, height: 80)
        }
        refresh.addTarget(self, action: #selector(hitrefresh), for: .valueChanged)
        tableView.refreshControl = refresh
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func initalSetup() {
        setNavigationBar(title: category.name, backButton: true)
        tableView.delegate = self
        tableView.dataSource = self
        calenderCollectionView.delegate = self
        calenderCollectionView.dataSource = self
        tableView.registerCell(with: FeaturesTVCell.self)
        tableView.registerCell(with: ViewAllHeaderBtnTVCell.self)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.calenderCollectionView.scrollToItem(at: IndexPath(item: 4, section: 0), at: .centeredHorizontally, animated: false)
        }
    }
    
    
    private func addEmptyScreen(){
        var msg = ""
        var icon = UIImage()
        if viewModel.isDataLoaded{
            msg = "\n\nNo Events Available"
            icon = #imageLiteral(resourceName: "ic-no-event")
        }
        tableView.emptyDataSetView { view in
            view.titleLabelString(NSAttributedString(string: msg, attributes: [NSAttributedString.Key.font:AppFonts.Semibold.withSize(16),NSAttributedString.Key.foregroundColor:UIColor.black]))
                .image(icon)
                .didTapDataButton {
                    
                }
                .didTapContentView {
                    // Do something
                }
        }
        tableView.reloadData()

    }
    
    @objc func hitrefresh(_ sender:UIRefreshControl){
        guard let d = calender.filter ({ $0.isCurrent }).first else { sender.endRefreshing()
            return }
        viewModel.getEvent(date: d, loader: true)
        sender.endRefreshing()
    }
    
    
    
    private func navigateToDetail(_ e:Event){
        let vc = EventGroupListVC.instantiate(fromAppStoryboard: .Home)
        vc.event = e
        AppRouter.pushViewController(self, vc)
    }
    
    private func scrollFeaturelistToTop(){
        if !viewModel.upcomingEvents.liveEvents.isEmpty{
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }else if !viewModel.upcomingEvents.upcoming.isEmpty{
            tableView.scrollToRow(at: IndexPath(row: 0, section: 1), at: .top, animated: true)
        }else if !viewModel.upcomingEvents.ended.isEmpty{
            tableView.scrollToRow(at: IndexPath(row: 0, section: 2), at: .top, animated: true)
        }
    }
}



extension CategoriesEventListVC : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        3
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return viewModel.upcomingEvents.liveEvents.count
        case 1:
            return (viewModel.upcomingEvents.upcoming.count > 0 ?  viewModel.upcomingEvents.upcoming.count + 1 : 0)
        default:
            return (viewModel.upcomingEvents.ended.count > 0 ?  viewModel.upcomingEvents.ended.count + 1 : 0)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueCell(with: FeaturesTVCell.self)
            cell.populateData(viewModel.upcomingEvents.liveEvents[indexPath.row],isFeature:true)
            return cell
        case 1:
            if indexPath.row == 0{
                let cell = tableView.dequeueCell(with: ViewAllHeaderBtnTVCell.self)
                cell.headerLabel.text = "Upcoming"
                cell.viewAllBtn.isHidden = true
                return cell
            }else{
                let cell = tableView.dequeueCell(with: FeaturesTVCell.self)
                cell.populateData(viewModel.upcomingEvents.upcoming[indexPath.row - 1],isFeature:true)
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
                cell.populateData(viewModel.upcomingEvents.ended[indexPath.row - 1],isFeature:true)
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            navigateToDetail(viewModel.upcomingEvents.liveEvents[indexPath.row])
        case 1:
            if indexPath.row != 0{
                navigateToDetail(viewModel.upcomingEvents.upcoming[indexPath.row - 1])
            }
        default:
            if indexPath.row != 0{
                navigateToDetail(viewModel.upcomingEvents.ended[indexPath.row - 1])
            }
        }
    }
}


extension CategoriesEventListVC : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return calender.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueCell(with: CalenderCVCell.self, indexPath: indexPath)
        cell.isselectedDate = calender[indexPath.item].isCurrent
        cell.data = calender[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = calender[indexPath.item].toShowDate.widthOfText(28, font: AppFonts.Bold.withSize(18)) + 28
        return CGSize(width: width, height: 65)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let index = calender.firstIndex(where: { $0.isCurrent }){
            calender[index].isCurrent = false
            guard let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? CalenderCVCell else { return }
            cell.isselectedDate = false
        }
        calender[indexPath.item].isCurrent = true
        guard let cell = collectionView.cellForItem(at: indexPath) as? CalenderCVCell else { return }
        cell.isselectedDate = true
        scrollFeaturelistToTop()
        viewModel.getEvent(date: calender[indexPath.item], loader: true)
        _ = viewModel.upcomingEvents.clearAll()
        addEmptyScreen()
    }
}
