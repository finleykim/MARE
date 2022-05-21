//
//  Data.swift
//  MARE
//
//  Created by Finley on 2022/05/12.
//

import Foundation
import UIKit

struct Recipe{
    var uuidString: String
    var title: String
    var date: Date
    var cookingTime: String
    var ingredient: String
    var content: String
    var comment: String
    var folder: String
    var bookmark: Bool
    var mainImage: String
}

//struct MainImage{
//    var mainImage: [String: UIImage]
//}


struct RecipeSearch{
    var recipes: [Recipe] { searchInfo.row }
    private let searchInfo: SearchInfo
    
    struct SearchInfo{
        var row: [Recipe] = []
    }
}
