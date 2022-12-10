//
//  EventListVC.swift
//  Stoke
//
//  Created by Admin on 12/04/21.
//

import UIKit

protocol SelectEventListDelegate:AnyObject {
    func getSelectedEvent(_ event:Event)
}

class SelectEventListVC: BaseVC {

    @IBOutlet weak var searchTF: UITextField!
    @IBOutlet weak var tableView: UITableView!
    var viewModel:SelectEventVM!
    weak var delegate:SelectEventListDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = SelectEventVM(NetworkLayer())
        self.viewModel.query = ""
        viewModel.notify = { [weak self] in
            self?.tableView.reloadData()
        }
        searchTF.addTarget(self, action: #selector(textFiedChangeEditing(_:)), for: .editingChanged)
        searchTF.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerCell(with: FeaturesTVCell.self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationBar(title: "Events", backButton: true)
    }
    
    
    @objc func textFiedChangeEditing(_ textField:UITextField){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [unowned self] in
            self.viewModel.query = textField.text ?? ""
        }
    }

}

extension SelectEventListVC : UITextFieldDelegate {
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        textField.text = nil
        view.endEditing(true)
        self.viewModel.query = textField.text ?? ""
        self.tableView.reloadData()
        return false
    }
}


extension SelectEventListVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(with: FeaturesTVCell.self)
        cell.populateSearchData(viewModel.events[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.getSelectedEvent(viewModel.events[indexPath.row])
        pop()
    }
}
