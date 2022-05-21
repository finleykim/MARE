//
//  SearchViewController.swift
//  MARE
//
//  Created by Finley on 2022/05/21.
//

import UIKit
import SnapKit

class SearchViewController: UIViewController{
    

    var recipeList = [Recipe]()
    var recipe : Recipe?
    var searchText: String?
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isHidden = true
       return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationItems()
        setTableViewLayout()
        searchRecipeLoad()
        setTableViewLayout()
    }
    

    private func searchRecipeLoad(){
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
        }.sorted(by: {
            $0.date.compare($1.date) == .orderedDescending
        })
    }
    
    private func setNavigationItems(){
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "mare"
        
        let searchController = UISearchController()
        searchController.searchBar.placeholder = "레시피명을 입력해주세요"
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        
        navigationItem.searchController = searchController
    }
    
    private func setTableViewLayout(){
        view.addSubview(tableView)
        tableView.snp.makeConstraints{ $0.edges.equalToSuperview() }
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
 
    
}


extension SearchViewController: UISearchBarDelegate{

    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        tableView.reloadData()
        tableView.isHidden = false
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        tableView.isHidden = true
        self.recipeList = []
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipeList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        let recipe = recipeList[indexPath.row]
        cell.textLabel?.text = recipe.title
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else { return }
        let recipe = self.recipeList[indexPath.row]
        viewController.recipe = recipe
        viewController.indexPath = indexPath
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
}
