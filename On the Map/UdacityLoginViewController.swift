//
//  UdacityLoginViewController.swift
//  On the Map
//
//  Created by Andrew Fruth on 11/22/15.
//  Copyright © 2015 Udacity. All rights reserved.
//

import UIKit

class UdacityLoginViewController: UIViewController {
    
    static var userID = ""
    static var firstName = ""
    static var lastName = ""
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    @IBAction func closeKeyboard(sender: UITextField) {
        sender.resignFirstResponder()
    }
    
    @IBAction func signUpUdacity(sender: UIButton) {
        UIApplication.sharedApplication().openURL(NSURL(string: "https://www.google.com/url?q=https://www.udacity.com/account/auth%23!/signin&sa=D&usg=AFQjCNHOjlXo3QS15TqT0Bp_TKoR9Dvypw")!)
    }
    
    @IBAction func loginViaUdacity(sender: UIButton) {
        let email = emailField.text!
        let password = passwordField.text!
        
        let loginClient = LoginAPIClient(email: email, password: password)
        loginClient.makeLoginRequest("POST") { error, userID in
        // http://stackoverflow.com/questions/24022479/how-would-i-create-a-uialertview-in-swift
            NSOperationQueue.mainQueue().addOperationWithBlock() {
                if error == nil {
                    self.findUserName(userID)
                } else if error as? String == "JSONParse" {
                    let alert = AlertBox.makeAlert("Login Error", message: "Could not parse JSON from data.")
                    self.presentViewController(alert, animated: true, completion: nil)
                } else if (error as? String) != nil {
                    let message = error as! String
                    let alert = AlertBox.makeAlert("Login Error", message: message)
                    self.presentViewController(alert, animated: true, completion: nil)
                } else {
                    let alert = AlertBox.makeAlert("Login Error", message: error!.localizedDescription)
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    private func findUserName(userID: String?) {
        let email = emailField.text!
        let password = passwordField.text!
        
        let loginClient = LoginAPIClient(email: email, password: password)
        loginClient.getUserDetails(userID) { error in
            NSOperationQueue.mainQueue().addOperationWithBlock() {
                if error != nil {
                    let message = error!
                    let alert = AlertBox.makeAlert("Login Error", message: message)
                    self.presentViewController(alert, animated: true, completion: nil)
                } else {
                    self.performSegueWithIdentifier("showMapView", sender: self)
                }
            }
        }
    }
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name:
            UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    // https://discussions.udacity.com/t/better-way-to-shift-the-view-for-keyboardwillshow-and-keyboardwillhide/36558
    // Thank You!
    
    func keyboardWillShow(notification: NSNotification) {
        if emailField.isFirstResponder() || passwordField.isFirstResponder() {
            view.frame.origin.y = -getKeyboardHeight(notification) / 2
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if emailField.isFirstResponder() || passwordField.isFirstResponder() {
            view.frame.origin.y += getKeyboardHeight(notification) / 2
        }
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }

    
}
