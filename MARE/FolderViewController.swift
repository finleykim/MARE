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
    
    private var folderList = [FolderData](){
        didSet{
            self.saveFolderList()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        
        NotificationCenter.default.addObserver(self, selector: #selector(newFolder(_:)), name: NSNotification.Name("newFolder"), object: nil)
    }
    
    @objc private func newFolder(_ notification: Notification){
        guard let folder = notification.object as? FolderData else { return }
        self.folderList.append(folder)
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
                "folderName" : $0.folderName
            ]
        }
        let userDefaults = UserDefaults.standard
        userDefaults.set(date, forKey: "folderList")
    }

}


extension FolderViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.folderList.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FolderCollectiolnViewCell", for: indexPath) as? FolderCollectionViewCell else { return UICollectionViewCell()}
        
        let folder = self.folderList[indexPath.row]
        cell.folderName.text = folder.folderName
        // cell.recipeCount.text = "\(self.recipeList.count)개의 레시피"
    
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 80)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as? ViewController else { return }
        //폴더에 포함된 레시피 표시코드
        self.navigationController?.pushViewController(viewController, animated: true)
        
        
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
        
        // viewController.modalPresentationStyle = .fullscreen
        viewController.modalTransitionStyle = .crossDissolve
        self.present(viewController, animated: true, completion: nil)
    }
}
