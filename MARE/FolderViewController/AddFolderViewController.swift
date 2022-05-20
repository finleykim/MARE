//
//  AddFolderViewController.swift
//  MARE
//
//  Created by Finley on 2022/05/14.
//

import UIKit

final class AddFolderViewController: UIViewController{

    
    @IBOutlet weak var superView: UIView!
    @IBOutlet weak var modalyView: UIView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    var datePicker = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        touchesBegan()

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.modalyView.endEditing(true)
    }
    
    
    private func touchesBegan(){
        let singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(keyboardIsHidden(sender:)))
        singleTapGestureRecognizer.numberOfTapsRequired = 1
        singleTapGestureRecognizer.isEnabled = true
        singleTapGestureRecognizer.cancelsTouchesInView = false
        self.modalyView.addGestureRecognizer(singleTapGestureRecognizer)
    }
    
    @objc private func keyboardIsHidden(sender: UITapGestureRecognizer){
        self.view.endEditing(true)
    }
    
    private func setup(){
        
        self.modalyView.layer.cornerRadius = 30
        
    }
    
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {

        
        guard let folderName = self.nameTextField.text else { return }
        
        let folder = Folder(uuidString: UUID().uuidString,
                                    folderName: folderName,
                            date: datePicker.date)
        NotificationCenter.default.post(name: NSNotification.Name("newFolder"), object: folder, userInfo: nil)
        
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
}
