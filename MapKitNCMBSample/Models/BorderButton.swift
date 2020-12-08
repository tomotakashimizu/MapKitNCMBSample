//
//  BorderButton.swift
//  InstaSampleSwift5
//
//  Created by Sample on 2020/05/02.
//  Copyright © 2020 sample.com. All rights reserved.
//

import UIKit

@IBDesignable

class BorderButton: UIButton {
    
    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet {
            self.layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
