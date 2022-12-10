//
//  EventFilterVC.swift
//  Stoke
//
//  Created by Admin on 19/03/21.
//

import UIKit

enum SortingBy:String{
    case time
    case alphabetical
    case trending
    case following
}

protocol EventFilterDelegate:AnyObject {
    func getFilterType(_ type:SortingBy)
}

class EventFilterVC: BaseVC {
    
    @IBOutlet var optionLabels:[UILabel]!
    @IBOutlet weak var btn1:UIButton!
    @IBOutlet weak var btn2:UIButton!
    @IBOutlet weak var btn3:UIButton!
    @IBOutlet weak var btn4:UIButton!
    @IBOutlet weak var selection1: UIButton!
    @IBOutlet weak var selection2: UIButton!
    @IBOutlet weak var selection3: UIButton!
    @IBOutlet weak var selection4: UIButton!
    @IBOutlet weak var bottomView: UIView!
    
    var sortedBy:SortingBy = .time
    weak var delegate:EventFilterDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        bottomView.roundCorner([.topLeft,.topRight], radius: 10)
    }
    
    override func initalSetup() {
        optionLabels.forEach {
            $0.font = AppFonts.Regular.withSize(16)
        }
        [btn1,btn2,btn3,btn4].forEach  {
            $0?.setImage(#imageLiteral(resourceName: "ic-check-inactive"), for: .normal)
            $0?.setImage(#imageLiteral(resourceName: "ic-check-active"), for: .selected)
            $0?.isSelected = false
        }
        switch sortedBy {
        case .time:
            btn1.isSelected = true
        case .alphabetical:
            btn2.isSelected = true
        case .trending:
            btn3.isSelected = true
        default:
            btn4.isSelected = true

        }
        
    }
    
    
    @IBAction func disMissView(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
    
    
    
    
    @IBAction func btnTapped(_ sender: UIButton) {
        
        switch sender {
        case selection1:
            setSeletion(btn1)
            delegate?.getFilterType(.time)
        case selection2:
            setSeletion(btn2)
            delegate?.getFilterType(.alphabetical)
        case selection3:
            setSeletion(btn3)
            delegate?.getFilterType(.trending)
        default:
            setSeletion(btn4)
            delegate?.getFilterType(.following)
        }
        dismiss(animated: false, completion: nil)

    }
    
    private func setSeletion(_ sender:UIButton){
        btn1.isSelected = sender == btn1
        btn2.isSelected = sender == btn2
        btn3.isSelected = sender == btn3
        btn4.isSelected = sender == btn4

    }
    

}
