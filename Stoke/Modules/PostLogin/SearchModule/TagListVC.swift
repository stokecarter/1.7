//
//  TagListVC.swift
//  Stoke
//
//  Created by Admin on 17/03/21.
//

import UIKit
import SwiftyJSON

class TagListVC: BaseVC {
    
    var dataSource:TagListModel = TagListModel(JSON()){
        didSet{
            collectionView.reloadData()
        }
    }

    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func initalSetup() {
        collectionView.registerCell(with: TagsCVCell.self)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func updateEmptyScreen(){
        collectionView.emptyDataSetView { view in
            view.titleLabelString(NSAttributedString(string: "\n\nNo Tags Found", attributes: [NSAttributedString.Key.font:AppFonts.Semibold.withSize(16),NSAttributedString.Key.foregroundColor:UIColor.black]))
                .image(#imageLiteral(resourceName: "no_tag"))
                .didTapDataButton {
                    
                }
                .didTapContentView {
                    // Do something
                }
        }
    }

}

extension TagListVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.data.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueCell(with: TagsCVCell.self, indexPath: indexPath)
        cell.populateCell(dataSource.data[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 60)/3
        let height:CGFloat = 118
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        CommonFunctions.actionOnTags(dataSource.data[indexPath.item].id, action: !dataSource.data[indexPath.item].isSaved) { [weak self] in
            self?.dataSource.data[indexPath.item].isSaved.toggle()
            self?.collectionView.reloadData()
        }
    }
}
