//
//  CollectionViewCell.swift
//  MARE
//
//  Created by Finley on 2022/05/12.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageViewCell: UIImageView!
    
    required init?(coder: NSCoder) {
      super.init(coder: coder)
      self.contentView.layer.cornerRadius = 3.0
    }
    

}
