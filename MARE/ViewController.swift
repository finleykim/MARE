//
//  ViewController.swift
//  MARE
//
//  Created by Finley on 2022/05/12.
//

import UIKit

class ViewController: UIViewController {

    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    var dataList = [Data](){
        didSet{
            self.saveDataList()
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        notificationObserver()
    }

    
    func notificationObserver(){
        NotificationCenter.default.addObserver(self, selector: #selector(newRecipeNotification(_:)), name: NSNotification.Name("newRecipe"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(editRecipeNotification(_:)), name: NSNotification.Name("editRecipe"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(deleteRecipeNotification(_:)), name: NSNotification.Name("deleteRecipe"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(starDiaryNotification(_:)), name: NSNotification.Name("bookmarkRecipe"), object: nil)
    }
    
    @objc func newRecipeNotification(_ notification: Notification){
        guard let data = notification.object as? Data else { return }
        self.dataList.append(data)
        self.dataList = self.dataList.sorted(by: {
            $0.date.compare($1.date) == .orderedDescending
        })
        self.collectionView.reloadData()
    }
    
    @objc func editRecipeNotification(_ notification: Notification){
        guard let data = notification.object as? Data else { return }
        guard let index = self.dataList.firstIndex(where: {$0.uuidString == data.uuidString}) else { return }
        self.dataList[index] = data
        self.dataList = self.dataList.sorted(by: {
            $0.date.compare($1.date) == .orderedDescending
        })
    }
    
    @objc func deleteRecipeNotification(_ notification: Notification){
        guard let uuidString = notification.object as? String else { return }
        guard let index = self.dataList.firstIndex(where: { $0.uuidString == uuidString }) else { return }
        self.dataList.remove(at: index)
        self.collectionView.deleteItems(at: [IndexPath(row: index, section: 0)])
    }
    
    @objc func starDiaryNotification(_ notification: Notification) {
      guard let starDiary = notification.object as? [String: Any] else { return }
      guard let bookmark = starDiary["bookmark"] as? Bool else { return }
      guard let uuidString = starDiary["uuidString"] as? String else { return }
      guard let index = self.dataList.firstIndex(where: { $0.uuidString == uuidString }) else { return }
      self.dataList[index].bookmark = bookmark
    }
    
    
    private func saveDataList(){
        let date = self.dataList.map{
            [
                "uuidString": $0.uuidString,
                "title": $0.title,
                "mainImage": $0.mainImage,
                "date": $0.date,
                "cookingTime": $0.cookingTime,
                "ingredient": $0.ingredient,
                "content": $0.content,
                "comment": $0.comment,
                "folder": $0.folder,
                "bookmark": $0.bookmark
            ]
        }
        let userDefaults = UserDefaults.standard
        userDefaults.set(date, forKey: "dataList")
    }
    
    
    private func setupCollectionView(){
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    

    
    
    
    
    @IBAction func folderBarButtonTapped(_ sender: UIBarButtonItem) {
        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "FolderViewController") as? FolderViewController else { return }
        
        navigationController?.pushViewController(viewController, animated: true)
        
    }
    @IBAction func addButtonTapped(_ sender: Any) {
        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "WritingViewController") as? WritingViewController else { return }
        
        navigationController?.pushViewController(viewController, animated: true)
    }
    
}


extension ViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as? CollectionViewCell else { return UICollectionViewCell() }
        let data = self.dataList[indexPath.row]
        cell.imageViewCell.image = data.mainImage
        
        return cell
    }
    

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else { return }
        let data = self.dataList[indexPath.row]
        viewController.data = data
        viewController.indexPath = indexPath
        
        navigationController?.pushViewController(viewController, animated: true)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (UIScreen.main.bounds.width / 3), height: 180)
    }
}
