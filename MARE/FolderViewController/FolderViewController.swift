//
//  FolderViewController.swift
//  MARE
//
//  Created by Finley on 2022/05/12.
//

import Foundation
import UIKit

class FolderViewController: UIViewController{
    

    @IBOutlet weak var addFolderStackView: UIStackView!
    @IBOutlet weak var folderTableView: UITableView!
    
    
    private var folderList = [Folder](){
        didSet{
            self.saveFolderList()
        }
    }
    var recipe : Recipe?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        loadFolderList()
        setupTableView()
        setup()

        NotificationCenter.default.addObserver(self, selector: #selector(newFolder(_:)), name: NSNotification.Name("newFolder"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(newFolder(_:)), name: NSNotification.Name("editRecipe"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(newFolder(_:)), name: NSNotification.Name("newRecipe"), object: nil)
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        loadFolderList()
        setup()
    }
    
    @objc private func newFolder(_ notification: Notification){
        guard let folder = notification.object as? Folder else { return }
        self.folderList.append(folder)
        self.folderList = self.folderList.sorted(by: {
            $0.date.compare($1.date) == .orderedDescending
        })
        setup()
        self.folderTableView.reloadData()
    }
    
    
    
    
    
    
    private func setup(){
        if folderList.count == 0{
            self.addFolderStackView.alpha = 1
            self.folderTableView.alpha = 0
        } else {
            self.addFolderStackView.alpha = 0
            self.folderTableView.alpha = 1
        }
    }
    
    
    private func setupTableView(){
        self.folderTableView.delegate = self
        self.folderTableView.dataSource = self
        self.folderTableView.rowHeight = 80
        
    }
    
    private func saveFolderList(){
        let date = self.folderList.map{
            [
                "uuidString" : $0.uuidString,
                "folderName" : $0.folderName,
                "date" : $0.date
            ]
        }
        let userDefaults = UserDefaults.standard
        userDefaults.set(date, forKey: "folderList")
    }
    

    
    private func loadFolderList(){
        let userDefaults = UserDefaults.standard
        guard let data = userDefaults.object(forKey: "folderList") as? [[String: Any]] else { return }
        self.folderList = data.compactMap{
            guard let uuidString = $0["uuidString"] as? String else { return nil }
            guard let folderName = $0["folderName"] as? String else { return nil }
            guard let date = $0["date"] as? Date else { return nil }
            return Folder(uuidString: uuidString, folderName: folderName, date: date)
        }
        self.folderList = self.folderList.sorted(by: {
            $0.date.compare($1.date) == .orderedDescending
        })

    }
    

    

    
    

    @IBAction func addfolderStackViewButtonTapped(_ sender: UIButton) {
        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "AddFolderViewController") as? AddFolderViewController else { return }
        
  
        viewController.modalTransitionStyle = .crossDissolve
        self.present(viewController, animated: true, completion: nil)
    }
    
    deinit{
        NotificationCenter.default.removeObserver(self)
    }
}





extension FolderViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.folderList.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      guard let cell = tableView.dequeueReusableCell(withIdentifier: "FolderTableViewCell", for: indexPath) as? FolderTableViewCell else { return UITableViewCell() }
    let folder = self.folderList[indexPath.row]
      cell.folderNameLabel.text = folder.folderName
      
    return cell
  }

  func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
    return true
  }

  func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
    var folderList = self.folderList
    let task = folderList[sourceIndexPath.row]
    folderList.remove(at: sourceIndexPath.row)
    folderList.insert(task, at: destinationIndexPath.row)
    self.folderList = folderList
  }

  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    self.folderList.remove(at: indexPath.row)
    tableView.deleteRows(at: [indexPath], with: .automatic)

  }
    

    
    
}

extension FolderViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "FolderRecipeListViewController") as? FolderRecipeListViewController else { return }
      let folder = self.folderList[indexPath.row]
      viewController.folder = folder
      viewController.indexPath = indexPath
                
      navigationController?.pushViewController(viewController, animated: true)
  }
  
    
}


extension FolderViewController{
    private func setupNavigationBar(){
        
        let rightBarButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addBUttonTapped))
        navigationItem.rightBarButtonItem = rightBarButton
        rightBarButton.tintColor = .CustomColor
    }
    
    @objc private func editButtonTapped(){
        
    }
    
    @objc private func addBUttonTapped(){
        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "AddFolderViewController") as? AddFolderViewController else { return }
        
  
        viewController.modalTransitionStyle = .crossDissolve
        self.present(viewController, animated: true, completion: nil)
    }
}


