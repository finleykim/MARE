//
//  WritingViewController.swift
//  MARE
//
//  Created by Finley on 2022/05/12.
//

import Foundation
import UIKit

enum EditMode{
    case new
    case edit(IndexPath, Data)
}

class WritingViewController: UIViewController{

    
    @IBOutlet weak var bookmarkButton: UIButton!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var mainImage: UIImageView!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var cookingTimeTextField: UITextField!
    @IBOutlet weak var ingredientTextField: UITextView!
    @IBOutlet weak var contentTextField: UITextView!
    @IBOutlet weak var commentTextField: UITextView!
    @IBOutlet weak var folderTextField: UITextField!
    
    private lazy var imagePickerController: UIImagePickerController = {
       let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        
        return imagePickerController
    }()
    private var datePicker = UIDatePicker()
    private var folderPicker = UIPickerView()
    private var dataDate: Date?
    var editMode: EditMode = .new
    var selectImage: UIImage?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        setupEditMode()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
      self.view.endEditing(true)
    }
    
    
    
    private func setup(){
        self.bookmarkButton.tintColor = UIColor(red: 232, green: 184, blue: 40, alpha: 1)
            [ingredientTextField,contentTextField,commentTextField].forEach{
                $0?.layer.borderColor = UIColor.systemGray4.cgColor
                $0?.textColor = .systemGray4
                $0?.layer.cornerRadius = 8
                $0?.font = .systemFont(ofSize: 15)
                $0?.layer.borderWidth = 1
                self.ingredientTextField.text = "재료를 입력해주세요"
                self.contentTextField.text = "레시피를 입력해주세요"
                self.commentTextField.text = "추가코멘트를 입력해주세요"
                $0?.delegate = self
        }
    }
    
    //EditMode
    private func setupEditMode(){
        switch editMode{
        case let .edit(_, data):
            self.mainImage.image = data.mainImage
            self.dataDate = data.date
            self.cookingTimeTextField.text = data.cookingTime
            self.titleTextField.text = data.title
            self.ingredientTextField.text = data.ingredient
            self.contentTextField.text = data.content
            self.commentTextField.text = data.comment
            self.folderTextField.text = data.folder
            
        default: break
        }
    }
    
    //dateFormatter
    private func dateToString(date: Date) -> String {
        let formetter = DateFormatter()
        formetter.dateFormat = "yyyy-MM-dd(EEEE)"
        formetter.locale = Locale(identifier: "ko_KR")
        
        return formetter.string(from: date)
    }
    

    @IBAction func bookmarkButtonTapped(_ sender: UIButton) {
    }
    @IBAction func imagePickButtonTapped(_ sender: UIButton) {
        present(imagePickerController, animated: true)
    }
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        guard let image = self.mainImage.image ?? UIImage(named: "NilImage") else { return }
        guard let title = self.titleTextField.text else { return }
        guard let date = self.dataDate else { return }
        guard let cookingTime = self.cookingTimeTextField.text else { return }
        guard let ingredient = self.ingredientTextField.text else { return }
        guard let content = self.contentTextField.text else { return }
        guard let comment = self.commentTextField.text else { return }
        guard let folder = self.folderTextField.text else { return }
        
        
        switch self.editMode{
        case .new:
            let data = Data(uuidString: UUID().uuidString, title: title, mainImage: image, date: date, cookingTime: cookingTime, ingredient: ingredient, content: content, comment: comment, folder: folder, bookmark: false)
            NotificationCenter.default.post(
                name: NSNotification.Name("newRecipe"), object: data, userInfo: nil
            )
        case let .edit(_, data):
            let data = Data(uuidString: data.uuidString, title: title, mainImage: image, date: date, cookingTime: cookingTime, ingredient: ingredient, content: content, comment: comment, folder: folder, bookmark: data.bookmark)
            NotificationCenter.default.post(
                name: NSNotification.Name("editRecipe"), object: data, userInfo: nil
            )
        
        }
        self.navigationController?.popViewController(animated: true)
    }
}





extension WritingViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        if let editImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.selectImage = editImage
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.selectImage = originalImage
        }
        picker.dismiss(animated: true)
    }
}

extension WritingViewController: UITextViewDelegate{
    func textViewDidBeginEditing(_ textView: UITextView) {
        guard textView.textColor == .systemGray4 else { return }
        textView.text = nil
        textView.textColor = .label
        textView.font = .systemFont(ofSize: 17)
  }
}
