//
//  ViewController.swift
//  MARE
//
//  Created by Finley on 2022/05/12.
//

import UIKit

class ViewController: UIViewController {

    
    @IBOutlet weak var bookmarkCollectionView: UICollectionView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var maincollectionViewCell : MainCollectionViewCell?
    var recipeList = [Recipe](){
        didSet{
            self.saveRecipeList()
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadRecipeList()
        registerNib()
        setupCollectionView()
        notificationObserver()

    }

    private func registerNib(){
        let nibName = UINib(nibName: "MainCollectionViewCell", bundle: nil)
        self.collectionView.register(nibName, forCellWithReuseIdentifier: "MainCollectionViewCell")
    }
    
    
    func notificationObserver(){
        NotificationCenter.default.addObserver(self, selector: #selector(newRecipeNotification(_:)), name: NSNotification.Name("newRecipe"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(editRecipeNotification(_:)), name: NSNotification.Name("editRecipe"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(deleteRecipeNotification(_:)), name: NSNotification.Name("deleteRecipe"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(starDiaryNotification(_:)), name: NSNotification.Name("bookmarkRecipe"), object: nil)
    }
    
    @objc func newRecipeNotification(_ notification: Notification){
        guard let recipe = notification.object as? Recipe else { return }
        self.recipeList.append(recipe)
        self.recipeList = self.recipeList.sorted(by: {
            $0.date.compare($1.date) == .orderedDescending
        })

        self.collectionView.reloadData()
    }
    
    @objc func editRecipeNotification(_ notification: Notification){
        guard let recipe = notification.object as? Recipe else { return }
        guard let index = self.recipeList.firstIndex(where: {$0.uuidString == recipe.uuidString}) else { return }
        self.recipeList[index] = recipe
        
        self.recipeList = self.recipeList.sorted(by: {
            $0.date.compare($1.date) == .orderedDescending
        })
        self.collectionView.reloadData()
    }
    
    @objc func deleteRecipeNotification(_ notification: Notification){
        guard let uuidString = notification.object as? String else { return }
        guard let index = self.recipeList.firstIndex(where: { $0.uuidString == uuidString }) else { return }
        self.recipeList.remove(at: index)
        self.collectionView.deleteItems(at: [IndexPath(row: index, section: 0)])
    }
    
    @objc func starDiaryNotification(_ notification: Notification) {
      guard let starDiary = notification.object as? [String: Any] else { return }
      guard let bookmark = starDiary["bookmark"] as? Bool else { return }
      guard let uuidString = starDiary["uuidString"] as? String else { return }
      guard let index = self.recipeList.firstIndex(where: { $0.uuidString == uuidString }) else { return }
      self.recipeList[index].bookmark = bookmark
    }
    
    
    private func saveRecipeList(){
        let date = self.recipeList.map{
            [
                "uuidString": $0.uuidString,
                "title": $0.title,
                "date": $0.date,
                "cookingTime": $0.cookingTime,
                "ingredient": $0.ingredient,
                "content": $0.content,
                "comment": $0.comment,
                "folder": $0.folder,
                "bookmark": $0.bookmark,
                "mainImage" : $0.mainImage
            ]
        }
        let userDefaults = UserDefaults.standard
        userDefaults.set(date, forKey: "recipeList")

    }
    
    private func loadRecipeList(){
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
        }
        self.recipeList = self.recipeList.sorted(by: {
            $0.date.compare($1.date) == .orderedDescending
        })
    }
    
    
    private func setupCollectionView(){
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.collectionViewLayout = UICollectionViewFlowLayout()
    }
    

    private func setupCellLabel(){
        if maincollectionViewCell?.cellImageView.image == UIImage(named: "NilImage"){
            maincollectionViewCell?.cellLabel.alpha = 1
        }else {
            maincollectionViewCell?.cellLabel.alpha = 0
        }
    }
    
    
    
    @IBAction func folderBarButtonTapped(_ sender: UIBarButtonItem) {
        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "FolderViewController") as? FolderViewController else { return }
        
        navigationController?.pushViewController(viewController, animated: true)
        
    }
    @IBAction func addButtonTapped(_ sender: Any) {
        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "WritingViewController") as? WritingViewController else { return }
        
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func seeAllBookmarkButtonTapped(_ sender: Any) {
    }
}


extension ViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.recipeList.count
    }
    

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MainCollectionViewCell", for: indexPath) as? MainCollectionViewCell else { return UICollectionViewCell() }
        let recipe = self.recipeList[indexPath.row]
        cell.cellImageView.image = recipe.mainImage.toImage()
        cell.cellLabel.text = recipe.title
        setupCellLabel()
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else { return }
        let recipe = self.recipeList[indexPath.row]
        viewController.recipe = recipe
        viewController.indexPath = indexPath
        
        navigationController?.pushViewController(viewController, animated: true)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (UIScreen.main.bounds.width / 2) - 20, height: (UIScreen.main.bounds.width / 2) - 20)
    }
}

extension String{
    func toImage() -> UIImage?{
        if let data = Data(base64Encoded: self, options: .ignoreUnknownCharacters){
            return UIImage(data: data)
        }
        return nil
    }
}
