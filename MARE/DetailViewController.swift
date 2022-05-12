//
//  DetailViewController.swift
//  MARE
//
//  Created by Finley on 2022/05/12.
//

import Foundation
import UIKit

class DetailViewController: UIViewController{
    
    var rightBarButtonItem = UINavigationItem()
    var data : Data?
    var indexPath: IndexPath?
    
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var mainImage: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var ingredientLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var bookmarButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
        setupNavigationBar()
        NotificationCenter.default.addObserver(self, selector: #selector(bookmarkNotification(_:)), name: NSNotification.Name("bookMarkRecipe"), object: nil)
    }
    
    
    @objc func bookmarkNotification(_ notification: Notification){
        guard let starDiary = notification.object as? [String: Any] else { return }
        guard let bookmark = starDiary["bookmark"] as? Bool else { return }
        guard let uuidString = starDiary["uuidString"] as? String else { return }
        guard let data = self.data else { return }
        if data.uuidString == uuidString {
            self.data?.bookmark = bookmark
            self.setUp()
        }
    }
    
    
    
    private func setUp(){
        guard let data = self.data else { return }
        self.mainImage.image = data.mainImage
        self.dateLabel.text = self.dateToString(date: data.date)
        self.temperatureLabel.text = data.cookingTime
        self.titleLabel.text = data.title
        self.ingredientLabel.text = data.ingredient
        self.contentLabel.text = data.content
        self.commentLabel.text = data.comment
        self.bookmarButton.setImage(data.bookmark ? UIImage(systemName: "bookmark") : UIImage(systemName: "bookmart.fill"), for: .normal)
        self.bookmarButton.tintColor = UIColor(red: 232, green: 184, blue: 40, alpha: 1)
    }
    
    private func dateToString(date: Date) -> String {
        let formetter = DateFormatter()
        formetter.dateFormat = "yyyy-MM-dd(EEEE)"
        formetter.locale = Locale(identifier: "ko_KR")
        
        return formetter.string(from: date)
    }
    
    
    
    @IBAction func voiceButtonTapped(_ sender: Any) {
        //Voice Support
    }
    
    @IBAction func bookmarkButtonTapped(_ sender: UIButton) {
    }
    
}

extension DetailViewController{
    func setupNavigationBar(){
        let rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .plain, target: self, action: #selector(rightBarButtonTapped))
        navigationController?.navigationItem.rightBarButtonItem = rightBarButtonItem
        
        let leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "ellipsis"), style: .plain, target: self, action: #selector(leftBarButtonTapped))
        navigationController?.navigationItem.leftBarButtonItem = leftBarButtonItem
        
    }
    
    
    //Action
    @objc func rightBarButtonTapped(){
        let activityItems: [Any] = [data?.title]
        let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        present(activityViewController, animated: true)
    }
    
    @objc func leftBarButtonTapped(){
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let editButton = UIAlertAction(title: "수정", style: .default, handler: editButtonTapped(_:))
        let deleteButton = UIAlertAction(title: "삭제", style: .destructive, handler: deleteButtonTapped(_:))
        
        actionSheet.addAction(editButton)
        actionSheet.addAction(deleteButton)
        
        self.present(actionSheet, animated: true){
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissAlertController))
            actionSheet.view.superview?.subviews[0].addGestureRecognizer(tapGesture)
        }
    }
    
    @objc func dismissAlertController(){
        self.dismiss(animated: true, completion: nil)
    }
    
    func editButtonTapped(_ action: UIAlertAction){
        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "WritingViewController") as? WritingViewController else { return }
        guard let indexPath = self.indexPath else { return }
        guard let data = self.data else { return }
        viewController.editMode = .edit(indexPath,data)
        NotificationCenter.default.addObserver(self, selector: #selector(editNotification(_:)), name: NSNotification.Name("editRecipe"), object: nil)
    }
    
    @objc func editNotification(_ notification: Notification){
        guard let data = notification.object as? Data else { return }
        self.data = data
        self.setUp()
    }
    
    func deleteButtonTapped(_ action: UIAlertAction){
        let alert = UIAlertController(title: "정말 삭제하시게요?", message: nil, preferredStyle: .alert)
        let cancelButton = UIAlertAction(title: "취소", style: .default, handler: cancelButtonTapped(_:))
        let secondDeleteButton = UIAlertAction(title: "삭제", style: .destructive, handler: secondDeleteButtonTapped(_:))
        
        alert.addAction(cancelButton)
        alert.addAction(secondDeleteButton)
    }
    
    func cancelButtonTapped(_ action: UIAlertAction){
        self.dismiss(animated: true)
    }
    
    func secondDeleteButtonTapped(_ action: UIAlertAction){
        guard let uuidString = self.data?.uuidString else { return }
        NotificationCenter.default.post(name: NSNotification.Name("deleteRecipe"), object: uuidString, userInfo: nil)
        self.navigationController?.popViewController(animated: true)
    }
    

    
}
