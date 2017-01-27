//
//  SignUpVC.swift
//  final
//
//  Created by Akash Ungarala on 8/9/16.
//  Copyright © 2016 Akash Ungarala. All rights reserved.
//

import UIKit
import Firebase

class SignUpVC: UIViewController {
    
    @IBOutlet weak var FirstName: UITextField!
    @IBOutlet weak var LastName: UITextField!
    @IBOutlet weak var Email: UITextField!
    @IBOutlet weak var Password: UITextField!
    @IBOutlet weak var ConfirmPassword: UITextField!
    var activityIndicatorView: ActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func Submit(sender: UIButton) {
        if FirstName.text == "" {
            alert("Please enter the First Name")
        } else if LastName.text == "" {
            alert("Please enter the Last Name")
        } else if Email.text == "" {
            alert("Please enter the Email")
        } else if Password.text == "" {
            alert("Please enter the Password");
        } else if ConfirmPassword.text == "" {
            alert("Please enter the Confirmation Password");
        } else if (Password.text! != ConfirmPassword.text!) {
            alert("Confirmation Password doesn't match with Password");
        } else {
            self.activityIndicatorView = ActivityIndicatorView(title: "Signing Up...", center: self.view.center)
            self.view.addSubview(self.activityIndicatorView.getViewActivityIndicator())
            self.activityIndicatorView.startAnimating()
            FIRAuth.auth()!.createUserWithEmail(self.Email.text!, password: self.Password.text!, completion: { (user, error) in
                if error != nil {
                    self.activityIndicatorView.stopAnimating()
                    self.alert("Firebase Sign Up Error")
                } else {
                    FIRAuth.auth()!.signInWithEmail(self.Email.text!, password: self.Password.text!, completion: { (user, error) in
                        if error != nil {
                            self.activityIndicatorView.stopAnimating()
                            self.alert("Firebase Login Error")
                        } else {
                            let userId = user?.uid
                            let userInfo = ["id": "\(userId!)", "email": "\(self.Email.text!)", "first_name": "\(self.FirstName.text!)", "last_name": "\(self.LastName.text!)", "created_at": FIRServerValue.timestamp(),"updated_at": FIRServerValue.timestamp()]
                            FIRDatabase.database().referenceWithPath("users/").child("\(userId!)").setValue(userInfo)
                            self.activityIndicatorView.stopAnimating()
                            self.performSegueWithIdentifier("SignUpSegue", sender: sender)
                        }
                    })
                }
            })
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if identifier == "SignUpSegue" {
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