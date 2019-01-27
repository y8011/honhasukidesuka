//
//  customCell.swift
//  sampleCoreData1
//
//  Created by yuka on 2017/11/22.
//  Copyright © 2017年 yuka. All rights reserved.
//

import UIKit

class customCell: UICollectionViewCell {

    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    
    var id:Int = -1
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override init(frame: CGRect){
        super.init(frame: frame)
    }
    required init(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)!
    }

}
