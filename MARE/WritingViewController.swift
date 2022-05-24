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
    case edit(IndexPath, Recipe)
}

class WritingViewController: UIViewController{

    
    @IBOutlet weak var secondView: UIView!
    @IBOutlet weak var bookmarkButton: UIButton!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var mainImage: UIImageView!
    @IBOutlet weak var addImageButton: UIButton!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var cookingTimeTextField: UITextField!
    @IBOutlet weak var ingredientTextField: UITextView!
    @IBOutlet weak var contentTextField: UITextView!
    @IBOutlet weak var commentTextField: UITextView!
    @IBOutlet weak var folderTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
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
    var recipe: Recipe?
    private var folderList = [Folder]()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupEditMode()
        setupDataPicker()
        setupPickerView()
        touchesBegan()
        loadFolderList()
        dismissPickerView()
        setupFolderTextField()
        saveButton.isEnabled = true
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        self.navigationItem.leftBarButtonItem = UIBarButtonItem()
    }
    

    
  
    
    private func touchesBegan(){
        let singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(keyboardIsHidden(sender:)))
        singleTapGestureRecognizer.numberOfTapsRequired = 1
        singleTapGestureRecognizer.isEnabled = true
        singleTapGestureRecognizer.cancelsTouchesInView = false
        self.secondView.addGestureRecognizer(singleTapGestureRecognizer)
    }
    

    

    
    @objc private func keyboardIsHidden(sender: UITapGestureRecognizer){
        self.view.endEditing(true)
    }
    
    private func contentBasicSetup(){
        
            [ingredientTextField,contentTextField,commentTextField].forEach{
                $0?.layer.borderColor = UIColor.systemGray4.cgColor
                $0?.textColor = .black
                $0?.layer.cornerRadius = 8
                $0?.font = .systemFont(ofSize: 17)
                $0?.layer.borderWidth = 1

            }
    }
    
    private func newContentTextViewSetup(){
        
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
    
    
    private func setupFolderTextField(){
        if folderList.count == 0 {
            self.folderTextField.placeholder = "생성된 폴더가 없어요"
            self.folderTextField.isEnabled = false
        } else{
            self.folderTextField.placeholder = "폴더를 선택해주세요"
            self.folderTextField.isEnabled = true
        }
    }
    
    //EditMode
    private func setupEditMode(){
        switch editMode{
        case .new:
            newContentTextViewSetup()
            
        case let .edit(_, recipe):
            contentBasicSetup()
            self.mainImage.image = recipe.mainImage.toImage()
            self.dataDate = recipe.date
            self.dateTextField.text = dateToString(date: recipe.date)
            self.cookingTimeTextField.text = recipe.cookingTime
            self.titleTextField.text = recipe.title
            self.ingredientTextField.text = recipe.ingredient
            self.contentTextField.text = recipe.content
            self.commentTextField.text = recipe.comment
            self.folderTextField.text = recipe.folder
            self.addImageButton.alpha = 0

        }
    }
    
    
    
    

    
    private func setupDataPicker(){
        self.datePicker.datePickerMode = .date
        self.datePicker.preferredDatePickerStyle = .wheels
        self.datePicker.addTarget(self, action: #selector(datePickerValueDidChange(_:)), for: .valueChanged)
        self.dateTextField.inputView = self.datePicker
        self.datePicker.locale = Locale(identifier: "ko_KR")
    }
    
    @objc private func datePickerValueDidChange(_ datePicker: UIDatePicker){
        let formmator = DateFormatter()
        formmator.dateFormat = "yyyy-MM-dd(EEEE)"
        formmator.locale = Locale(identifier: "ko_KR")
        self.dataDate = datePicker.date
        self.dateTextField.text = formmator.string(from: datePicker.date)
    }
    
    
    
    

    //dateFormatter
    private func dateToString(date: Date) -> String {
        let formetter = DateFormatter()
        formetter.dateFormat = "yyyy-MM-dd(EEEE)"
        formetter.locale = Locale(identifier: "ko_KR")
        
        return formetter.string(from: date)
    }
    
    
    private func image() -> String {
        if self.mainImage.image == selectImage{
            return self.mainImage.image?.toString() ?? ""
        } else{
            if self.mainImage.image == UIImage(named: "AddImage"){
                return UIImage(named: "NilImage")?.toString() ?? ""
            } else {
                return self.mainImage.image?.toString() ?? ""
                
            }
        }
    }

    @IBAction func bookmarkButtonTapped(_ sender: UIButton) {
        
    }
    @IBAction func addImageButtonTapped(_ sender: UIButton) {
        present(imagePickerController, animated: true)
    }
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        guard let title = self.titleTextField.text else { return }
        guard let date = self.dataDate else { return }
        guard let cookingTime = self.cookingTimeTextField.text else { return }
        guard let ingredient = self.ingredientTextField.text else { return }
        guard let content = self.contentTextField.text else { return }
        guard let comment = self.commentTextField.text else { return }
        guard let folder = self.folderTextField.text else { return }
        let mainImage = image()
        
        switch self.editMode{
        case .new:
            let recipe = Recipe(
                uuidString: UUID().uuidString,
                title: title,
                date: date,
                cookingTime: cookingTime,
                ingredient: ingredient,
                content: content,
                comment: comment,
                folder: folder,
                bookmark: false,
                mainImage: mainImage)
            NotificationCenter.default.post(
                name: NSNotification.Name("newRecipe"),
                object: recipe,
                userInfo: nil
            )
        case let .edit(_, recipe):
            let recipe = Recipe(
                uuidString: recipe.uuidString,
                title: title,
                date: date,
                cookingTime: cookingTime,
                ingredient: ingredient,
                content: content,
                comment: comment,
                folder: folder,
                bookmark: recipe.bookmark,
                mainImage: mainImage)
            NotificationCenter.default.post(
                name: NSNotification.Name("editRecipe"),
                object: recipe,
                userInfo: nil
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
        self.mainImage.image = selectImage
        self.addImageButton.alpha = 0
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

//MARK: folder PickerView

extension WritingViewController{

    
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
    
    func setupPickerView(){
        self.folderPicker.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 220)
        self.folderPicker.dataSource = self
        self.folderPicker.delegate = self
        self.folderTextField.inputView = folderPicker
    }
    
    func dismissPickerView() {
            let toolBar = UIToolbar()
            toolBar.sizeToFit()
            let button = UIBarButtonItem(title: "선택", style: .plain, target: self, action: #selector(self.action))
            toolBar.setItems([button], animated: true)
            toolBar.isUserInteractionEnabled = true
            folderTextField.inputAccessoryView = toolBar
    }
    
    @objc func action() {
        self.view.endEditing(true)
       }
    
    
}

extension WritingViewController: UIPickerViewDelegate,UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return folderList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        
        let folder = folderList[row]
        return folder.folderName
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let folder = folderList[row]
        self.folderTextField.text = folder.folderName
    }
    

}


extension WritingViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    

    

}

extension UIImage{
    func toString() -> String?{
        let pngData = self.pngData()
        return pngData?.base64EncodedString(options: .lineLength64Characters)
    }
}
