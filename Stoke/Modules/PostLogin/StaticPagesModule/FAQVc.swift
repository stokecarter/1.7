//
//  FAQVc.swift
//  Stoke
//
//  Created by Admin on 29/10/21.
//

import UIKit

class FAQVc: BaseVC {
    
    var viewModel: FAQVm!
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialSetup()
        observerSetup()
    }
}

extension FAQVc{
    
    private func initialSetup(){
        viewModel = FAQVm()
        setNavigationBar(title: "FAQs", backButton: true)
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func observerSetup(){
        viewModel.refresh = { [weak self] in
            self?.tableView.reloadData()
        }
    }
}

extension FAQVc: UITableViewDelegate, UITableViewDataSource{
   
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.list.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            let faqObj = viewModel.list[section]
            return faqObj.isOpen ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0{
            let cell = tableView.dequeueCell(with: FAQSectionCell.self)
            cell.question = viewModel.list[indexPath.section].question
            cell.isOpen = viewModel.list[indexPath.section].isOpen
            return cell
        }else{
            let cell = tableView.dequeueCell(with: FAQCell.self)
            cell.answer = viewModel.list[indexPath.section].answer
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            
            if viewModel.list[indexPath.section].isOpen{
                viewModel.list[indexPath.section].isOpen = false
                let sections = IndexSet.init(integer: indexPath.section)
                tableView.reloadSections(sections, with: .none)
            }else{
                viewModel.list[indexPath.section].isOpen = true
                let sections = IndexSet.init(integer: indexPath.section)
                tableView.reloadSections(sections, with: .none)
            }
    }
}
