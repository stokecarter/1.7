//
//  TwoTabsProfileTVCell.swift
//  Stoke
//
//  Created by Admin on 17/05/21.
//

import UIKit

class TwoTabsProfileTVCell: UITableViewCell {
    
    @IBOutlet weak var savedCommnetsBtn: UIButton!
    @IBOutlet weak var saveTaggsBtn: UIButton!
    @IBOutlet weak var saveCommnetsTV: UITableView!
    @IBOutlet weak var tagsCV: UICollectionView!
    @IBOutlet weak var sliderContainerView: UIView!
    @IBOutlet weak var slidderView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
        
    var selectionMade:((ProfileSections)->())?
    
    var getTableViewContentSize:((CGFloat)->())?
    var getCollectionViewContentSize:((CGFloat)->())?

    
    override func awakeFromNib() {
        super.awakeFromNib()
        scrollView.delegate = self
        setupFounts()
        saveCommnetsTV.delegate = self
        saveCommnetsTV.dataSource = self
        tagsCV.delegate = self
        tagsCV.dataSource = self
        tagsCV.registerCell(with: TagsCVCell.self)
        saveCommnetsTV.registerCell(with: CommnetTVCell.self)
        saveCommnetsTV.registerCell(with: CommnetReactionTVCell.self)
        saveCommnetsTV.registerCell(with: ChatroomNameTVCell.self)
        saveCommnetsTV.emptyDataSetView { view in
            view.titleLabelString(NSAttributedString(string: "\n\nYour saved comments will appear here!", attributes: [NSAttributedString.Key.font:AppFonts.Semibold.withSize(16),NSAttributedString.Key.foregroundColor:UIColor.black]))
                .image(#imageLiteral(resourceName: "ic-no-chatroom"))
        }
        tagsCV.emptyDataSetView { view in
            view.titleLabelString(NSAttributedString(string: "\n\nYour saved tags will appear here!", attributes: [NSAttributedString.Key.font:AppFonts.Semibold.withSize(16),NSAttributedString.Key.foregroundColor:UIColor.black]))
                .image(#imageLiteral(resourceName: "no_tag"))
        }
    }
    
    var tapedOnCommnet:((Int)->())?
    var tapOnTags:(()->())?
    
    private var commnets:[Comment] = []{
        didSet{
            saveCommnetsTV.reloadData()
        }
    }
    
    private var tags:[Tag] = []{
        didSet{
            tagsCV.reloadData()
        }
    }
    
    @IBAction func saveBtnTapped(_ sender: Any) {
        setSelectedButton(savedCommnetsBtn)
        scrollView.setContentOffset(CGPoint(x: self.contentView.bounds.width, y: 0), animated: true)
    }
    
    @IBAction func saveTagsBtnTapped(_ sender: Any) {
        setSelectedButton(saveTaggsBtn)
        scrollView.setContentOffset(CGPoint.zero, animated: true)
    }
    
    private func setSelectedButton(_ sender:UIButton){
        savedCommnetsBtn.isSelected   = sender === saveTaggsBtn ? true:false
        saveTaggsBtn.isSelected   = sender === savedCommnetsBtn ? true:false
    }
    
    private func setupFounts() {
        saveTaggsBtn.isSelected = true
        [savedCommnetsBtn,saveTaggsBtn].forEach {
            $0?.setTitleColor(AppColors.themeColor, for: .selected)
            $0?.setTitleColor(#colorLiteral(red: 0.7882352941, green: 0.7882352941, blue: 0.7882352941, alpha: 1), for: .normal)
            $0?.titleLabel?.font = AppFonts.Medium.withSize(14)
        }
    }
    
    
    func populateCommnetCell(_ dataSource:[Comment]){
        commnets = dataSource
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }
            if let size = self.getTableViewContentSize { size(self.saveCommnetsTV.contentSize.height)}
        }
    }
    
    func populateTags(_ dataSource:[Tag]){
        tags = dataSource
    }
    
}


extension TwoTabsProfileTVCell : UIScrollViewDelegate {
    
    
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView)    {
        if scrollView === saveCommnetsTV{
            if scrollView.contentOffset.y <= 0{
                scrollView.isScrollEnabled = false
            }
        }
        if scrollView === tagsCV{
            if scrollView.contentOffset.y <= 0{
                scrollView.isScrollEnabled = false
            }
        }
        if scrollView === tagsCV{
            if scrollView.contentOffset.y <= 0{
                scrollView.isScrollEnabled = false
            }
        }
        guard self.scrollView === scrollView else {
            return
        }
        
        let width = scrollView.width/slidderView.width
        let scroll = scrollView.contentOffset.x
        slidderView.transform = CGAffineTransform(translationX: scroll/width, y: 0)
        switch scroll {
        case  0:
            if let selection = selectionMade { selection(.savedCommnets)}
            setSelectedButton(savedCommnetsBtn)
        case  UIDevice.width :
            if let selection = selectionMade { selection(.savedTaggs)}
            setSelectedButton(saveTaggsBtn)
        default :
            break
        }
    }
}


extension TwoTabsProfileTVCell : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return commnets.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0{
            let cell = tableView.dequeueCell(with: CommnetTVCell.self)
            cell.populateCell(commnets[indexPath.section])
            cell.openProfileTapped = { [weak self] in
                CommonFunctions.navigateToUserProfile(self?.commnets[indexPath.section].user.id ?? "")
            }
            cell.handelLongPress = { [weak self] in
                CommonFunctions.vaibratePhone()
                if let tap = self?.tapedOnCommnet { tap(indexPath.section)}
            }
            return cell
        }else if indexPath.row  == 1 {
            let cell = tableView.dequeueCell(with: CommnetReactionTVCell.self)
            cell.populateCommnetReacts(model: commnets[indexPath.section])
            cell.buttonStackBottomHeight.constant = -3
            cell.layoutIfNeeded()
            return cell
        }else{
            let cell = tableView.dequeueCell(with: ChatroomNameTVCell.self)
            let t = "in \(commnets[indexPath.section].event.name)"
            cell.roomNameLabel.text = t
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

}


extension TwoTabsProfileTVCell :  UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueCell(with: TagsCVCell.self, indexPath: indexPath)
        cell.populateCell(tags[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 60)/3
        let height:CGFloat = 118
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        CommonFunctions.actionOnTags(tags[indexPath.item].id, action: !tags[indexPath.item].isSaved) { [weak self] in
            self?.tags[indexPath.item].isSaved.toggle()
            collectionView.reloadData()
        }
    }
    
}
