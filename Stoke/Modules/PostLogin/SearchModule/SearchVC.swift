//
//  SearchVC.swift
//  Stoke
//
//  Created by Admin on 17/03/21.
//

import UIKit

class SearchVC: BaseVC {
    
    
    @IBOutlet weak var userBtn: UIButton!
    @IBOutlet weak var eventBtn: UIButton!
    @IBOutlet weak var tagsBtn: UIButton!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var searchTF: UITextField!
    @IBOutlet weak var slidderView: UIView!

    var firstVC:UserListVC!
    var secondVC:EventListVC!
    var thirdVC:TagListVC!
    
    var viewModel:SearchVM!

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = SearchVM(NetworkLayer())
        scrollView.delegate = self
        loadViewControllers()
        searchTF.addTarget(self, action: #selector(textFiedChangeEditing(_:)), for: .editingChanged)
        searchTF.delegate = self
        viewModel.notifyTypeChage = { [weak self] in
            self?.searchTF.text = nil
            self?.view.endEditing(true)
        }
        viewModel.reloadData = { [weak self] in
            guard let self = self else { return }
            if self.viewModel.searchStyle == .user{
                self.firstVC.updateEmptyScreen()
            }else if self.viewModel.searchStyle == .event{
                self.secondVC.updateEmptyScreen()
            }else{
                self.thirdVC.updateEmptyScreen()
            }
            self.firstVC.tableView.reloadData()
            self.secondVC.tableView.reloadData()
            self.thirdVC.dataSource = self.viewModel.tagList
        }
    }
    
    override func initalSetup() {
        setNavigationBar(title: "Search", backButton: true)
        userBtn.isSelected = true
    }
    
    override func setupFounts() {
        [userBtn,eventBtn,tagsBtn].forEach {
            $0?.setTitleColor(AppColors.themeColor, for: .selected)
            $0?.setTitleColor(AppColors.labelColor, for: .normal)
            $0?.titleLabel?.font = AppFonts.Medium.withSize(14)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setUpViewControllersFrame()
    }
    
    // Mark:- IBActions
    
    @IBAction func userTapped(_ sender: UIButton) {
        viewModel.searchStyle = .user
        setSelectedButton(sender)
        scrollView.setContentOffset(CGPoint.zero, animated: true)
    }
    
    @IBAction func eventTapped(_ sender: UIButton) {
        viewModel.searchStyle = .event
        setSelectedButton(sender)
        scrollView.setContentOffset(CGPoint(x: self.view.bounds.width, y: 0), animated: true)
    }
    
    @IBAction func taggsTapped(_ sender: UIButton) {
        viewModel.searchStyle = .tag
        setSelectedButton(sender)
        scrollView.setContentOffset(CGPoint(x: self.view.bounds.width*2, y: 0), animated: true)
    }
    
    
    @objc func textFiedChangeEditing(_ textField:UITextField){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [unowned self] in
            self.viewModel.searchQuery = textField.text ?? ""
        }
    }
    
    private func loadViewControllers(){
        
        // Loading First VC
        firstVC = UserListVC.instantiate(fromAppStoryboard: .Home)
        firstVC.viewModel = viewModel
        contentView.addSubview(firstVC.view)
        addChild(firstVC)
        
        // Loading Second VC
        secondVC = EventListVC.instantiate(fromAppStoryboard: .Home)
        secondVC.viewModel = viewModel
        contentView.addSubview(secondVC.view)
        addChild(secondVC)
        
        // Loading Third VC
        thirdVC = TagListVC.instantiate(fromAppStoryboard: .Home)
        contentView.addSubview(thirdVC.view)
        addChild(thirdVC)
        
    }
    
    private func setUpViewControllersFrame(){
        
        let width = UIDevice.width
        let height = contentView.height
        
        
        //Setting frame VC
        DispatchQueue.main.async { [unowned self] in
            self.firstVC.view.frame = CGRect(x: 0, y: 0, width: width, height: height)
            self.secondVC.view.frame = CGRect(x: width, y: 0, width: width, height: height)
            self.thirdVC.view.frame = CGRect(x: width*2, y: 0, width: width, height: height)
        }
        
    }
    
    private func setSelectedButton(_ sender:UIButton){
        
        userBtn.isSelected   = sender === userBtn ? true:false
        eventBtn.isSelected   = sender === eventBtn ? true:false
        tagsBtn.isSelected   = sender === tagsBtn ? true:false
    }

}


// Mark:- UIScrollView

extension SearchVC : UIScrollViewDelegate    {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView)    {
        let width = scrollView.width/slidderView.width
        let scroll = scrollView.contentOffset.x
        slidderView.transform = CGAffineTransform(translationX: scroll/width, y: 0)
        switch scroll {
        case  0:
            setSelectedButton(userBtn)
        case  UIDevice.width :
            setSelectedButton(eventBtn)
        case (UIDevice.width * 2):
            setSelectedButton(tagsBtn)
        default :
            break
        }
    }
}


extension SearchVC : UITextFieldDelegate {
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        textField.text = nil
        view.endEditing(true)
        _ = viewModel.clearData
        return false
    }
}
