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
    var recipe : Recipe?
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
        guard let data = self.recipe else { return }
        if data.uuidString == uuidString {
            self.recipe?.bookmark = bookmark
            self.setUp()
        }
    }
    
    
    
    private func setUp(){
        guard let recipe = self.recipe else { return }
        self.mainImage.image = recipe.mainImage.toImage()
        self.dateLabel.text = self.dateToString(date: recipe.date)
        self.temperatureLabel.text = recipe.cookingTime
        self.titleLabel.text = recipe.title
        self.ingredientLabel.text = recipe.ingredient
        self.contentLabel.text = recipe.content
        self.commentLabel.text = recipe.comment
        self.bookmarButton.setImage(recipe.bookmark ? UIImage(systemName: "bookmark") : UIImage(systemName: "bookmart.fill"), for: .normal)
        self.bookmarButton.tintColor = UIColor(red: 232, green: 184, blue: 40, alpha: 1)
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
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
        rightBarButtonItem.tintColor = UIColor(red: 232, green: 184, blue: 40, alpha: 1)
       navigationItem.rightBarButtonItem = rightBarButtonItem
        
        let leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "ellipsis"), style: .plain, target: self, action: #selector(leftBarButtonTapped))
        leftBarButtonItem.tintColor = UIColor(red: 232, green: 184, blue: 40, alpha: 1)
       navigationItem.leftBarButtonItem = leftBarButtonItem

    }
    
    
    //Action
    @objc func rightBarButtonTapped(){
        let activityItems: [Any] = [recipe?.title]
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
        guard let recipe = self.recipe else { return }
        viewController.editMode = .edit(indexPath,recipe)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(editNotification(_:)),
            name: NSNotification.Name("editRecipe"),
            object: nil)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func editNotification(_ notification: Notification){
        guard let recipe = notification.object as? Recipe else { return }
        self.recipe = recipe
        self.setUp()
    }
    
    func deleteButtonTapped(_ action: UIAlertAction){
        let alert = UIAlertController(title: "정말 삭제하시게요?", message: nil, preferredStyle: .alert)
        let cancelButton = UIAlertAction(title: "취소", style: .default, handler: cancelButtonTapped(_:))
        let secondDeleteButton = UIAlertAction(title: "삭제", style: .destructive, handler: secondDeleteButtonTapped(_:))
        
        alert.addAction(cancelButton)
        alert.addAction(secondDeleteButton)
        
        self.present(alert, animated: true){
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissAlertController))
            alert.view.superview?.subviews[0].addGestureRecognizer(tapGesture)
        }
    }
    
    func cancelButtonTapped(_ action: UIAlertAction){
        self.dismiss(animated: true)
    }
    
    func secondDeleteButtonTapped(_ action: UIAlertAction){
        guard let uuidString = self.recipe?.uuidString else { return }
        NotificationCenter.default.post(name: NSNotification.Name("deleteRecipe"), object: uuidString, userInfo: nil)
        self.navigationController?.popViewController(animated: true)
    }
    

    
}

