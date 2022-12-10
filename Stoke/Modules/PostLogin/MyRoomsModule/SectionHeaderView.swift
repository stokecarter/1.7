//
//  SectionHeaderView.swift
//  Stoke
//
//  Created by Admin on 23/05/21.
//

import UIKit

class SectionHeaderView: UICollectionReusableView {
    
    
    var label: UILabel = {
        let label: UILabel = UILabel()
        label.font = AppFonts.Medium.withSize(16)
        label.textColor = #colorLiteral(red: 0.3019607843, green: 0.3019607843, blue: 0.3019607843, alpha: 1)
        label.sizeToFit()
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.topAnchor.constraint(equalTo: self.topAnchor,constant: -5).isActive = true
        label.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 16).isActive = true
        label.rightAnchor.constraint(equalTo: self.rightAnchor,constant: 10).isActive = true
        label.bottomAnchor.constraint(greaterThanOrEqualTo: self.bottomAnchor, constant: 5).isActive = true
    }



    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
