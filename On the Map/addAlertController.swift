//
//  AddAlertController.swift
//  On the Map
//
//  Created by Andrew Fruth on 12/28/15.
//  Copyright © 2015 Udacity. All rights reserved.
//

import UIKit

struct AddAlertController {
    
    func makeAlert(message: String) {
        let alert = UIAlertController(title: "Login Error", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        alert.addAction(alertAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
}

