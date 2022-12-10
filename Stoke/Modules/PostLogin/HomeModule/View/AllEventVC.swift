//
//  AllEventVC.swift
//  Stoke
//
//  Created by Admin on 07/07/22.
//

import UIKit
import CoreMedia

class AllEventVC: BaseVC {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var featuredTableView: UITableView!
    @IBOutlet weak var calendarCV: UICollectionView!
    
    var calender: [EventCalendar] = AppCalendar.shared.returnFullCalender(true)
    var isTitleImageViewHiden:Bool = false{
        didSet{
            CommonFunctions.navigationTitleImageView.isHidden = isTitleImageViewHiden
        }
    }
    
    var fRefresh = UIRefreshControl()
    
    var viewModel:FeatureListVM!
    
    var height:CGFloat{
        return UIApplication.shared.statusBarFrame.height +
            self.navigationController!.navigationBar.frame.height
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isTitleImageViewHiden = true
        NotificationCenter.default.addObserver(self, selector: #selector(scrollToTop), name: NSNotification.Name.scrollTotop, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: .scrollTotop, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        StokeAnalytics.shared.setScreenVisitEvent(.visitFeaturedEvents)
        isTitleImageViewHiden = false
        setupView()
        applyTransparentBackgroundToTheNavigationBar(0)
        viewModel = FeatureListVM(NetworkLayer(), date: calender[4], allEvent: true)
        viewModel.notify = { [weak self] in
            self?.addEmptyScreens()
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
                self.calendarCV.reloadData()
                self.scrollFeaturelistToTop()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.calendarCV.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: true)
                }
            }else{
                printDebug("Error.....")
            }
        }
        [fRefresh].forEach { $0.addTarget(self, action: #selector(hitrefresh), for: .valueChanged)
        }
        featuredTableView.refreshControl = fRefresh
        scrollToTop()
    }
    
    private func setupView(){
        setNavigationBar(title: "All Events", backButton: true)
    }
    
    func addEmptyScreens(){
        var fetMsg = ""
        var fetIcon = UIImage()
        fetMsg = "\n\nNo Events Available"
        fetIcon = #imageLiteral(resourceName: "ic_no_event")
        
        featuredTableView.emptyDataSetView { view in
            view.titleLabelString(NSAttributedString(string: fetMsg, attributes: [NSAttributedString.Key.font:AppFonts.Semibold.withSize(16),NSAttributedString.Key.foregroundColor:UIColor.black]))
                .image(fetIcon)
                .isScrollAllowed(true)
        }
        featuredTableView.reloadData()
    }
    
    private func scrollFeaturelistToTop(){
        if let v = viewModel,v.allEvents.liveEvents.count > 0{
            featuredTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }else if let v = viewModel,v.allEvents.upcoming.count > 0{
            featuredTableView.scrollToRow(at: IndexPath(row: 0, section: 1), at: .top, animated: true)
        }else if let v = viewModel,v.allEvents.ended.count > 0{
            featuredTableView.scrollToRow(at: IndexPath(row: 0, section: 2), at: .top, animated: true)
        }
    }
    
    
    @objc func scrollToTop() {
        
        if viewModel.isDataLoaded{
            scrollView.setContentOffset(CGPoint.zero, animated: true)
            scrollFeaturelistToTop()
            for i in 0..<calender.count{
                calender[i].isCurrent = false
            }
            if viewModel.isOngoing{
                calender[1].isCurrent = true
                viewModel.hitAllEventsApi(date: calender[1], loader: false)
            }else{
                calender[0].isCurrent = true
                viewModel.hitAllEventsApi(date: calender[0], loader: false)
            }
            calendarCV.reloadData()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                let i = (self?.viewModel.isOngoing ?? false) ? 1 : 0
                self?.calendarCV.scrollToItem(at: IndexPath(item: i, section: 0), at: .centeredHorizontally, animated: true)
            }
        }
    }
    
    override func initalSetup() {
        scrollView.delegate = self
        [featuredTableView].forEach {
            $0?.registerCell(with: FeaturesTVCell.self)
            $0?.registerCell(with: ViewAllHeaderBtnTVCell.self)
            $0?.delegate = self
            $0?.dataSource = self
        }
        calendarCV.delegate = self
        calendarCV.dataSource = self
        if let flowLayout = calendarCV?.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = CGSize(width: 65, height: 80)//UICollectionViewFlowLayout.automaticSize
        }
    }
    
    @objc func hitrefresh(_ sender:UIRefreshControl){
        guard let d = calender.filter ({ $0.isCurrent }).first else { sender.endRefreshing()
            return }
        viewModel.hitAllEventsApi(date: d)
        sender.endRefreshing()
    }
    
    private func viewAllFor(_ data:SortedEvents){
        let vc = TodaysEventListVC.instantiate(fromAppStoryboard: .Home)
        vc.dayString = data.weakDay
        vc.isTodays = false
        vc.isFeatured = true
        vc.startDate = data.startTimeStamp
        vc.category = data.events.first?.category
        isTitleImageViewHiden = true
        AppRouter.pushViewController(self, vc)
    }
    
    private func viewEventChatroomList(_ m:Event){
        let vc = EventGroupListVC.instantiate(fromAppStoryboard: .Home)
        vc.event = m
        AppRouter.pushViewController(self, vc)
    }
}

extension AllEventVC : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        guard viewModel != nil else { return 0 }
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard viewModel != nil else { return 0 }
        if section == 0{
            return viewModel.allEvents.liveEvents.count
        }else if section == 1{
            return (viewModel.allEvents.upcoming.count > 0 ? viewModel.allEvents.upcoming.count + 1: 0)
        }else{
            return (viewModel.allEvents.ended.count > 0 ? viewModel.allEvents.ended.count + 1: 0)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueCell(with: FeaturesTVCell.self)
            cell.populateData(viewModel.allEvents.liveEvents[indexPath.row],isFeature: true)
            return cell
        case 1:
            if indexPath.row == 0{
                let cell = tableView.dequeueCell(with: ViewAllHeaderBtnTVCell.self)
                cell.headerLabel.text = "Upcoming"
                cell.viewAllBtn.isHidden = true
                return cell
            }else {
                let cell = tableView.dequeueCell(with: FeaturesTVCell.self)
                cell.populateData(viewModel.allEvents.upcoming[indexPath.row - 1],isFeature: true)
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
                cell.populateData(viewModel.allEvents.ended[indexPath.row - 1],isFeature: true)
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard CommonFunctions.checkForInternet() else { return }
        switch indexPath.section {
        case 0:
            viewEventChatroomList(viewModel.allEvents.liveEvents[indexPath.row])
        case 1:
            viewEventChatroomList(viewModel.allEvents.upcoming[indexPath.row - 1])
        default:
            viewEventChatroomList(viewModel.allEvents.ended[indexPath.row - 1])
        }
    }
}

extension AllEventVC : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
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
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            for i in 0..<AppCalendar.shared.fullCalendar.count{
                self.calender[i].isCurrent = false
            }
            self.calender[indexPath.item].isCurrent = true
            _ = self.viewModel.allEvents.clearAll()
            self.featuredTableView.reloadData()
            self.viewModel.hitAllEventsApi(date: self.calender[indexPath.item], loader: true)
            self.addEmptyScreens()
            collectionView.reloadData()
        }
    }
}
