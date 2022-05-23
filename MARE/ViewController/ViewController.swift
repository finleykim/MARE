//
//  ViewController.swift
//  MARE
//
//  Created by Finley on 2022/05/12.
//

import UIKit
import SnapKit

class ViewController: UIViewController {

    
    @IBOutlet weak var startPageView: UIView!
    @IBOutlet weak var firstCollectionView: UICollectionView!
    @IBOutlet weak var secondCollectionView: UICollectionView!
    @IBOutlet weak var allRecipeView: UIView!
    @IBOutlet weak var topLogo: UIImageView!
    @IBOutlet weak var bookMarkLabelStack: UIStackView!
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var bookmarkView: UIView!
    
    
    var recipeList = [Recipe](){
        didSet{
            self.saveRecipeList()
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadRecipeList()
        setupCollectionView()
        notificationObserver()
        setupFirstPage()
        setupBookmarkFirstPage()

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupFirstPage()
        setupBookmarkFirstPage()
    }
    

    
    private func setupFirstPage(){
        if self.recipeList.count == 0{
            startPageView.alpha = 1
        } else{
            startPageView.alpha = 0
        }
    }

    
    
    
    
    private func setupBookmarkFirstPage(){
        let recipe = self.recipeList.filter({ $0.bookmark == true })
        if recipe.count == 0{
            self.bookmarkView.isHidden = true
            allRecipeView.snp.makeConstraints{
                $0.top.equalToSuperview()
                $0.bottom.equalToSuperview()
                $0.leading.equalToSuperview().inset(10)
                $0.trailing.equalToSuperview().inset(10)
            }
        } else if recipe.count > 0{
            self.bookmarkView.isHidden = false
            topLogo.snp.makeConstraints{
                $0.top.equalToSuperview().inset(60)
                $0.leading.equalToSuperview().inset(100)
                $0.trailing.equalToSuperview().inset(100)
            }
            bookmarkView.snp.makeConstraints{
                $0.top.equalTo(topLogo.snp.bottom).offset(20)
                $0.leading.equalToSuperview()
                $0.trailing.equalToSuperview()
            }
            allRecipeView.snp.makeConstraints{
                $0.top.equalTo(bookmarkView.snp.bottom).offset(20)
                $0.leading.equalToSuperview().inset(10)
                $0.trailing.equalToSuperview().inset(10)
                $0.bottom.equalToSuperview()
            }
        }
  
    }
    
    
    private func setupCollectionView(){
        firstCollectionView.delegate = self
        firstCollectionView.dataSource = self
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        firstCollectionView.collectionViewLayout = layout
        firstCollectionView.showsHorizontalScrollIndicator = false
        //firstCollectionView.backgroundColor = UIColor(red: 232, green: 184, blue: 40, alpha: 1)
        
        secondCollectionView.delegate = self
        secondCollectionView.dataSource = self
        secondCollectionView.collectionViewLayout = UICollectionViewFlowLayout()
 
    }
  
    
    func notificationObserver(){
        NotificationCenter.default.addObserver(self, selector: #selector(newRecipeNotification(_:)), name: NSNotification.Name("newRecipe"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(editRecipeNotification(_:)), name: NSNotification.Name("editRecipe"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(deleteRecipeNotification(_:)), name: NSNotification.Name("deleteRecipe"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(bookmarkNotification(_:)), name: NSNotification.Name("bookmark"), object: nil)
    }
    
    @objc func newRecipeNotification(_ notification: Notification){
        guard let recipe = notification.object as? Recipe else { return }
        self.recipeList.append(recipe)
        self.recipeList = self.recipeList.sorted(by: {
            $0.date.compare($1.date) == .orderedDescending
        })

        self.firstCollectionView.reloadData()
        self.secondCollectionView.reloadData()
    }
    
    @objc func editRecipeNotification(_ notification: Notification){
        guard let recipe = notification.object as? Recipe else { return }
        guard let index = self.recipeList.firstIndex(where: {$0.uuidString == recipe.uuidString}) else { return }
        self.recipeList[index] = recipe
        
        self.recipeList = self.recipeList.sorted(by: {
            $0.date.compare($1.date) == .orderedDescending
        })
        self.firstCollectionView.reloadData()
        self.secondCollectionView.reloadData()
    }
    
    @objc func deleteRecipeNotification(_ notification: Notification){
        guard let uuidString = notification.object as? String else { return }
        guard let index = self.recipeList.firstIndex(where: { $0.uuidString == uuidString }) else { return }
        self.recipeList.remove(at: index)
        
        self.secondCollectionView.deleteItems(at: [IndexPath(row: index, section: 0)])
    }
    
    @objc func bookmarkNotification(_ notification: Notification) {
      guard let starDiary = notification.object as? [String: Any] else { return }
      guard let bookmark = starDiary["bookmark"] as? Bool else { return }
      guard let uuidString = starDiary["uuidString"] as? String else { return }
      guard let index = self.recipeList.firstIndex(where: { $0.uuidString == uuidString }) else { return }
      self.recipeList[index].bookmark = bookmark
        self.firstCollectionView.reloadData()
        
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
    
    
 
    

 
    
    
//    @IBAction func folderBarButtonTapped(_ sender: UIBarButtonItem) {
//        self.tabBarController?.selectedIndex = 2
//        
//    }
    @IBAction func addButtonTapped(_ sender: Any) {
        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "WritingViewController") as? WritingViewController else { return }
        
        navigationController?.pushViewController(viewController, animated: true)
    }
    

    @IBAction func seeallBookmarkButtonTapped(_ sender: UIButton) {
        self.tabBarController?.selectedIndex = 1
    }
}



extension ViewController: UICollectionViewDelegateFlowLayout,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView{
        case firstCollectionView:
            return self.recipeList.filter({ $0.bookmark == true }).count
        case secondCollectionView:
            return recipeList.count
        default:
            return 1
        }
    }
    
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else { return }
            switch collectionView{
            case firstCollectionView:
                let recipe = self.recipeList.filter({ $0.bookmark == true })[indexPath.row]
                viewController.recipe = recipe
                viewController.indexPath = indexPath
               
            case secondCollectionView:
                    let recipe = self.recipeList[indexPath.row]
                    viewController.recipe = recipe
                    viewController.indexPath = indexPath
                   
                
                
                
            default:
                break
            }
            navigationController?.pushViewController(viewController, animated: true)
    
            
    
        }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView{
        case firstCollectionView:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "firstCell", for: indexPath) as? FirstCollectionViewCell else { return UICollectionViewCell() }
            let recipe = self.recipeList.filter({ $0.bookmark == true })[indexPath.row]
            
            cell.imageView.image = recipe.mainImage.toImage()

            return cell
        case secondCollectionView:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "secondCell", for: indexPath) as? SecondCollectionviewCell else { return UICollectionViewCell() }
            let recipe = self.recipeList[indexPath.row]
            cell.imageView.image = recipe.mainImage.toImage()
                //cell.imageView.layer.cornerRadius = 50
            cell.label.text = recipe.title

            
            return cell
            
        default:
            return UICollectionViewCell()
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch collectionView{
        case firstCollectionView:
            return CGSize(width: 80, height: 80)
        case secondCollectionView:
            return CGSize(width: (UIScreen.main.bounds.width / 2)-15, height: (UIScreen.main.bounds.width / 2)-15)
        default:
            return CGSize(width: 0, height: 0)
        }
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


extension UIColor{
    class var CustomColor: UIColor? { return UIColor(named: "CustomColor")}
}
