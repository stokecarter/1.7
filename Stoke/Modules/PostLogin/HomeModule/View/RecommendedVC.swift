//
//  RecommendedVC.swift
//  Stoke
//
//  Created by Admin on 16/03/21.
//

import UIKit

class RecommendedVC: BaseVC {
    
    
    @IBOutlet weak var tableView: UITableView!
    var refreshController = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.emptyDataSetView { view in
            view.titleLabelString(NSAttributedString(string: "\n\nNo Recommended", attributes: [NSAttributedString.Key.font:AppFonts.Semibold.withSize(16),NSAttributedString.Key.foregroundColor:UIColor.black]))
                .image(#imageLiteral(resourceName: "ic-no-event"))
                .didTapDataButton {
                    
                }
                .didTapContentView {
                    
                }
        }
    }
    
    private func addPullToRefresh(){
        refreshController.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.refreshControl = refreshController
    }
    
    @objc func refresh(){
        tableView.reloadData()
        refreshController.endRefreshing()
    }
    
}
