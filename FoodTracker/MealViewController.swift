//
//  MealViewController.swift
//  FoodTracker
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
    //@IBOutlet weak var ratingControl: RatingControl!
    @IBOutlet weak var episodeTextField: UITextField!
    @IBOutlet weak var totalTextField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    

    
    var meal: Meal?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Handle the text field’s user input through delegate callbacks.
        nameTextField.delegate = self
        
        if let meal = meal {
            //navigationItem.title = meal.name
            nameTextField.text = meal.name
            photoImageView.image = meal.photo
            episodeTextField.text = meal.episode
            totalTextField.text = meal.total
            //ratingControl.rating = meal.rating
            
        }
        
        updateSaveButtonState()
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
        //navigationItem.title = textField.text
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
        
        // Configure the destination view controller only when the save button is pressed.
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
            //let rating = ratingControl.rating
            let episode = episodeTextField.text ?? ""
            let total = totalTextField.text ?? ""
            
            print("meal saved")
            
            // Set the meal to be passed to MealTableViewController after the unwind segue.
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

