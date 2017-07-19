//
//MemeEditorViewController.swift
//  Meme V1.0
//
//  Created by Chun Yeung on 2017/7/18.
//  Copyright © 2017年 Chun Yeung. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate{
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var topToolBar: UIToolbar!
    @IBOutlet weak var bottomToolBar: UIToolbar!
    // TextField func
    
    let memeTextAttributes:[String:Any] = [
        NSStrokeColorAttributeName: UIColor.black,
        NSForegroundColorAttributeName: UIColor.white,
        NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBold", size: 40)!,
        NSStrokeWidthAttributeName: -3.0]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topTextField.text = "TOP"
        bottomTextField.text = "BUTTOM"
        
        func prepareTextField(textField: UITextField, defaultText: String?){
        
        let defaultText = textField
        defaultText.defaultTextAttributes = memeTextAttributes
        defaultText.textAlignment = NSTextAlignment.center
        textField.delegate = self
        }
        
        prepareTextField(textField: topTextField, defaultText:"TOP")
        prepareTextField(textField: bottomTextField, defaultText:"BOTTOM")
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.text == "TOP" || bottomTextField.text == "BUTTOM" {
            textField.text = ""
        }
        
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
        
    }
    
    // keyboard func
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
        
        if imagePickerView.image == nil{
            shareButtom.isEnabled = false
        }else{
            shareButtom.isEnabled = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()

    }
    
    func keyboardWillShow(_ notification:Notification) {
        if bottomTextField.isFirstResponder {
            view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    
    func keyboardWillHide(_ notification:Notification) {
            view.frame.origin.y = 0
        
    }
    
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    func subscribeToKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
        
    }
    
    func unsubscribeFromKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
        
        
    }
    

    

    
//    Image Picker func
    
    func pick(sourceType: UIImagePickerControllerSourceType){
        if UIImagePickerController.isSourceTypeAvailable(sourceType){
            let pickerController = UIImagePickerController()
            pickerController.delegate = self
            pickerController.sourceType = sourceType
            self.present(pickerController, animated: true, completion: nil)
        }
    }
    
    @IBAction func pickAnImageFromAlbum(_ sender: Any) {
        
        pick(sourceType: .photoLibrary)
        
    }
    
    @IBAction func pickAnImageFromCamera(_ sender: Any) {
        pick(sourceType: .camera)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as?UIImage{
            imagePickerView.image = image
            dismiss(animated: true, completion: nil)
        }
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
//    Save and Share func
    
    @IBOutlet weak var shareButtom: UIBarButtonItem!
    
    
    @IBAction func share(_ sender: Any) {

        
        let activityItems = [generateMemedImage()]
        
        let activityController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        
        activityController.completionWithItemsHandler = {
            
            activity,completed, items, error in
            if completed {
                self.save()
                self.dismiss(animated: true, completion: nil)
            }
        }
        
        present(activityController, animated: true, completion: nil)
        
    }
    
    
     func generateMemedImage() -> UIImage {
    
        func toolBarHiddenBool (hiddenBool:Bool) {
            self.bottomToolBar.isHidden = hiddenBool
            self.topToolBar.isHidden = hiddenBool
        }
        
        toolBarHiddenBool(hiddenBool: true)
        
         UIGraphicsBeginImageContext(self.view.frame.size)
         self.view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
         let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
         UIGraphicsEndImageContext()

        toolBarHiddenBool(hiddenBool: false)
         
     return memedImage
        
     }
    
    
    func save() {
     
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imagePickerView.image!, memedImage: generateMemedImage())
    }

    
}

