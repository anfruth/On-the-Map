//
//  KeyboardController.swift
//  On the Map
//
//  Created by Andrew Fruth on 12/28/15.
//  Copyright © 2015 Udacity. All rights reserved.
//

import UIKit

 class KeyboardController : NSObject {
    
    init(emailField: UITextField?, passwordField: UITextField?, enteredLocationField: UITextField?, enterURLField: UITextField?, submitButton: UIButton?, viewController: UIViewController, view: UIView) {
        self.emailField = emailField
        self.passwordField = passwordField
        self.enteredLocationField = enteredLocationField
        self.enterURLField = enterURLField
        self.submitButton = submitButton
        self.viewController = viewController
        self.view = view
    }
    
    var emailField: UITextField?
    var passwordField: UITextField?
    var enteredLocationField: UITextField?
    var enterURLField: UITextField?
    var submitButton: UIButton?
    var viewController: UIViewController
    var view: UIView
    
     func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(viewController, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(viewController, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
     func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(viewController, name:
            UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(viewController, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    // https://discussions.udacity.com/t/better-way-to-shift-the-view-for-keyboardwillshow-and-keyboardwillhide/36558
    // Thank You!
    
     func keyboardWillShow(notification: NSNotification) {
        if emailField != nil && passwordField != nil && (emailField!.isFirstResponder() || passwordField!.isFirstResponder()) {
            view.frame.origin.y = -getKeyboardHeight(notification) / 2
        } else if (enteredLocationField != nil && enterURLField != nil && (enteredLocationField!.isFirstResponder() || enterURLField!.isFirstResponder())) {
            submitButton!.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    
     func keyboardWillHide(notification: NSNotification) {
        if emailField != nil && passwordField != nil && (emailField!.isFirstResponder() || passwordField!.isFirstResponder()) {
            view.frame.origin.y += getKeyboardHeight(notification) / 2
        } else if (enteredLocationField != nil && enterURLField != nil && (enteredLocationField!.isFirstResponder() || enterURLField!.isFirstResponder())) {
            submitButton!.frame.origin.y += getKeyboardHeight(notification)
        }
    }
    
     func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }

    
}
