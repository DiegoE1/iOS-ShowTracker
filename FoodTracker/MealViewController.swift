//
//  MealViewController.swift
//  ShowTracker
//
//  Created by Diego Espinosa on 8/15/18.
//  Copyright © 2018 Diego Espinosa. All rights reserved.
//
import os.log
import UIKit

@IBDesignable class MealViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK: Properties
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var episodeTextField: UITextField!
    @IBOutlet weak var totalTextField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    

    
    var meal: Meal?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerSettingsBundle()
        NotificationCenter.default.addObserver(self, selector: #selector(MealViewController.defaultsChanged), name: UserDefaults.didChangeNotification, object: nil)
        defaultsChanged()
        
        nameTextField.delegate = self
        
        if let meal = meal {
            nameTextField.text = meal.name
            photoImageView.image = meal.photo
            episodeTextField.text = meal.episode
            totalTextField.text = meal.total
        }
        updateSaveButtonState()
    }
    
    func registerSettingsBundle(){
        let appDefaults = [String:AnyObject]()
        UserDefaults.standard.register(defaults: appDefaults)
    }
    @objc func defaultsChanged(){
        if UserDefaults.standard.bool(forKey: "DARK_THEME_KEY"){
            //dark themed enabled
            updateToDarkTheme()
        } else {
            //dark themed disabled
            updateToLightTheme()
        }
    }
    func updateToDarkTheme(){
        // background color
        self.view.backgroundColor = UIColor.darkGray
        
        // nav bar color
        self.navigationController?.navigationBar.barStyle = UIBarStyle.black
        self.navigationController?.navigationBar.backgroundColor = UIColor.darkGray
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        // text field background color
        self.nameTextField.backgroundColor = UIColor.lightGray
        self.episodeTextField.backgroundColor = UIColor.lightGray
        self.totalTextField.backgroundColor = UIColor.lightGray
        
        // text field text color
        self.nameTextField.textColor = UIColor.white
        self.episodeTextField.textColor = UIColor.white
        self.totalTextField.textColor = UIColor.white
        
        // text field keyboard appearance
        self.nameTextField.keyboardAppearance = .dark
        self.episodeTextField.keyboardAppearance = .dark
        self.totalTextField.keyboardAppearance = .dark
    }
    func updateToLightTheme(){
        // background color
        self.view.backgroundColor = UIColor.white
        
        // nav bar color
        self.navigationController?.navigationBar.barStyle = UIBarStyle.default
        self.navigationController?.navigationBar.tintColor = .systemBlue
        
        // text field background color
        self.nameTextField.backgroundColor = UIColor.white
        self.episodeTextField.backgroundColor = UIColor.white
        self.totalTextField.backgroundColor = UIColor.white
        
        // text field text color
        self.nameTextField.textColor = UIColor.black
        self.episodeTextField.textColor = UIColor.black
        self.totalTextField.textColor = UIColor.black
        
        // text field appearance
        self.nameTextField.keyboardAppearance = .default
        self.episodeTextField.keyboardAppearance = .default
        self.totalTextField.keyboardAppearance = .default
    }
    
    //MARK: UItextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //Hide Keyboard
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        saveButton.isEnabled = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateSaveButtonState()
    }
    
    //MARK: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as?
            UIImage else {
                fatalError("Expected a dictionary containing an image, but was provided teh following: \(info)")
        }
        photoImageView.image = selectedImage
        
        dismiss(animated: true, completion: nil)
    }
    //MARK: Navigation
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        let isPresentingInAddMealMode = presentingViewController is UINavigationController
        if isPresentingInAddMealMode {
            dismiss(animated: true, completion: nil)
        }
        else if let owningNavigationController = navigationController{
            owningNavigationController.popViewController(animated: true)
        }
        else {
            fatalError("The MealViewController is not inside a navigation controller.")
        }
    }
    
    // break
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
        
        if(episodeTextField.text == nil || totalTextField.text == nil){
            print("episode cannot be nill")
            if(Int(episodeTextField.text!)! > Int(totalTextField.text!)!){
                print("episode cannot be large than total")
                episodeTextField.resignFirstResponder()
            }
            
        } else {
            let name = nameTextField.text ?? ""
            let photo = photoImageView.image
            let episode = episodeTextField.text ?? ""
            let total = totalTextField.text ?? ""
            
            print("meal saved")
            
            meal = Meal(name: name, photo: photo, episode: episode, total: total)
        }
    }
    
    //MARK: Actions
    @IBAction func selectImageFromPhotoLibrary(_ sender: UITapGestureRecognizer) {
        nameTextField.resignFirstResponder()
        
        let imagePickerController = UIImagePickerController()
        
        imagePickerController.sourceType = .photoLibrary
        
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    //MARK: Private Methods
    private func updateSaveButtonState(){
        let text = nameTextField.text ?? ""
        saveButton.isEnabled = !text.isEmpty
    }
}




