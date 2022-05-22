//
//  BookmarkViewController.swift
//  MARE
//
//  Created by Finley on 2022/05/18.
//

import UIKit

class BookmarkViewController: UIViewController{
    
    @IBOutlet weak var collectionView: UICollectionView!
    var recipeList = [Recipe]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNotification()
        loadBookmarkList()
        setupCollectionView()
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }
    
    
    private func setupCollectionView(){
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.collectionViewLayout = UICollectionViewFlowLayout()
    }
    
    
    private func setupNotification(){
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(addbookMark(_:)),
                                               name: NSNotification.Name("bookmark"),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(deleteRecipe(_:)),
                                               name: NSNotification.Name("deleteRecipe"),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(editRecipe(_:)),
                                               name: NSNotification.Name("editRecipe"),
                                               object: nil)
    }
    
    
    
    private func loadBookmarkList(){
        let userDefaults = UserDefaults.standard
        guard let data = userDefaults.object(forKey: "recipeList") as? [[String : Any]] else { return }
        self.recipeList = data.compactMap{
            guard let uuidString = $0["uuidString"] as? String else { return nil }
            guard let title = $0["title"] as? String else { return nil }
            guard let date = $0["date"] as? Date else { return nil }
            guard let cookingTime = $0["cookingTime"] as? String else { return nil }
            guard let ingredient = $0["ingredient"] as? String else { return nil }
            guard let content = $0["content"] as? String else { return nil }
            guard let comment = $0["comment"] as? String else { return nil }
            guard let folder = $0["folder"] as? String else { return nil }
            guard let bookmark = $0["bookmark"] as? Bool else { return nil }
            guard let mainImage = $0["mainImage"] as? String else { return nil }
            return Recipe(uuidString: uuidString, title: title, date: date, cookingTime: cookingTime, ingredient: ingredient, content: content, comment: comment, folder: folder, bookmark: bookmark, mainImage: mainImage)
        }.filter({
            $0.bookmark == true
        }).sorted(by: {
            $0.date.compare($1.date) == .orderedDescending
        })
    }
    
    @objc func addbookMark(_ notification: Notification){
        guard let bookmarkRecipe = notification.object as? [String: Any] else { return }
        guard let recipe = bookmarkRecipe["recipe"] as? Recipe else { return }
        guard let bookmark = bookmarkRecipe["bookmark"] as? Bool else { return }
        guard let uuidString = bookmarkRecipe["uuidString"] as? String else { return }

        if bookmark{
            self.recipeList.append(recipe)
            self.recipeList = self.recipeList.sorted(by: {
                $0.date.compare($1.date) == .orderedDescending
            })
            self.collectionView.reloadData()
        } else{
            guard let index = self.recipeList.firstIndex(where: { $0.uuidString == uuidString }) else { return }
            self.recipeList.remove(at: index)
            self.collectionView.deleteItems(at: [IndexPath(row: index, section: 0)])
        }
    }
    
    @objc func deleteRecipe(_ notification: Notification){
        guard let uuidString = notification.object as? String else { return }
        guard let index = self.recipeList.firstIndex(where: { $0.uuidString == uuidString }) else { return }
        self.recipeList.remove(at: index)
        self.collectionView.deleteItems(at: [IndexPath(row: index, section:  0)])
    }
    
    @objc func editRecipe(_ notification: Notification){
        guard let recipe = notification.object as? Recipe else { return }
        guard let index = self.recipeList.firstIndex(where: {$0.uuidString == recipe.uuidString }) else { return }
        self.recipeList[index] = recipe
        self.recipeList = self.recipeList.sorted(by: {
            $0.date.compare($1.date) == .orderedDescending
        })
        self.collectionView.reloadData()
    }
    
    

    

    
}


extension BookmarkViewController: UICollectionViewDelegateFlowLayout,UICollectionViewDataSource,UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.recipeList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BookmarkCell", for: indexPath) as? BookmarkCell else { return UICollectionViewCell() }
        let recipe = self.recipeList[indexPath.row]
        cell.imageView.image = recipe.mainImage.toImage()
        cell.label.text = recipe.title
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (UIScreen.main.bounds.width / 2) - 20, height: (UIScreen.main.bounds.width / 2) - 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else { return }
        let recipe = self.recipeList[indexPath.row]
        viewController.recipe = recipe
        viewController.indexPath = indexPath
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
}
