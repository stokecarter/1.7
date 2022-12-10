//
//  AddPostVC.swift
//  Stoke
//
//  Created by Admin on 17/08/22.
//

import UIKit

protocol AddPostDelegate:AnyObject {
    func postUpdated()
}

class AddPostVC: BaseVC {
    //MARK: - IBOutlets
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    
    var viewModel:FeatureListVM!
    weak var delegate: AddPostDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func initalSetup() {
        textView.delegate = self
        textView.becomeFirstResponder()
    }

    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func postButtonTapped(_ sender: Any) {
        //Hit add post API
        viewModel.hitAddPostAPI(text: textView.text) {[weak self] postAdded in
            if postAdded {
                self?.dismiss(animated: true) {
                    self?.delegate?.postUpdated()
                }
            } else {
                let vc = DeleteChatRoomPopupVC.instantiate(fromAppStoryboard: .Events)
                vc.heading = "Sorry Hot Takes posting is closed for the week."
                vc.subheading = "The new week begins Monday morning and ends Friday night."
                vc.showOkOnly = true
                vc.modalTransitionStyle = .crossDissolve
                vc.modalPresentationStyle = .overFullScreen
                self?.present(vc, animated: false, completion: nil)
            }
        }
    }
}

extension AddPostVC: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        return newText.count < 201
    }
}
