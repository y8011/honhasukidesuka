//
//  CircleButton.swift
//  honhaSukidesuka
//
//  Created by oyuka on 2018/09/08.
//  Copyright © 2018年 yuka. All rights reserved.
//

import UIKit

class CircleButton: UIButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override init(frame: CGRect){
        
        
        super.init(frame: frame)
        
        self.layer.cornerRadius = frame.width / 2
        self.layer.backgroundColor = UIColor.cyan.cgColor
        
    }

    required init(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)!
    }
}
