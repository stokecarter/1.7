//
//  MyPaymnetsVC.swift
//  Stoke
//
//  Created by Admin on 12/05/21.
//

import UIKit

class MyPaymnetsVC: BaseVC {
    
    
    @IBOutlet weak var searchTF: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    var refresh = UIRefreshControl()
    var isFresh:Bool = true
    
    var viewModel:MyPaymnetsVM!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar(title: "My Payments", backButton: true)
        applyTransparentBackgroundToTheNavigationBar(100)

        addRightButtonToNavigation(image: #imageLiteral(resourceName: "ic-filter"))
        viewModel = MyPaymnetsVM(NetworkLayer())
        viewModel.reload = { [weak self] in
            self?.tableView.reloadData()
        }
        searchTF.addTarget(self, action: #selector(textFiedChangeEditing(_:)), for: .editingChanged)
        searchTF.delegate = self
        refresh.addTarget(self, action: #selector(pullToRefresh(_:)), for: .valueChanged)
        tableView.refreshControl = refresh
    }
    
    override func initalSetup() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerCell(with: MyPaymentsTVCell.self)
        tableView.emptyDataSetView { view in
            view.titleLabelString(NSAttributedString(string: "\n\nNo Payment Available", attributes: [NSAttributedString.Key.font:AppFonts.Semibold.withSize(16),NSAttributedString.Key.foregroundColor:UIColor.black]))
                .image(#imageLiteral(resourceName: "no_payment"))
                .didTapDataButton {
                    
                }
                .didTapContentView {
                    // Do something
                }
        }
    }
    
    override func rightBarButtonTapped(_ sender: UIButton) {
        let vc = PaymnetFilterVC.instantiate(fromAppStoryboard: .Chat)
        vc.modalTransitionStyle = .coverVertical
        vc.modalPresentationStyle = .overFullScreen
        vc.delegate = self
        if !isFresh{
            vc.isFresh = isFresh
            vc.amount = viewModel.maxPrice
            vc.fromDt = viewModel.fromDate
            vc.toDate = viewModel.toDate
        }
        present(vc, animated: false, completion: nil)
    }
    
    @objc func pullToRefresh(_ sender:UIRefreshControl){
        sender.endRefreshing()
        viewModel.hitPaymnetList()
    }
    
    @objc func textFiedChangeEditing(_ textField:UITextField){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [unowned self] in
            self.viewModel.search = textField.text ?? ""
        }
    }
}

extension MyPaymnetsVC : UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel != nil ? viewModel.dataSource.count : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(with: MyPaymentsTVCell.self)
        cell.populateCell(viewModel.dataSource[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = PaymentDetailVC.instantiate(fromAppStoryboard: .Chat)
        vc.model = viewModel.dataSource[indexPath.row]
        AppRouter.pushViewController(self, vc)
    }
    
}


extension MyPaymnetsVC : UITextFieldDelegate {
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        textField.text = nil
        viewModel.search = ""
        view.endEditing(true)
        return false
    }
}


extension MyPaymnetsVC : PaymnetFilterDelegate {
    func getFilterData(_ fDate: Date?, toDate: Date?, amount: Double?) {
        isFresh = false
        viewModel.fromDate = fDate
        viewModel.toDate = toDate
        viewModel.maxPrice = amount ?? 0.0
        viewModel.hitPaymnetList()
    }
    
    func clearFilter() {
        isFresh = true
        viewModel.fromDate = nil
        viewModel.toDate = nil
        viewModel.maxPrice = 200
        viewModel.hitPaymnetList()
    }
    

}
