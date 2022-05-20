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
      self.contentView.layer.cornerRadius = 3.0
      self.contentView.layer.borderWidth = 1.0
      self.contentView.layer.borderColor = UIColor.black.cgColor
    }
    
}
