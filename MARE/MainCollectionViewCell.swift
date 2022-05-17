//
//  MainCollectionViewCell.swift
//  MARE
//
//  Created by Finley on 2022/05/17.
//

import UIKit

class MainCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var cellImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.layer.cornerRadius = 3.0
    }

}
