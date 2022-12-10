//
//  ImageViewWithPreview.swift
//  Jhaiho
//
//  Created by Bhavneet Singh on 05/01/18.
//  Copyright © 2018 Bhavneet Singh. All rights reserved.
//

import UIKit

protocol ImageViewWithPreviewDelegate: NSObjectProtocol {
    func imageViewWithPreview(willPreview imageView: ImageViewWithPreview)
    func imageViewWithPreview(didPreview imageView: ImageViewWithPreview)
}

class ImageViewWithPreview: UIImageView {

    @objc enum ImageType: Int {
        case Circle = 0, Rectangle = 1, Square = 2
        
        static func initialize(with: Int) -> ImageType {
            return with == 0 ? ImageType.Circle : with == 1 ? ImageType.Rectangle : ImageType.Square
        }
    }
    
    @objc enum GestureType: Int {
        case tap = 0, longPress = 1
        
        static func initialize(with: Int) -> GestureType {
            return with == 0 ? GestureType.tap : GestureType.longPress
        }
    }

    private var imageType: ImageType = .Rectangle
    private var gestureType: GestureType = .longPress
    
    @IBInspectable var previewType: Int = 0 {
        didSet{
            self.imageType = ImageType.initialize(with: previewType)
        }
    }
    
    weak var delegate: ImageViewWithPreviewDelegate?
    
    private var imageGesture: UIGestureRecognizer!
    private var backViewTapGesture: UITapGestureRecognizer!
    var previewViewController: UIViewController!
    var backDarkView: UIView!
    var transitionImageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.initialSetup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.initialSetup()
    }
    
    override init(image: UIImage?) {
        super.init(image: image)
        
        self.initialSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.initialSetup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.setupFrames()
    }
    
    private func initialSetup() {
    
        if self.gestureType == .tap {
            self.isUserInteractionEnabled = true
            self.imageGesture = UITapGestureRecognizer(target: self, action: #selector(ImageViewWithPreview.showImage))
            self.addGestureRecognizer(self.imageGesture)
        } else if self.gestureType == .longPress {
            self.isUserInteractionEnabled = true
            self.imageGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.longPressAction(_:)))
            self.addGestureRecognizer(self.imageGesture)
        }
        
    }
    
    private func setupFrames() {
        
        
    }
    
    private func replicate(image: UIImage) -> UIImageView {
        let replicateImage = UIImageView(image: self.image)
        replicateImage.clipsToBounds = self.clipsToBounds
        replicateImage.frame = self.superview?.convert(self.frame, to: nil) ?? self.frame
        replicateImage.layer.cornerRadius = self.layer.cornerRadius
        replicateImage.contentMode = self.contentMode
        replicateImage.isUserInteractionEnabled = true
        return replicateImage
    }
}

extension ImageViewWithPreview {
    
    @objc private func longPressAction(_ gesture: UILongPressGestureRecognizer) {
        
        switch gesture.state {
        case .began:
            self.showImage()
        case .ended:
            self.hideImage()
        default: break
        }
    }
    
    @objc private func showImage() {
        
        self.delegate?.imageViewWithPreview(willPreview: self)

        guard let _ = self.image, let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        self.transitionImageView = self.replicate(image: self.image!)
        self.backDarkView = UIView(frame: UIScreen.main.bounds)
        self.backViewTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.hideImage))
        appDelegate.window?.addSubview(self.backDarkView)
        appDelegate.window?.addSubview(self.transitionImageView)
        self.backDarkView.addGestureRecognizer(self.backViewTapGesture)
        self.backDarkView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.6)
        self.backDarkView.alpha = 0
        self.transitionImageView.alpha = 0
        let fullScreenWidth = UIScreen.main.bounds.width-50
        let fullScreenHeight = UIScreen.main.bounds.height-50
        let fullScreenSize: CGSize!
        
        switch self.imageType {
        case .Circle:
            fullScreenSize = CGSize(width: fullScreenWidth, height: fullScreenWidth)
            self.transitionImageView.layer.cornerRadius = self.transitionImageView.frame.height/2
            break
        case .Rectangle:
            if let imgSize = self.image?.size {
                let ratio = imgSize.width/imgSize.height
                let height = (fullScreenWidth)/ratio
                
                if height > fullScreenHeight {
                    ////////////
                } else {
                    ////////////
                }
                fullScreenSize = CGSize(width: fullScreenWidth, height: height)
                
            } else {
                fullScreenSize = CGSize(width: fullScreenWidth, height: fullScreenWidth)
            }
            self.transitionImageView.layer.cornerRadius = 10
            break
        case .Square:
            fullScreenSize = CGSize(width: fullScreenWidth, height: fullScreenWidth)
            self.transitionImageView.layer.cornerRadius = 10
            break
        }
        
        UIView.animate(withDuration: 0.2, animations: {
            self.transitionImageView.frame.size = fullScreenSize
            self.transitionImageView.center = appDelegate.window!.center
            self.transitionImageView.layer.cornerRadius = self.imageType == .Circle ? fullScreenWidth/2 : 10
            self.backDarkView.alpha = 1
            self.transitionImageView.alpha = 1
        }) { (finished) in
            
        }
    }
    
    @objc private func hideImage() {
        
        UIView.animate(withDuration: 0.2, animations: {
            if let gframe = self.superview?.convert(self.frame, to: nil) {
                self.transitionImageView.frame.size = gframe.size
                self.transitionImageView.frame.origin = CGPoint(x: gframe.origin.x, y: gframe.origin.y+20)
            } else {
                self.transitionImageView.frame.size = self.frame.size
                self.transitionImageView.frame.origin = CGPoint(x: self.frame.origin.x, y: self.frame.origin.y+20)
            }
            self.backDarkView.alpha = 0
        }) { (finished) in
            
        }
        
        UIView.animate(withDuration: 0.2, animations: {
            self.transitionImageView.alpha = 0
        }, completion: { (finished) in
            self.backDarkView.removeFromSuperview()
            self.transitionImageView.removeFromSuperview()
            self.backDarkView = nil
            self.transitionImageView = nil
            self.backViewTapGesture = nil
            
            self.delegate?.imageViewWithPreview(didPreview: self)
        })

    }
}
