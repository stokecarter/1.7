//
//  EventListVC.swift
//  Stoke
//
//  Created by Admin on 17/03/21.
//

import UIKit
import SwiftyJSON

class EventListVC: BaseVC {
    
    @IBOutlet weak var tableView: UITableView!
    var viewModel:SearchVM!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func initalSetup() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerCell(with: FeaturesTVCell.self)
    }
    
    func updateEmptyScreen(){
        tableView.emptyDataSetView { view in
            view.titleLabelString(NSAttributedString(string: "\n\nNo Events Found", attributes: [NSAttributedString.Key.font:AppFonts.Semibold.withSize(16),NSAttributedString.Key.foregroundColor:UIColor.black]))
                .image(#imageLiteral(resourceName: "ic-no-event"))
                .didTapDataButton {
                    
                }
                .didTapContentView {
                    // Do something
                }
        }
    }
    
}

extension EventListVC : UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.eventList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(with: FeaturesTVCell.self)
        cell.populateSearchData(viewModel.eventList[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = EventGroupListVC.instantiate(fromAppStoryboard: .Home)
        vc.event = viewModel.eventList[indexPath.row]
        CommonFunctions.navigationTitleImageView.isHidden = true
        AppRouter.pushViewController(self, vc)
    }
}


