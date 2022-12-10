//
//  CategoriesListVC.swift
//  Stoke
//
//  Created by Admin on 17/03/21.
//

import UIKit

class CategoriesListVC: BaseVC {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var viewModel:DiscoverVM!
    var refreshController = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) { [weak self] in
            self?.collectionView.reloadData()
        }
        addPullToRefresh()
        viewModel.notify = { [weak self] in
            self?.collectionView.reloadData()
        }
    }
    
    override func initalSetup() {
        setNavigationBar(title: "Categories", backButton: true)
        collectionView.registerCell(with: VeriticalGridCVCell.self)
        collectionView.delegate = self
        collectionView.dataSource = self
    }

    private func addPullToRefresh(){
        refreshController.addTarget(self, action: #selector(refresh), for: .valueChanged)
        collectionView.refreshControl = refreshController
    }
    
    @objc func refresh(){
        viewModel.hitApiForCategories(loader: true)
        refreshController.endRefreshing()
    }
}

extension CategoriesListVC : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueCell(with: VeriticalGridCVCell.self, indexPath: indexPath)
        cell.populateCell(viewModel.categories[indexPath.item])
        cell.imView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        cell.imView.contentMode = .scaleToFill
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 30)/2
        let height:CGFloat = width * 10/15
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard CommonFunctions.checkForInternet() else { return }
        let vc = CategoriesEventListVC.instantiate(fromAppStoryboard: .Home)
        vc.category = viewModel.categories[indexPath.row]
        AppRouter.pushViewController(self, vc)
    }
}
