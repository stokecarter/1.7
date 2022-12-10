//
//  HomeVC.swift
//  Stoke
//
//  Created by Admin on 16/03/21.
//

import UIKit

enum HotTakeListType: String {
    case new = "new"
    case top = "top"
    case allTime = "all-time"
    case myTakes = "my-takes"
    
    func title() -> String {
        switch self {
        case .new:
            return "New"
        case .top:
            return "Top"
        case .allTime:
            return "All Time"
        case .myTakes:
            return "My Takes"
        }
    }
    
    static func allTypes() -> [HotTakeListType] {
        return [.new, .top, .allTime, .myTakes]
    }
}

class HomeVC: BaseVC {
    
    @IBOutlet weak var featuredBtn: UIButton!
    @IBOutlet weak var recommendedBtn: UIButton!
    @IBOutlet weak var sliderContainerView: UIView!
    @IBOutlet weak var slidderView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var featuredTableView: UITableView!
    @IBOutlet weak var recommendedTV: UITableView!
    @IBOutlet weak var calendarCV: UICollectionView!
    @IBOutlet weak var hotTakesCV: UICollectionView!
    @IBOutlet weak var addPostButton: UIButton!
    
    var calender:[EventCalendar] = AppCalendar.shared.returnOneWeekCalender(true)
//    var hotTakeOptions: []
    var isTitleImageViewHiden:Bool = false{
        didSet{
            CommonFunctions.navigationTitleImageView.isHidden = isTitleImageViewHiden
        }
    }
    
    var fRefresh = UIRefreshControl()
    var rRefresh = UIRefreshControl()
    
    var selectedType: HotTakeListType = .new
    var viewModel:FeatureListVM!
    
    var height:CGFloat{
        return UIApplication.shared.statusBarFrame.height +
            self.navigationController!.navigationBar.frame.height
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isTitleImageViewHiden = false
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
        addNavBarImage()
        applyTransparentBackgroundToTheNavigationBar(0)
        viewModel = FeatureListVM(NetworkLayer(), date: calender[1])
        viewModel.notify = { [weak self] in
            self?.addEmptyScreens()
        }
        viewModel.updateCalender = { [weak self] flag in
            guard let self = self else { return }
            if let d = self.calender.filter ({ $0.isCurrent }).first{
                var index = 0
                self.calender = AppCalendar.shared.returnOneWeekCalender(flag)
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
        [fRefresh,rRefresh].forEach { $0.addTarget(self, action: #selector(hitrefresh), for: .valueChanged)
        }
        recommendedTV.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 0, right: 0)
        featuredTableView.refreshControl = fRefresh
        recommendedTV.refreshControl = rRefresh
        scrollToTop()
        
        addPostButton.shadowColor = #colorLiteral(red: 0.368627451, green: 0.368627451, blue: 0.368627451, alpha: 0.5)
        addPostButton.shadowOffset = .zero
        addPostButton.shadowOpacity = 1.0
        addPostButton.shadowRadius = 10
    }
    
    func addNavBarImage() {
        CommonFunctions.navigationTitleImageView.image = #imageLiteral(resourceName: "ic-stoke-red-small")
        CommonFunctions.navigationTitleImageView.contentMode = .scaleAspectFit
        CommonFunctions.navigationTitleImageView.translatesAutoresizingMaskIntoConstraints = false
        CommonFunctions.navigationTitleImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(handelTapOnHeader))
        CommonFunctions.navigationTitleImageView.addGestureRecognizer(tap)
        if let navC = self.navigationController{
            navC.navigationBar.addSubview(CommonFunctions.navigationTitleImageView)
            CommonFunctions.navigationTitleImageView.centerXAnchor.constraint(equalTo: navC.navigationBar.centerXAnchor).isActive = true
            CommonFunctions.navigationTitleImageView.centerYAnchor.constraint(equalTo: navC.navigationBar.centerYAnchor, constant: -3).isActive = true
            CommonFunctions.navigationTitleImageView.widthAnchor.constraint(equalTo: navC.navigationBar.widthAnchor, multiplier: 0.3).isActive = true
            CommonFunctions.navigationTitleImageView.heightAnchor.constraint(equalTo: navC.navigationBar.widthAnchor, multiplier: 0.2).isActive = true
        }
    }
    
    func addEmptyScreens(){
        var fetMsg = ""
        var trendMsg = ""
        var fetIcon = UIImage()
        var trendIcon = UIImage()
        if featuredBtn.isSelected{
            if viewModel.isDataLoaded{
            fetMsg = "\n\nNo Featured Events Available"
            fetIcon = #imageLiteral(resourceName: "ic_no_event")
            }
        }else{
            if viewModel.isDataLoaded{
            trendMsg = "\n\nNo Hot Takes Available"
            trendIcon = #imageLiteral(resourceName: "ic-no-event")
            }
        }
        featuredTableView.emptyDataSetView { view in
            view.titleLabelString(NSAttributedString(string: fetMsg, attributes: [NSAttributedString.Key.font:AppFonts.Semibold.withSize(16),NSAttributedString.Key.foregroundColor:UIColor.black]))
                .image(fetIcon)
                .isScrollAllowed(true)
        }
        recommendedTV.emptyDataSetView { view in
            view.titleLabelString(NSAttributedString(string: trendMsg, attributes: [NSAttributedString.Key.font:AppFonts.Semibold.withSize(16),NSAttributedString.Key.foregroundColor:UIColor.black]))
                .image(trendIcon)
                .isScrollAllowed(true)
            
        }
        recommendedTV.reloadData()
        featuredTableView.reloadData()
    }
    
    private func scrollFeaturelistToTop(){
        if let v = viewModel,v.dataSource.liveEvents.count > 0{
            featuredTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }else if let v = viewModel,v.dataSource.upcoming.count > 0{
            featuredTableView.scrollToRow(at: IndexPath(row: 0, section: 1), at: .top, animated: true)
        }else if let v = viewModel,v.dataSource.ended.count > 0{
            featuredTableView.scrollToRow(at: IndexPath(row: 0, section: 2), at: .top, animated: true)
        }
    }
    
    
    @objc func scrollToTop() {
        setSelectedButton(featuredBtn)
        if viewModel.isDataLoaded{
            scrollView.setContentOffset(CGPoint.zero, animated: true)
            scrollFeaturelistToTop()
            for i in 0..<calender.count{
                calender[i].isCurrent = false
            }
            if viewModel.isOngoing{
                calender[1].isCurrent = true
                viewModel.hitFeaturesApi(date: calender[1], loader: false)
            }else{
                calender[0].isCurrent = true
                viewModel.hitFeaturesApi(date: calender[0], loader: false)
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
        [recommendedTV,featuredTableView].forEach {
            $0?.registerCell(with: FeaturesTVCell.self)
            $0?.registerCell(with: HotTakesTVCell.self)
            $0?.registerCell(with: ViewAllHeaderBtnTVCell.self)
            $0?.delegate = self
            $0?.dataSource = self
        }
        calendarCV.delegate = self
        calendarCV.dataSource = self
        hotTakesCV.delegate = self
        hotTakesCV.dataSource = self
        if let flowLayout = calendarCV?.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = CGSize(width: 65, height: 80)//UICollectionViewFlowLayout.automaticSize
        }
        if let flowLayout = hotTakesCV?.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = CGSize(width: 65, height: 80)//UICollectionViewFlowLayout.automaticSize
        }
        
    }
    
    override func setupFounts() {
        featuredBtn.isSelected = true
        featuredBtn.setTitle("Featured Events", for: .normal)
        recommendedBtn.setTitle("Hot Takes", for: .normal)
        [featuredBtn,recommendedBtn].forEach { $0?.setTitleColor(AppColors.themeColor, for: .selected)
            $0?.setTitleColor(#colorLiteral(red: 0.7882352941, green: 0.7882352941, blue: 0.7882352941, alpha: 1), for: .normal)
            $0?.titleLabel?.font = AppFonts.Medium.withSize(16)
        }
    }
    
    @objc func hitrefresh(_ sender:UIRefreshControl){
        guard let d = calender.filter ({ $0.isCurrent }).first else { sender.endRefreshing()
            return }
        viewModel.trendingCurrentPage = 1
        viewModel.hitFeaturesApi(date: d)
        viewModel.hitForHotTakes(type: selectedType, loader: true)
        sender.endRefreshing()
    }
    
    
    // Mark:- IBActions
    
    @IBAction func featuredTapped(_ sender: UIButton) {
        addEmptyScreens()
        setSelectedButton(sender)
        StokeAnalytics.shared.setScreenVisitEvent(.visitFeaturedEvents)
        scrollView.setContentOffset(CGPoint.zero, animated: true)
    }
    
    @IBAction func recommendedTapped(_ sender: UIButton) {
        addEmptyScreens()
        StokeAnalytics.shared.setScreenVisitEvent(.visitTrendingEvents)
        if let v = viewModel,v.posts.data.count > 0{
            recommendedTV.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
        self.setSelectedButton(sender)
        self.scrollView.setContentOffset(CGPoint(x: self.view.bounds.width, y: 0), animated: true)
    }
    
    @IBAction func addPostButtonTapped(_ sender: Any) {
        viewModel.hitCheckWeekdayAPI {[weak self] isWeekday in
            if isWeekday {
                //Push add post controller
                let vc = AddPostVC.instantiate(fromAppStoryboard: .Home)
                vc.delegate = self
                vc.viewModel = self?.viewModel
                vc.modalPresentationStyle = .fullScreen
                vc.modalTransitionStyle = .coverVertical
                self?.present(vc, animated: true, completion: nil)
            } else {
                let vc = DeleteChatRoomPopupVC.instantiate(fromAppStoryboard: .Events)
                vc.heading = "Sorry Hot Takes posting is closed for the week."
                vc.subheading = "The new week begins Monday morning and ends Friday night."
                vc.showOkOnly = true
                vc.modalTransitionStyle = .crossDissolve
                vc.modalPresentationStyle = .overFullScreen
                self?.present(vc, animated: false, completion: nil)
            }
        }
    }
    
    
    private func setSelectedButton(_ sender:UIButton){
        featuredBtn.isSelected   = sender === featuredBtn ? true:false
        recommendedBtn.isSelected   = sender === recommendedBtn ? true:false
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

// Mark:- UIScrollView

extension HomeVC : UIScrollViewDelegate    {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView)    {
        if self.scrollView === scrollView {
            let width = scrollView.width/slidderView.width
            let scroll = scrollView.contentOffset.x
            slidderView.transform = CGAffineTransform(translationX: scroll/width, y: 0)
            switch scroll {
            case  0:
                setSelectedButton(featuredBtn)
            case  UIDevice.width :
                viewModel.trendingCurrentPage = 1
                viewModel.hitForHotTakes(type: selectedType, loader: true)
                setSelectedButton(recommendedBtn)
            default :
                break
            }
        }
        
        if scrollView === recommendedTV {
            let height = scrollView.frame.size.height
            let contentYoffset = scrollView.contentOffset.y
            let distanceFromBottom = scrollView.contentSize.height - contentYoffset
            
            if distanceFromBottom < height && ((viewModel.posts.totalCount - (viewModel.posts.page * viewModel.posts.limit)) > 0){
                if viewModel.posts.isLoaded {
                    self.viewModel.posts.isLoaded = false
                    viewModel.trendingCurrentPage += 1
                    viewModel.hitForHotTakes(type: viewModel.hotTakeType)
                }
            } else {
                printDebug("Else.......")
            }
        }
        //else if scrollView === featuredTableView{
//            if ((scrollView.contentOffset.y + scrollView.frame.size.height) > scrollView.contentSize.height ) && viewModel.dataSource.data.count < viewModel.dataSource.totalCount {
//                viewModel.currentPage += 1
//                viewModel.hitFeaturesApi(date: calender.filter { $0.isCurrent}.first!, loader: false)
//            }
        //}else if scrollView === recommendedTV{
            //            if ((scrollView.contentOffset.y + scrollView.frame.size.height) > scrollView.contentSize.height ) && viewModel.trending.data.count < viewModel.trending.totalCount {
            //                viewModel.trendingCurrentPage += 1
            //                viewModel.hitForTrending(date: calender[1])
            //            }
       // }
    }
}


extension HomeVC : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView === featuredTableView{
            guard viewModel != nil else { return 0 }
            return 3
        }else{
            return 1
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView === featuredTableView{
            guard viewModel != nil else { return 0 }
            if section == 0{
                return (viewModel.dataSource.liveEvents.count > 0 ? viewModel.dataSource.liveEvents.count + 1: 0)
            }else if section == 1{
                return (viewModel.dataSource.upcoming.count > 0 ? viewModel.dataSource.upcoming.count + 1 : 0)
            }else{
                return (viewModel.dataSource.ended.count > 0 ? viewModel.dataSource.ended.count + 1 : 0)
            }
        }else{
            guard viewModel != nil else { return 0 }
            return viewModel.posts.data.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView === featuredTableView{
            switch indexPath.section {
            case 0:
                if indexPath.row == 0{
                    let cell = tableView.dequeueCell(with: ViewAllHeaderBtnTVCell.self)
                    cell.headerLabel.text = ""
                    cell.btnAction = {
                        print("ViewAll TApped")
                        let vc = AllEventVC.instantiate(fromAppStoryboard: .Home)
                        AppRouter.pushViewController(self, vc)
                    }
                    return cell
                } else {
                    let cell = tableView.dequeueCell(with: FeaturesTVCell.self)
                    cell.populateData(viewModel.dataSource.liveEvents[indexPath.row - 1],isFeature: true)
                    return cell
                }
            case 1:
                if indexPath.row == 0{
                    let cell = tableView.dequeueCell(with: ViewAllHeaderBtnTVCell.self)
                    cell.headerLabel.text = "Upcoming"
                    cell.btnAction = {
                        print("ViewAll TApped")
                        let vc = AllEventVC.instantiate(fromAppStoryboard: .Home)
                        AppRouter.pushViewController(self, vc)
                    }
//                    cell.viewAllBtn.isHidden = true
                    return cell
                }else{
                    let cell = tableView.dequeueCell(with: FeaturesTVCell.self)
                    cell.populateData(viewModel.dataSource.upcoming[indexPath.row - 1],isFeature: true)
                    return cell
                }
            default:
                if indexPath.row == 0{
                    let cell = tableView.dequeueCell(with: ViewAllHeaderBtnTVCell.self)
                    cell.headerLabel.text = "Ended"
                    cell.btnAction = {
                        print("ViewAll TApped")
                        let vc = AllEventVC.instantiate(fromAppStoryboard: .Home)
                        AppRouter.pushViewController(self, vc)
                    }
//                    cell.viewAllBtn.isHidden = true
                    return cell
                }else{
                    let cell = tableView.dequeueCell(with: FeaturesTVCell.self)
                    cell.populateData(viewModel.dataSource.ended[indexPath.row - 1],isFeature: true)
                    return cell
                }
            }
        }else{
            let cell = tableView.dequeueCell(with: HotTakesTVCell.self)
            cell.populateData(viewModel.posts.data[indexPath.row])
            cell.upButtonTapped = {[weak self] in
                //upvoted
                print("up up up vote")
                self?.viewModel.hitVoteAPI(postId: self?.viewModel.posts.data[indexPath.row].id ?? "", vote: 1) {//[weak self] in
                    tableView.reloadRows(at: [indexPath], with: .automatic)
                }
            }
            
            cell.downButtonTapped = {[weak self] in
                // downvoted
                print("down down down vote")
                self?.viewModel.hitVoteAPI(postId: self?.viewModel.posts.data[indexPath.row].id ?? "", vote: -1) {//[weak self] in
                    tableView.reloadRows(at: [indexPath], with: .automatic)
                }
            }
            
            cell.handelLongPress = {[weak self] in
                print("Hot takes longPress")
                let vc = TwoBtnPopup.instantiate(fromAppStoryboard: .Home)
                let t = (self?.viewModel.posts.data[indexPath.row].isOwnPost ?? false) ? "Delete": "Report"
                vc.btn1Title = t
                vc.btn2Title = "Cancel"
                vc.section = indexPath.row
                vc.modalPresentationStyle = .overFullScreen
                vc.modalTransitionStyle = .coverVertical
                vc.delagate = self
                self?.present(vc, animated: false, completion: nil)
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView === featuredTableView{
            guard CommonFunctions.checkForInternet() else { return }
            switch indexPath.section {
            case 0:
                if indexPath.row != 0{
                    viewEventChatroomList(viewModel.dataSource.liveEvents[indexPath.row - 1])
                }
            case 1:
                if indexPath.row != 0{
                    viewEventChatroomList(viewModel.dataSource.upcoming[indexPath.row - 1])
                }
            default:
                if indexPath.row != 0{
                    viewEventChatroomList(viewModel.dataSource.ended[indexPath.row - 1])
                }
            }
        }else{
//            guard CommonFunctions.checkForInternet() else { return }
//            let vc = EventGroupListVC.instantiate(fromAppStoryboard: .Home)
//            vc.event = viewModel.trending.data[indexPath.row]
//            AppRouter.pushViewController(self, vc)
        }
    }
}



extension HomeVC : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionView == calendarCV ? calender.count: 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == calendarCV {
            let cell = collectionView.dequeueCell(with: CalenderCVCell.self, indexPath: indexPath)
            cell.isselectedDate = calender[indexPath.item].isCurrent
            cell.data = calender[indexPath.item]
            return cell
        } else {
            let cell = collectionView.dequeueCell(with: CalenderCVCell.self, indexPath: indexPath)
            cell.isselectedDate = selectedType == HotTakeListType.allTypes()[indexPath.row]
            cell.timeLabel.text = HotTakeListType.allTypes()[indexPath.row].title()
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = calender[indexPath.item].toShowDate.widthOfText(28, font: AppFonts.Bold.withSize(18)) + 28
        return CGSize(width: width, height: 65)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == calendarCV {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                for i in 0..<AppCalendar.shared.oneWeek.count{
                    self.calender[i].isCurrent = false
                }
                self.calender[indexPath.item].isCurrent = true
                _ = self.viewModel.dataSource.clearAll()
                self.featuredTableView.reloadData()
                self.viewModel.hitFeaturesApi(date: self.calender[indexPath.item], loader: true)
                self.addEmptyScreens()
                collectionView.reloadData()
            }
        } else {
            if selectedType == HotTakeListType.allTypes()[indexPath.row] {
                
            } else {
                viewModel.trendingCurrentPage = 1
                selectedType = HotTakeListType.allTypes()[indexPath.row]
                self.recommendedTV.reloadData()
                self.viewModel.hitForHotTakes(type: selectedType, loader: true)
                self.addEmptyScreens()
                collectionView.reloadData()
            }
        }
    }
}





class CalenderCVCell : UICollectionViewCell {
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var bgView: UIView!
    
    var data:EventCalendar? = nil{
        didSet{
            if let e = data{
                if e.date.isToday{
                    timeLabel.text = e.toShowDate
                }else{
                    let b = e.weekDay
                    let n = e.calendarDate
                    let t = b + " " + n
                    timeLabel.attributedText = retunAttributedText(b, text: t,isselectedDate:isselectedDate)
                }
            }
        }
    }
    
    var isselectedDate:Bool = false {
        didSet{
            if isselectedDate{
                bgView.backgroundColor = AppColors.themeColor
                timeLabel.textColor = .white
            }else{
                bgView.backgroundColor = .white
                timeLabel.textColor = #colorLiteral(red: 0.3098039216, green: 0.3098039216, blue: 0.3098039216, alpha: 1)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        timeLabel.font = AppFonts.Bold.withSize(15)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        printDebug(bgView.frame.height)
        bgView.layer.cornerRadius = 17//bgView.bounds.height/2
        bgView.shadowColor = #colorLiteral(red: 0.368627451, green: 0.368627451, blue: 0.368627451, alpha: 0.16)
        bgView.shadowOffset = .zero
        bgView.shadowOpacity = 1.0
        bgView.shadowRadius = 3
    }
    
    
    private func retunAttributedText(_ bold:String, text:String,isselectedDate:Bool) -> NSAttributedString{
        let color:UIColor = isselectedDate ? #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0) : #colorLiteral(red: 0.3098039216, green: 0.3098039216, blue: 0.3098039216, alpha: 1)
        let attributedString = NSMutableAttributedString(string: text,
                                                         attributes: [NSAttributedString.Key.font: AppFonts.Medium.withSize(15),NSAttributedString.Key.foregroundColor:color])
        let boldFontAttribute: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: AppFonts.Bold.withSize(15),NSAttributedString.Key.foregroundColor:color]
        let range = (text as NSString).range(of: bold)
        attributedString.addAttributes(boldFontAttribute, range: range)
        return attributedString
    }
}

extension HomeVC : ThreeBtnPopupDelegate{
    func getUserChoice(_ index:Int,section:Int) {
        if index == 0{
            if viewModel.posts.data[section].isOwnPost {
                let vc = DeleteChatRoomPopupVC.instantiate(fromAppStoryboard: .Events)
                vc.heading = "Delete Hot Take"
                vc.subheading = "Are you sure you want to delete this Hot Take?"
                vc.deleteBtnTitle = "Delete"
                vc.section = section
                vc.delegate = self
                vc.modalTransitionStyle = .crossDissolve
                vc.modalPresentationStyle = .overFullScreen
                self.present(vc, animated: false, completion: nil)
            } else {
                let vc = DeleteChatRoomPopupVC.instantiate(fromAppStoryboard: .Events)
                vc.heading = "Report Hot Take"
                vc.subheading = "Are you sure you want to report this Hot Take?"
                vc.deleteBtnTitle = "Report"
                vc.section = section
                vc.delegate = self
                vc.modalTransitionStyle = .crossDissolve
                vc.modalPresentationStyle = .overFullScreen
                self.present(vc, animated: false, completion: nil)
            }
        }else{
            printDebug("do noting...")
        }
}
    
}

extension HomeVC: AddPostDelegate {
    func postUpdated() {
        self.viewModel.trendingCurrentPage = 1
        self.viewModel.hitForHotTakes(type: selectedType, loader: true)
        self.recommendedTV.reloadData()
        self.addEmptyScreens()
    }
}

extension HomeVC : DeleteChatRoomPopupDelegate {
    func deleteTapped(index:Int) {
        if viewModel.posts.data[index].isOwnPost {
            viewModel.hitDeletePostAPI(postId: viewModel.posts.data[index].id) {//[weak self] in
                //                    self?.postUpdated()
            }
        } else {
            viewModel.hitReportPostAPI(postId: viewModel.posts.data[index].id) {
                //                    print("Post reported")
            }
        }
        
    }
}
