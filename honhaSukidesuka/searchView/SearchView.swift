//
//  SearchView.swift
//  honhaSukidesuka
//
//  Created by oyuka on 2019/01/25.
//  Copyright © 2019 yuka. All rights reserved.
//

import UIKit

class SearchView: UIView {
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    @IBOutlet weak var searchedTableView: UITableView!
    
    
    public var searchedBooks: [Book] = []
    
    // Storyboard/xib から初期化はここから
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNib()
    }
    
    // コードから初期化
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNib()
    }
    
    private func loadNib() {
        //let view = Bundle.main.loadNibNamed("SearchView", owner: self, options: nil)?.first as! UIView
        let view = UINib(nibName: "SearchView", bundle: nil).instantiate(withOwner: self, options: nil).first as! UIView
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleHeight,.flexibleWidth]
        
        self.addSubview(view)
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundImageView.clipsToBounds = true
        
        isHidden = true
        searchedTableView.separatorColor = .clear
        searchedTableView.delegate = self.parentContainerViewController() as? UITableViewDelegate
        searchedTableView.dataSource = self.parentContainerViewController() as? UITableViewDataSource
        searchedTableView.register(UINib(nibName: "searchTableCell", bundle: nil), forCellReuseIdentifier: "searchCell")

    }
    
    
    func afterLoaded() {
        
    }
    
    func appear() {
        if isHidden {
            self.fadeIn(type: .Slow, completed: nil)
        }
    }
    func disappear() {
        if !isHidden {
            self.fadeOut(type: .Normal, completed: nil)
        }
    }
}
