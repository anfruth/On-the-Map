//
//  AlertBox.swift
//  On the Map
//
//  Created by Andrew Fruth on 12/28/15.
//  Copyright © 2015 Udacity. All rights reserved.
//

import UIKit

struct AlertBox {
    
    static func makeAlert(title: String, message: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        alert.addAction(alertAction)
        return alert
    }
    
}
