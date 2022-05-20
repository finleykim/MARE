//
//  BookmarkViewController.swift
//  MARE
//
//  Created by Finley on 2022/05/18.
//

import UIKit

class BookmarkViewController: UIViewController{
    
    @IBOutlet weak var allBookmarkCollectionView: UICollectionView!
//    var bookmarkList = [Recipe]()
//    
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupNotification()
//
//    }
//    private func setupCollectionView(){
//        allBookmarkCollectionView.delegate = self
//        allBookmarkCollectionView.dataSource = self
//        allBookmarkCollectionView.collectionViewLayout = UICollectionViewFlowLayout()
//    }
//    
//    
//    private func setupNotification(){
//        NotificationCenter.default.addObserver(self, selector: #selector(addbookMark(_:)), name: NSNotification.Name("bookmark"), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(deleteRecipe(_:)), name: NSNotification.Name("deleteRecipe"), object: nil)
//    }
//    
//    @objc func addbookMark(_ notification: Notification){
//        
//    }
//    
//    @objc func deleteRecipe(_ notification: Notification){
//        
//    }
//    
//    
//    private func loadBookmarkList(){
//        let userDefaults = UserDefaults.standard
//        guard let data = userDefaults.object(forKey: "diaryList") as? [[String : Any]] else { return }
//        self.bookmarkList = data.compactMap{
//            guard let uuidString = $0["uuidString"] as? String else { return nil }
//            
//        }
//    }
//    
//
//    
//}
//
//
//extension BookmarkViewController: UICollectionViewDelegateFlowLayout,UICollectionViewDataSource{
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        <#code#>
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        <#code#>
//    }
    
    
}
