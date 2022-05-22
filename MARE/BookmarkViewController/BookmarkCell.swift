//
//  BookmarkCell.swift
//  MARE
//
//  Created by Finley on 2022/05/20.
//

import UIKit

class BookmarkCell: UICollectionViewCell{
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    required init?(coder: NSCoder) {
      super.init(coder: coder)
      self.contentView.layer.cornerRadius = 30

    }
}
