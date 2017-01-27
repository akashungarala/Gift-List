//
//  NewPersonVC.swift
//  final
//
//  Created by Akash Ungarala on 8/9/16.
//  Copyright © 2016 Akash Ungarala. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage

class NewPersonVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var selectedImageUrl:String!
    let ref = FIRDatabase.database().referenceWithPath("users/").child((FIRAuth.auth()?.currentUser?.uid)!)
    var activityIndicatorView: ActivityIndicatorView!
    
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var allocatedBudget: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.avatar.addGestureRecognizer(UITapGestureRecognizer(target: self, action:  #selector(self.uploadAvatar)))
        self.avatar.userInteractionEnabled = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func uploadAvatar() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        presentViewController(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        self.selectedImageUrl = nil
        var selectedImage:UIImage!
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImage = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImage = originalImage
        }
        dismissViewControllerAnimated(true, completion: nil)
        self.activityIndicatorView = ActivityIndicatorView(title: "Loading...", center: self.view.center)
        self.view.addSubview(self.activityIndicatorView.getViewActivityIndicator())
        self.activityIndicatorView.startAnimating()
        if let image = selectedImage {
            let imageName = NSUUID().UUIDString
            let storageRef = FIRStorage.storage().reference().child("photos").child("\(imageName).png")
            let uploadData = UIImagePNGRepresentation(image)
            storageRef.putData(uploadData!, metadata: nil, completion: { (metadata, error) in
                if (error == nil) {
                    if let image = metadata?.downloadURL()?.absoluteString {
                        self.selectedImageUrl = image
                        if let imageURL:NSURL? = NSURL(string: image) {
                            if let url = imageURL {
                                self.avatar.sd_setImageWithURL(url)
                                self.activityIndicatorView.stopAnimating()
                            }
                        }
                    }
                }
            })
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func submit(sender: UIButton) {
        if selectedImageUrl == nil  {
            alert("Please select the Avatar")
        } else if name.text == "" {
            alert("Please enter the Name")
        } else if allocatedBudget.text == "" {
            alert("Please enter the Allocated Budget ($)")
        } else {
            let a:Int? = Int(allocatedBudget.text!)
            if (a == nil) {
                alert("Please enter a valid integer value for Allocated Budget ($)")
            } else {
                self.activityIndicatorView = ActivityIndicatorView(title: "Adding Person...", center: self.view.center)
                self.view.addSubview(self.activityIndicatorView.getViewActivityIndicator())
                self.activityIndicatorView.startAnimating()
                let id = self.ref.child("persons").childByAutoId().key
                self.ref.child("persons").child(id).setValue(["id": id, "avatar": selectedImageUrl, "name": self.name.text!, "allocated_budget": self.allocatedBudget.text!, "created_at": FIRServerValue.timestamp(), "updated_at": FIRServerValue.timestamp()])
                self.activityIndicatorView.stopAnimating()
                self.performSegueWithIdentifier("SubmitNewPersonSegue", sender: sender)
            }
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if identifier == "SubmitNewPersonSegue" {
            return false
        }
        return true
    }
    
    func alert(alertMessage: String) {
        let alert = UIAlertController(title: "Alert", message: alertMessage, preferredStyle: UIAlertControllerStyle.Alert)
        let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alert.addAction(action)
        self.presentViewController(alert, animated: true, completion: nil)
    }

}