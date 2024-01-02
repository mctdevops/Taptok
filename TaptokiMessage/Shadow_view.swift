//
//  Shadow_view.swift
//  healthbot2
//
//  Created by Apple on 01/02/19.
//  Copyright © 2019 com.apple. All rights reserved.
//

import UIKit

class Shadow_view: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowOpacity = 1.0
        layer.shadowRadius = 5.0
        layer.cornerRadius = 10
        layer.masksToBounds = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowOpacity = 1.0
        layer.shadowRadius = 5.0
        layer.cornerRadius = 10
        layer.masksToBounds = false
    }

}
class Shadow_Button: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowOpacity = 1.0
        layer.shadowRadius = 5.0
        layer.cornerRadius = 10
        layer.masksToBounds = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowOpacity = 1.0
        layer.shadowRadius = 5.0
        layer.cornerRadius = 10
        layer.masksToBounds = false
    }

}

