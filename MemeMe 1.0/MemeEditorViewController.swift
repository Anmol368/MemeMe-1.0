//
//  MemeEditorViewController.swift
//  MemeMe 1.0
//
//  Created by Anmol on 09/03/21.
//

import UIKit

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UITextFieldDelegate, UINavigationControllerDelegate {

   
    @IBOutlet weak var bottomToolbar: UIToolbar!
    @IBOutlet weak var topToolbar: UIToolbar!
    @IBOutlet weak var topToolbarShareButton: UIBarButtonItem!
    @IBOutlet weak var topToolbarCancelButton: UIBarButtonItem!
    
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    

    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    let memeTextAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.strokeColor: UIColor.black,
        NSAttributedString.Key.foregroundColor: UIColor.white,
        NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSAttributedString.Key.strokeWidth:  NSNumber.init(value: -3.0)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
        
        orgTextField(textField: topTextField)
        orgTextField(textField: bottomTextField)
        
        topToolbarShareButton.isEnabled = false
        
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
        
        
    }

    @IBAction func pickAnImageFromAlbum(_ sender: Any) {
        
        pickAnImage(source: .photoLibrary)
        
    }

    @IBAction func pickAnImageFromCamera(_ sender: Any) {
        
        pickAnImage(source: .camera)

    }
    
    func pickAnImage(source: UIImagePickerController.SourceType) {
        
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = source
        present(pickerController, animated: true, completion: nil)
                
        }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            imagePickerView.image = image
            topToolbarShareButton.isEnabled = true
            
            dismiss(animated: true, completion: nil)
        }
    
    }
    
    
    
    private func imagePickerControllerDidCancel(_ picker: UIImagePickerController) -> Bool {
        return true
    }
    
    @IBAction func shareMeme(_ sender: Any) {
        
        let memeImage = generateMemedImage()
        let shareMeme = memeImage
        
        let activityController = UIActivityViewController(activityItems: [shareMeme] , applicationActivities: nil )
        
        
        activityController.completionWithItemsHandler = { (activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
            if !completed {
                // User canceled
                return
            }
            // User completed activity
            self.save(memeImage: shareMeme)
        }
        
        self.present(activityController, animated: true, completion: nil)

        
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
        
        topToolbarShareButton.isEnabled = false
        
        imagePickerView.image = nil
        
        dismiss(animated: true, completion: nil)
        
    }
    
    
    
    func orgTextField(textField: UITextField) {
        
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = NSTextAlignment.center
        textField.delegate = self
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if (topTextField == textField && topTextField.text == "TOP") {
                    topTextField.text = ""
                }
                else if (bottomTextField == textField && bottomTextField.text == "BOTTOM") {
                    bottomTextField.text = ""
                }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
    
    func subscribeToKeyboardNotifications() {

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }

    func unsubscribeFromKeyboardNotifications() {

        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {

        if bottomTextField.isEditing {
            view.frame.origin.y = -getKeyboardHeight(notification)
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        }
        
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        
        view.frame.origin.y = 0
    }

    func getKeyboardHeight(_ notification: Notification) -> CGFloat {

        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    func generateMemedImage() -> UIImage {

        //Hide toolbar and navbar
        toolBarsWillHide(visible: true)

        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memeImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        //Show toolbar and navbar
        toolBarsWillHide(visible: false)

        return memeImage
    }
    
    func toolBarsWillHide(visible: Bool) {
        
        bottomToolbar.isHidden = visible
        topToolbar.isHidden = visible
        
    }
    
    func save(memeImage: UIImage) {
            // Create the meme
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imagePickerView.image!, memeImage: memeImage )
    }

}
