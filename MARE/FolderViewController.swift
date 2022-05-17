//
//  FolderViewController.swift
//  MARE
//
//  Created by Finley on 2022/05/12.
//

import Foundation
import UIKit

class FolderViewController: UIViewController{
    

    @IBOutlet weak var folderCollectionView: UICollectionView!
    
    private var folderList = [Folder](){
        didSet{
            self.saveFolderList()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        loadFolderList()
        setupCollectionView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(newFolder(_:)), name: NSNotification.Name("newFolder"), object: nil)
    }
    
    @objc private func newFolder(_ notification: Notification){
        guard let folder = notification.object as? Folder else { return }
        self.folderList.append(folder)
        self.folderList = self.folderList.sorted(by: {
            $0.date.compare($1.date) == .orderedDescending
        })
        self.folderCollectionView.reloadData()
        
    }
    
    
    
    
    private func setupCollectionView(){
        self.folderCollectionView.collectionViewLayout = UICollectionViewFlowLayout()
        self.folderCollectionView.contentInset = UIEdgeInsets(top: 0, left:0, bottom: 0, right: 0)
        self.folderCollectionView.delegate = self
        self.folderCollectionView.dataSource = self
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

}


extension FolderViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.folderList.count
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FolderCollectionViewCell", for: indexPath) as? FolderCollectionViewCell else { return UICollectionViewCell() }
        
        let folder = self.folderList[indexPath.row]
        cell.folderNameLabel.text = folder.folderName
        // cell.recipeCount.text = "\(self.recipeList.count)개의 레시피"
    
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width - 20, height: 80)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as? ViewController else { return }
        //폴더에 포함된 레시피 표시코드
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            self.folderList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
    }
}


extension FolderViewController{
    private func setupNavigationBar(){
        let leftBarButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editButtonTapped))
        navigationItem.leftBarButtonItem = leftBarButton
        
        let rightBarButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addBUttonTapped))
        navigationItem.rightBarButtonItem = rightBarButton
    }
    
    @objc private func editButtonTapped(){
        
    }
    
    @objc private func addBUttonTapped(){
        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "AddFolderViewController") as? AddFolderViewController else { return }
        
  
        viewController.modalTransitionStyle = .crossDissolve
        self.present(viewController, animated: true, completion: nil)
    }
}
