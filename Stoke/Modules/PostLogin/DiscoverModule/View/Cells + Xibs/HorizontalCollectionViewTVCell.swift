//
//  HorizontalCollectionViewTVCell.swift
//  Stoke
//
//  Created by Admin on 17/03/21.
//

import UIKit

protocol HorizontalCollectionViewDelegate:AnyObject {
    func getSelectedCategory(_ category:Categories)
}

class HorizontalCollectionViewTVCell: UITableViewCell {

    
    @IBOutlet weak var collectionView: UICollectionView!
    weak var delegate:HorizontalCollectionViewDelegate?
    
    
    
    var dataSource:[Categories] = []{
        didSet{
            collectionView.reloadData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initialSetup()
        
    }
    
    private func initialSetup(){
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal
        collectionView!.collectionViewLayout = layout
        collectionView.registerCell(with: HorizontalGridCVCell.self)
        collectionView.delegate = self
        collectionView.dataSource = self
    }


    
}

extension HorizontalCollectionViewTVCell : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count > 5 ? 5 : dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueCell(with: HorizontalGridCVCell.self, indexPath: indexPath)
        cell.populateCell(dataSource[indexPath.item])
        cell.imView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.bounds.height
        let width = height * 15/10
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.getSelectedCategory(dataSource[indexPath.item])
    }
}
