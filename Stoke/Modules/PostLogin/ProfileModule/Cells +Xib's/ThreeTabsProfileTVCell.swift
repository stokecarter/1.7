//
//  ThreeTabsProfileTVCell.swift
//  Stoke
//
//  Created by Admin on 17/05/21.
//

import UIKit

class ThreeTabsProfileTVCell: UITableViewCell {
    
    @IBOutlet weak var savedCommnetsBtn: UIButton!
    @IBOutlet weak var saveChatRoomsBtn: UIButton!
    @IBOutlet weak var saveTaggsBtn: UIButton!
    @IBOutlet weak var saveCommnetsTV: UITableView!
    @IBOutlet weak var savedChatroomsCV: UICollectionView!
    @IBOutlet weak var tagsCV: UICollectionView!
    @IBOutlet weak var sliderContainerView: UIView!
    @IBOutlet weak var slidderView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var privateProfileView: UIView!
    
    var selectionMade:((ProfileSections)->())?
    
    var isPrivate:Bool = false{
        didSet{
            privateProfileView.isHidden = !isPrivate
        }
    }
    
        
    private var commnets:[Comment] = []{
        didSet{
            saveCommnetsTV.reloadData()
        }
    }
    
    var innerScrolling:((Bool,CGFloat)->())?
    var lastContentOffset:CGFloat = 0.0
    var tapOnTags:(()->())?
    var tapOnChatRooms:((ChatRoom)->())?
    private var tags:[Tag] = []{
        didSet{
            tagsCV.reloadData()
        }
    }
    
    private var rooms:[ChatRoom] = []{
        didSet{
            savedChatroomsCV.reloadData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        scrollView.delegate = self
        setupFounts()
        saveCommnetsTV.delegate = self
        saveCommnetsTV.dataSource = self
        [tagsCV,savedChatroomsCV].forEach {
            $0?.delegate = self
            $0?.dataSource = self
        }
        tagsCV.registerCell(with: TagsCVCell.self)
        saveCommnetsTV.registerCell(with: CommnetTVCell.self)
        saveCommnetsTV.registerCell(with: CommnetReactionTVCell.self)
        saveCommnetsTV.registerCell(with: ChatroomNameTVCell.self)
        savedChatroomsCV.registerCell(with: GroupCVCell.self)
        savedChatroomsCV.emptyDataSetView { view in
            view.titleLabelString(NSAttributedString(string: "\n\nNo Saved Rooms Available", attributes: [NSAttributedString.Key.font:AppFonts.Semibold.withSize(16),NSAttributedString.Key.foregroundColor:UIColor.black]))
                .image(#imageLiteral(resourceName: "ic-no-chatroom"))
        }
        saveCommnetsTV.emptyDataSetView { view in
            view.titleLabelString(NSAttributedString(string: "\n\nNo Saved Comments Available", attributes: [NSAttributedString.Key.font:AppFonts.Semibold.withSize(16),NSAttributedString.Key.foregroundColor:UIColor.black]))
                .image(#imageLiteral(resourceName: "ic-no-chatroom"))
        }
        tagsCV.emptyDataSetView { view in
            view.titleLabelString(NSAttributedString(string: "\n\nNo Tags Available", attributes: [NSAttributedString.Key.font:AppFonts.Semibold.withSize(16),NSAttributedString.Key.foregroundColor:UIColor.black]))
                .image(#imageLiteral(resourceName: "no_tag"))
        }
    }
    
    @IBAction func saveBtnTapped(_ sender: Any) {
        setSelectedButton(savedCommnetsBtn)
        scrollView.setContentOffset(CGPoint(x: self.contentView.bounds.width*2, y: 0), animated: true)
    }
    
    @IBAction func saveRoomBtnTapped(_ sender: Any) {
        setSelectedButton(saveChatRoomsBtn)
        scrollView.setContentOffset(CGPoint(x: self.contentView.bounds.width, y: 0), animated: true)
    }
    
    @IBAction func saveTagsBtnTapped(_ sender: Any) {
        setSelectedButton(saveTaggsBtn)
        scrollView.setContentOffset(CGPoint.zero, animated: true)
    }
    
    private func setSelectedButton(_ sender:UIButton){
        savedCommnetsBtn.isSelected   = sender === savedCommnetsBtn ? true:false
        saveChatRoomsBtn.isSelected = sender === saveChatRoomsBtn ? true : false
        saveTaggsBtn.isSelected   = sender === saveTaggsBtn ? true:false
    }
    
    private func setupFounts() {
        saveTaggsBtn.isSelected = true
        [savedCommnetsBtn,saveChatRoomsBtn,saveTaggsBtn].forEach {
            $0?.setTitleColor(AppColors.themeColor, for: .selected)
            $0?.setTitleColor(#colorLiteral(red: 0.7882352941, green: 0.7882352941, blue: 0.7882352941, alpha: 1), for: .normal)
            $0?.titleLabel?.font = AppFonts.Semibold.withSize(12)
        }
    }
    func populateCommnetCell(_ dataSource:[Comment]){
        commnets = dataSource
    }
    
    func populateTags(_ dataSource:[Tag]){
        tags = dataSource
    }
    
    func populateSaveRooms(_ dataSource:[ChatRoom]){
        rooms = dataSource
    }
    
        
}

extension ThreeTabsProfileTVCell : UITableViewDelegate, UITableViewDataSource {
    
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
            return cell
        }else if indexPath.row == 1{
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
    
    
}


extension ThreeTabsProfileTVCell :  UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView === tagsCV{
            return tags.count
        }else{
            return rooms.count
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView === tagsCV{
            let cell = collectionView.dequeueCell(with: TagsCVCell.self, indexPath: indexPath)
            cell.populateCell(tags[indexPath.item])
            return cell
        }else{
            let cell = collectionView.dequeueCell(with: GroupCVCell.self, indexPath: indexPath)
            cell.populatecell(rooms[indexPath.item])
            cell.viewDetailTapped = { [weak self] in
                guard let self = self else { return }
                if let t = self.tapOnChatRooms { t(self.rooms[indexPath.item])}
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView === tagsCV{
            let width = (collectionView.bounds.width - 60)/3
            let height:CGFloat = 118
            return CGSize(width: width, height: height)
        }else{
            let width = (collectionView.frame.width - 20)/2
            return CGSize(width: width, height: 215)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView === tagsCV{
            CommonFunctions.actionOnTags(tags[indexPath.item].id, action: !tags[indexPath.item].isSaved) { [weak self] in
                self?.tags[indexPath.item].isSaved.toggle()
                collectionView.reloadData()
            }
        }else{
            if let t = self.tapOnChatRooms { t(self.rooms[indexPath.item])}
        }
    }
}


extension ThreeTabsProfileTVCell : UIScrollViewDelegate {
    
    
    
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
        if scrollView === savedChatroomsCV{
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
            setSelectedButton(saveTaggsBtn)
        case  UIDevice.width :
            if let selection = selectionMade { selection(.savedCommnets)}
            setSelectedButton(saveChatRoomsBtn)
        case UIDevice.width*2:
            if let selection = selectionMade { selection(.savedCommnets)}
            setSelectedButton(savedCommnetsBtn)
        default :
            break
        }
    }
}

