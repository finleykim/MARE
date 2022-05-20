//
//  SecondCollectionviewCell.swift
//  MARE
//
//  Created by Finley on 2022/05/19.
//


import UIKit

class SecondCollectionviewCell: UICollectionViewCell{
    
    
    @IBOutlet weak var imageView: UIImageView!
    
    required init?(coder: NSCoder) {
      super.init(coder: coder)
      self.contentView.layer.cornerRadius = 10

    }
    
}
