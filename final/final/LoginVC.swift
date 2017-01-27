//
//  LoginVC.swift
//  final
//
//  Created by Akash Ungarala on 8/9/16.
//  Copyright © 2016 Akash Ungarala. All rights reserved.
//

import UIKit
import Firebase

class LoginVC: UIViewController {
    
    @IBOutlet weak var Email: UITextField!
    @IBOutlet weak var Password: UITextField!
    var status:Bool! = true
    var activityIndicatorView: ActivityIndicatorView!
    
    @IBAction func Login(sender: UIButton) {
        if Email.text == "" {
            alert("Please enter the Email")
            status = false
        } else if Password.text == "" {
            alert("Please enter the Password");
            status = false
        } else {
            self.activityIndicatorView = ActivityIndicatorView(title: "Signing In...", center: self.view.center)
            self.view.addSubview(self.activityIndicatorView.getViewActivityIndicator())
            self.activityIndicatorView.startAnimating()
            FIRAuth.auth()!.signInWithEmail(self.Email.text!, password: self.Password.text!, completion: { (user, error) in
                if error != nil {
                    self.activityIndicatorView.stopAnimating()
                    self.alert("Firebase Login Error")
                    self.status = false
                } else {
                    self.status = true
                    self.performSegueWithIdentifier("LoginSegue", sender: sender)
                    self.activityIndicatorView.stopAnimating()
                }
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if (FIRAuth.auth()?.currentUser != nil) {
            performSegueWithIdentifier("LoginSegue", sender: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if identifier == "LoginSegue" {
            return false
        }
        return true
    }
    
    @IBAction func cancelUnwindToLogin(sender: UIStoryboardSegue) {}
    
    @IBAction func submitUnwindToLogin(sender: UIStoryboardSegue) {
        performSegueWithIdentifier("LoginSegue", sender: nil)
    }
    
    @IBAction func logoutUnwindToLogin(sender: UIStoryboardSegue) {
        try! FIRAuth.auth()!.signOut()
    }
    
    func alert(alertMessage: String) {
        let alert = UIAlertController(title: "Alert", message: alertMessage, preferredStyle: UIAlertControllerStyle.Alert)
        let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alert.addAction(action)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
}