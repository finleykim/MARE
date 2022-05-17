//
//  FolderTableViewCell.swift
//  MARE
//
//  Created by Finley on 2022/05/14.
//

import UIKit

class FolderTableViewCell: UITableViewCell{
    
    
    
    @IBOutlet weak var folderNameLabel: UILabel!
    
    @IBOutlet weak var recipeCount: UILabel!
    
    required init?(coder: NSCoder){
        super.init(coder: coder)
        self.contentView.layer.cornerRadius = 3.0
        self.contentView.layer.borderWidth = 1.0
        self.contentView.layer.borderColor = UIColor.black.cgColor
    }
    
}
