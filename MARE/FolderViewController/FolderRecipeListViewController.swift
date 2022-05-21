//
//  FolderRecipeListViewController.swift
//  MARE
//
//  Created by Finley on 2022/05/21.
//

import UIKit

class FolderRecipeListViewController: UIViewController{
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var folderNameLabel: UILabel!
    var recipeList = [Recipe]()
    var folder : Folder?
    var indexPath : IndexPath?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        notification()
        setupCollectionView()
        folderRecipeLoad()
        setup()
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }
    
    private func notification(){
        NotificationCenter.default.addObserver(self, selector: #selector(addFolderRecipe(_:)), name: NSNotification.Name("newRecipe"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(editFolderRecipe(_:)), name: NSNotification.Name("editRecipe"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(deleteFolderRecipe(_:)), name: NSNotification.Name("deleteRecipe"), object: nil)
    }
    
    @objc func addFolderRecipe(_ notification: Notification){
        guard let folderRecipe = notification.object as? [String: Any] else { return }
        guard let recipe = folderRecipe["recipe"] as? Recipe else { return }
        guard let uuidString = folderRecipe["uuidString"] as? String else { return }
        guard let folderName = folderRecipe["folderName"] as? String else { return }
        
        if folderName != ""{
            self.recipeList.append(recipe)
            self.recipeList = self.recipeList.sorted(by: {
                $0.date.compare($1.date) == .orderedDescending
            })
            self.collectionView.reloadData()
        } else {
            guard let index = self.recipeList.firstIndex(where: { $0.uuidString == uuidString }) else { return }
            self.recipeList.remove(at: index)
            self.collectionView.deleteItems(at: [ IndexPath(row: index, section: 0)])
        }
        

    }
    
    @objc func editFolderRecipe(_ notification: Notification){
        guard let recipe = notification.object as? Recipe else { return }
        guard let index = self.recipeList.firstIndex(where: {$0.uuidString == recipe.uuidString }) else { return }
        self.recipeList[index] = recipe
        self.recipeList = self.recipeList.sorted(by: {
            $0.date.compare($1.date) == .orderedDescending
        })
        self.collectionView.reloadData()
    }
    
    @objc func deleteFolderRecipe(_ notification: Notification){
        guard let uuidString = notification.object as? String else { return }
        guard let index = self.recipeList.firstIndex(where: { $0.uuidString == uuidString }) else { return }
        self.recipeList.remove(at: index)
        self.collectionView.deleteItems(at: [IndexPath(row: index, section:  0)])
    }
    
    
//    @objc func folderSort(_ notification: Notification){
//        guard let folderRecipe = notification.object as? [String: Any] else { return }
//        guard let recipe = folderRecipe["recipe"] as? Recipe else { return }
//        guard let uuidString = folderRecipe["uuidString"] as? String else { return }
//        guard let folderName = folderRecipe["folderName"] as? String else { return }
//        self.folderNameLabel.text = folderName
//
//    }
    
    
    
    private func setupCollectionView(){
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.collectionViewLayout = UICollectionViewFlowLayout()
    }
    
    private func setup(){
       guard let folder = self.folder else { return }
        folderNameLabel.text = folder.folderName
    }
    
    
    private func folderRecipeLoad(){
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
            $0.folder != "" && $0.folder == self.folder?.folderName
        }).sorted(by: {
            $0.date.compare($1.date) == .orderedDescending
        })
    }
    
}



extension FolderRecipeListViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recipeList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? FolderRecipeListViewCell else { return UICollectionViewCell() }
        let recipe = recipeList[indexPath.row]
        
            
            
            
        cell.imageView.image = recipe.mainImage.toImage()
         return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else { return }
        let recipe = self.recipeList[indexPath.row]
        viewController.recipe = recipe
        viewController.indexPath = indexPath
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (UIScreen.main.bounds.width / 2) - 20, height: (UIScreen.main.bounds.width / 2) - 20)
    }
    
    
}
