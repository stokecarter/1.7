//
//  LeaderBoardFimterVC.swift
//  Stoke
//
//  Created by Admin on 27/04/21.
//

import UIKit

protocol LeaderBoardFilterDelegate:AnyObject {
    func getCID(_ id:Categories?)
}

class LeaderBoardFilterVC: BaseVC {
    

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var filterViewheight: NSLayoutConstraint!
    
    
    
    var categories:[Categories] = []
    var cID:String = ""
    weak var delegate:LeaderBoardFilterDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bgView.roundCorner([.topRight,.topLeft], radius: 25)
        tableView.reloadData()
        if self.tableView.contentSize.height >= (self.view.height/2){
            self.filterViewheight.constant = self.view.height/2 + 60
        }else{
            self.filterViewheight.constant = self.tableView.contentSize.height + 60
        }
        self.view.layoutIfNeeded()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        bgView.roundCorner([.topRight,.topLeft], radius: 25)
    }
    
    override func initalSetup() {
        tableView.delegate = self
        tableView.dataSource = self
        
        
        
    }

    @IBAction func dismissview(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
}


extension LeaderBoardFilterVC : UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(with: LBFilterTVCell.self)
        if indexPath.row == 0{
            cell.selectionBtn.isSelected = cID == ""
            cell.populate(nil)
        }else{
            cell.selectionBtn.isSelected = cID == categories[indexPath.row - 1].id
            cell.populate(categories[indexPath.row - 1])
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        cID = indexPath.row == 0 ? "" : categories[indexPath.row - 1].id
        tableView.reloadData()
        dismiss(animated: false) { [weak self] in
            guard let self = self else { return }
            self.delegate?.getCID(indexPath.row == 0 ? nil : self.categories[indexPath.row - 1])
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}


class LBFilterTVCell:UITableViewCell {
    
    @IBOutlet weak var selectionBtn:UIButton!
    @IBOutlet weak var catLabel:UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionBtn.setImage(#imageLiteral(resourceName: "ic-check-inactive"), for: .normal)
        selectionBtn.setImage(#imageLiteral(resourceName: "ic-check-active"), for: .selected)
        selectionBtn.isUserInteractionEnabled = false
    }
    
    func populate(_ c:Categories? = nil){
        if let cat = c{
            catLabel.text = cat.name
        }else{
            catLabel.text = "Overall"
        }
    }
}
