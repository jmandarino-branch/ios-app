//
//  MealViewController.swift
//  FoodTracker
//
//  Created by Jane Appleseed on 10/17/16.
//  Copyright © 2016 Apple Inc. All rights reserved.
//

import UIKit
import os.log
import Branch

class MealViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK: Properties
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var ratingControl: RatingControl!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIButton!
    
    @IBOutlet weak var testButton: UIButton!
    @IBOutlet weak var purchaseButton: UIButton!
    @IBAction func shareClicked(_ sender: UIButton) {
        
        let buo = BranchUniversalObject.init(canonicalIdentifier: "content/12345")
        buo.title = "share sheet test"
        buo.contentDescription = "share sheet"
        buo.imageUrl = "https://lorempixel.com/400/400"

        
        let lp: BranchLinkProperties = BranchLinkProperties()
        lp.channel = "facebook"
        lp.feature = "sharing"
        lp.campaign = "champaign campaign"
        lp.stage = "new user"
        lp.tags = ["one", "two", "three"]
        
        if meal != nil{
            lp.tags = [meal?.name]
            print(lp.tags)
        }
        lp.addControlParam("random", withValue: UUID.init().uuidString)
        
        let message = "Check out this link"
        buo.showShareSheet(with: lp, andShareText: message, from: self) { (activityType, completed) in
            print(activityType ?? "")
        }
    }
    @IBAction func purchaseClicked(_ sender: UIButton) {
        // Create a BranchUniversalObject with your content data:
        let branchUniversalObject = BranchUniversalObject.init()
        
        // ...add data to the branchUniversalObject as needed...
        
        branchUniversalObject.canonicalIdentifier = ""
        if meal != nil{
            branchUniversalObject.canonicalIdentifier = meal?.name
        }
        branchUniversalObject.canonicalUrl        = "https://branch.io/item/12345"
        branchUniversalObject.title               = "purchased something"
        
        // Create a BranchEvent:
        let event = BranchEvent.standardEvent(.purchase)
        
        // Add the BranchUniversalObjects with the content:
        event.contentItems     = [ branchUniversalObject ]
        
        // Add relevant event data:
        event.transactionID    = "12344555"
        event.currency         = .USD;
        event.revenue          = 1.5
        event.shipping         = 10.2
        event.tax              = 12.3
        event.eventDescription = "Event_description";
        event.searchQuery      = "item 123"
        event.customData       = [
            "Custom_Event_Property_Key1": "Custom_Event_Property_val1",
            "Custom_Event_Property_Key2": "Custom_Event_Property_val2"
        ]
        event.logEvent() // Log the event.
        
    }
    @IBAction func testButtonClick(_ sender: UIButton) {
        print("click click")
        let buo = BranchUniversalObject.init(canonicalIdentifier: "content/12345")
        //buo.title = "kiki do you love me"
        //buo.contentDescription = "My Content Description"
        //buo.imageUrl = "https://lorempixel.com/400/400"
        buo.publiclyIndex = true
        buo.locallyIndex = true
        buo.contentMetadata.customMetadata["key1"] = "value1"
        
        let lp: BranchLinkProperties = BranchLinkProperties()
        lp.channel = "facebook"
        lp.feature = "sharing"
        lp.campaign = "champaign campaign"
        lp.stage = "new user"
        lp.tags = ["one", "two", "three"]
        
        if meal != nil{
            lp.tags = [meal?.name]
            print(lp.tags)
        }
        
        lp.addControlParam("$fallback_url", withValue: "https://www.actionnetwork.com/ncaab/2019-ncaa-tournament-saturday-betting-picks-predictions-march-madness")
        lp.addControlParam("$match_duration", withValue: "2000")
        
        lp.addControlParam("custom_data", withValue: "yes")
        lp.addControlParam("look_at", withValue: "this")
        lp.addControlParam("nav_to", withValue: "over here")
        lp.addControlParam("random", withValue: UUID.init().uuidString)
        
        buo.getShortUrl(with: lp) { (url, error) in
            print(url ?? "")
            print("hello")
        }
        
        
    }
    /*
         This value is either passed by `MealTableViewController` in `prepare(for:sender:)`
         or constructed as part of adding a new meal.
     */
    var meal: Meal?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Handle the text field’s user input through delegate callbacks.
        nameTextField.delegate = self
        
        // Set up views if editing an existing Meal.
        if let meal = meal {
            navigationItem.title = meal.name
            nameTextField.text = meal.name
            photoImageView.image = meal.photo
            ratingControl.rating = meal.rating
        }
        
        // Enable the Save button only if the text field has a valid Meal name.
        updateSaveButtonState()
    }
    
    //MARK: UITextFieldDelegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Disable the Save button while editing.
        saveButton.isEnabled = false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateSaveButtonState()
        navigationItem.title = textField.text
    }
    
    //MARK: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        // The info dictionary may contain multiple representations of the image. You want to use the original.
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        // Set photoImageView to display the selected image.
        photoImageView.image = selectedImage
        
        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: Navigation
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        // Depending on style of presentation (modal or push presentation), this view controller needs to be dismissed in two different ways.
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
    
    // This method lets you configure a view controller before it's presented.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        // Configure the destination view controller only when the save button is pressed.
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
        
        let name = nameTextField.text ?? ""
        let photo = photoImageView.image
        let rating = ratingControl.rating
        
        // Set the meal to be passed to MealTableViewController after the unwind segue.
        meal = Meal(name: name, photo: photo, rating: rating)
    }
    
    //MARK: Actions
    @IBAction func selectImageFromPhotoLibrary(_ sender: UITapGestureRecognizer) {
        
        // Hide the keyboard.
        nameTextField.resignFirstResponder()
        
        // UIImagePickerController is a view controller that lets a user pick media from their photo library.
        let imagePickerController = UIImagePickerController()
        
        // Only allow photos to be picked, not taken.
        imagePickerController.sourceType = .photoLibrary
        
        // Make sure ViewController is notified when the user picks an image.
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    //MARK: Private Methods
    
    private func updateSaveButtonState() {
        // Disable the Save button if the text field is empty.
        let text = nameTextField.text ?? ""
        saveButton.isEnabled = !text.isEmpty
    }
    
}

