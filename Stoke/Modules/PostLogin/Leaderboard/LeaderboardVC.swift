//
//  LeaderboardVC.swift
//  Stoke
//
//  Created by Admin on 27/04/21.
//

import UIKit

class LeaderboardVC: BaseVC {

    
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var clapbtn: UIButton!
    @IBOutlet weak var laughBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var viewModel:LeaderBoardVM!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = LeaderBoardVM(NetworkLayer())
        viewModel.reload = { [weak self] in
            self?.setupemptyScreen(self?.viewModel.type ?? .like)
            self?.tableView.reloadData()
            DispatchQueue.main.asyncAfter(deadline: .now()) { [weak self] in
                self?.setupemptyScreen(self?.viewModel.type ?? .like)
            }
        }
        setNavigationBar(title: "Overall Leaderboard", backButton: true)
        addRightButtonToNavigation(image: #imageLiteral(resourceName: "ic-filter"), title: nil)
        likeBtn.setImage(#imageLiteral(resourceName: "like-inactive"), for: .normal)
        likeBtn.setImage(#imageLiteral(resourceName: "like-active-1"), for: .selected)
        clapbtn.setImage(#imageLiteral(resourceName: "clap-inactive"), for: .normal)
        clapbtn.setImage(#imageLiteral(resourceName: "exclamation-active"), for: .selected)
        laughBtn.setImage(#imageLiteral(resourceName: "laugh-inactive-1"), for: .normal)
        laughBtn.setImage(#imageLiteral(resourceName: "laugh-active"), for: .selected)
        [likeBtn,clapbtn,laughBtn].forEach {
            $0?.setTitleColor(AppColors.themeColor, for: .selected)
            $0?.setTitleColor(AppColors.labelColor, for: .normal)
        }
        manageSelectedState(likeBtn)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let _ = viewModel{
            viewModel.hitLeaderBoardApi(type: viewModel.type) {}
        }
    }
    
    override func initalSetup() {
        tableView.registerCell(with: HeaderTVCell.self)
        tableView.registerCell(with: LeaderboardListTVCell.self)
        tableView.delegate = self
        tableView.dataSource = self
        setupemptyScreen(.like)
    }
    
    override func rightBarButtonTapped(_ sender: UIButton) {
        viewModel.hitApiForCategories { [weak self](data) in
            guard let self = self else { return }
            let vc = LeaderBoardFilterVC.instantiate(fromAppStoryboard: .Chat)
            vc.cID = self.viewModel.cID
            vc.delegate = self
            vc.modalPresentationStyle = .overFullScreen
            vc.modalTransitionStyle = .coverVertical
            vc.categories = data
            self.present(vc, animated: false, completion: nil)
        }
    }
    
    @IBAction func trendingBtnSelection(_ sender: UIButton) {
        switch sender {
        case likeBtn:
            viewModel.hitLeaderBoardApi(type: .like) { [weak self] in
                self?.manageSelectedState(sender)
            }
        case clapbtn:
            viewModel.hitLeaderBoardApi(type: .clap) { [weak self] in
                self?.manageSelectedState(sender)
            }
        default:
            viewModel.hitLeaderBoardApi(type: .laugh) { [weak self] in
                self?.manageSelectedState(sender)
            }
        }
    }
    
    private func openCompleteList(){
        let vc = AllLeaderborduserVC.instantiate(fromAppStoryboard: .Chat)
        vc.dataSource = viewModel.completeData
        vc.type = viewModel.type
        AppRouter.pushFromTabbar(vc)
    }
    
    private func setupemptyScreen(_ type:LeaderBordType){
        var lbl:String = ""
        var icon:UIImage = UIImage()
        switch type {
        case .like:
            lbl = "No Users Found"
            icon = #imageLiteral(resourceName: "no-most-like-available")
        case .laugh:
            lbl = "No Users Found"
            icon = #imageLiteral(resourceName: "No Most laugh Available")
        default:
            lbl = "No Users Found"
            icon = #imageLiteral(resourceName: "ic-exclamation-black-2")
        }
        tableView.emptyDataSetView { view in
            view.titleLabelString(NSAttributedString(string: "\n\n\(lbl)", attributes: [NSAttributedString.Key.font:AppFonts.Semibold.withSize(16),NSAttributedString.Key.foregroundColor:UIColor.black]))
                .image(icon)
        }
    }
    
    private func manageSelectedState(_ sender:UIButton){
        switch sender {
        case likeBtn:
            sender.addShadow()
            sender.isSelected = true
            clapbtn.isSelected = false
            laughBtn.isSelected = false
            clapbtn.dropShadow()
            laughBtn.dropShadow()
        case clapbtn:
            sender.isSelected = true
            likeBtn.isSelected = false
            laughBtn.isSelected = false
            sender.addShadow()
            likeBtn.dropShadow()
            laughBtn.dropShadow()
        default:
            sender.isSelected = true
            likeBtn.isSelected = false
            clapbtn.isSelected = false
            sender.addShadow()
            likeBtn.dropShadow()
            clapbtn.dropShadow()
        }
    }
}

extension LeaderboardVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if viewModel == nil || viewModel.leaderBoard.isEmpty{
            return 0
        }else{
            if viewModel.leaderBoard.count > 2{
                return viewModel.leaderBoard.count - 2
            }else{
                return 1
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0{
            let cell = tableView.dequeueCell(with: HeaderTVCell.self)
            cell.openuserProfile = { [weak self] rank in
                switch rank {
                case 1:
                    if let index = self?.viewModel.leaderBoard.firstIndex(where: {$0.rank == 1}){
                        let id = self?.viewModel.leaderBoard[index]._id ?? ""
                        CommonFunctions.navigateToUserProfile(id,onParent: self)
                    }
                case 2:
                    if let index = self?.viewModel.leaderBoard.firstIndex(where: {$0.rank == 2}){
                        let id = self?.viewModel.leaderBoard[index]._id ?? ""
                        CommonFunctions.navigateToUserProfile(id,onParent: self)
                    }
                default:
                    if let index = self?.viewModel.leaderBoard.firstIndex(where: {$0.rank == 3}){
                        let id = self?.viewModel.leaderBoard[index]._id ?? ""
                        CommonFunctions.navigateToUserProfile(id,onParent: self)
                    }
                }
            }
            cell.tapOnImage = { [weak self] rank in
                guard let self = self else { return }
                switch rank {
                case 1:
                    if self.viewModel.totalFirstRank > 1{
                        self.openCompleteList()
                    }else{
                        if let index = self.viewModel.leaderBoard.firstIndex(where: {$0.rank == 1}){
                            let id = self.viewModel.leaderBoard[index]._id
                            CommonFunctions.navigateToUserProfile(id,onParent: self)
                        }
                    }
                case 2:
                    if self.viewModel.totalSecondRank > 1{
                        self.openCompleteList()
                    }else{
                        if let index = self.viewModel.leaderBoard.firstIndex(where: {$0.rank == 2}){
                            let id = self.viewModel.leaderBoard[index]._id
                            CommonFunctions.navigateToUserProfile(id,onParent: self)
                        }
                    }
                default:
                    if self.viewModel.totalThirdRank > 1{
                        self.openCompleteList()
                    }else{
                        if let index = self.viewModel.leaderBoard.firstIndex(where: {$0.rank == 3}){
                            let id = self.viewModel.leaderBoard[index]._id
                            CommonFunctions.navigateToUserProfile(id,onParent: self)
                        }
                    }
                }
            }
            cell.firstRankCount.text = viewModel.totalFirstRank > 1 ? "+\(viewModel.totalFirstRank - 1)" : ""
            cell.secondRankCount.text = viewModel.totalSecondRank > 1 ? "+\(viewModel.totalSecondRank - 1)" : ""
            cell.thirdRankCount.text = viewModel.totalThirdRank > 1 ? "+\(viewModel.totalThirdRank - 1)" : ""
            cell.populateCell(viewModel.leaderBoard, type: viewModel.type)
            return cell
        }else{
            let cell = tableView.dequeueCell(with: LeaderboardListTVCell.self)
            cell.populateCell(viewModel.leaderBoard[indexPath.row + 2], type: viewModel.type)
            cell.openUserProfile = { [weak self] in
                guard let self = self else { return }
                let id = self.viewModel.leaderBoard[indexPath.row + 2]._id
                CommonFunctions.navigateToUserProfile(id,onParent:self)
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0{
            return 270
        }else{
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row != 0{
            let id = self.viewModel.leaderBoard[indexPath.row + 2]._id
            CommonFunctions.navigateToUserProfile(id,onParent:self)
        }
    }
    
}


extension LeaderboardVC : LeaderBoardFilterDelegate {
    func getCID(_ id: Categories?) {
        if let id = id{
            viewModel.cID = id.id
            setNavigationBar(title: id.name, backButton: true)
            viewModel.hitLeaderBoardApi(type: viewModel.type) {}
        }else{
            viewModel.cID = ""
            setNavigationBar(title: "Overall Leaderboard", backButton: true)
            viewModel.hitLeaderBoardApi(type: viewModel.type) {}
        }
    }
}
