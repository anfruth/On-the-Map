//
//  InformationPostingViewController.swift
//  On the Map
//
//  Created by Andrew Fruth on 12/10/15.
//  Copyright © 2015 Udacity. All rights reserved.
//

import UIKit
import CoreLocation
import AddressBook
import MapKit

class InformationPostingViewController: UIViewController {
    
    let geoCoder = CLGeocoder()
    var locationEntered: CLLocation?
    let apiClient = StudentAPIClient(endpoint: "https://api.parse.com/1/classes/StudentLocation", parseID: Config.parseID, parseAPIKey: Config.parseAPIKey)
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var enteredLocationField: UITextField!
    @IBOutlet weak var whereStudyingLabel: UILabel!
    @IBOutlet weak var enterURLField: UITextField!
    @IBOutlet weak var findOnMapButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var mainBackgroundView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var geocodingIndicator: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cancelButton.setTitleColor(UIColor(red: 75.0/255, green: 125.0/255, blue: 200.0/255, alpha: 1.0), forState: .Normal)
        geocodingIndicator.hidden = true
    }
    
    @IBAction func closeKeyboard(sender: UITextField) {
        sender.resignFirstResponder()
    }

    @IBAction func cancelInfoPost(sender: UIButton) {
        dismissViewControllerAnimated(false, completion: nil)
    }
    
    // 2 methods below inspired by http://www.techotopia.com/index.php/An_Example_Swift_iOS_8_MKMapItem_Application
    
    @IBAction func findPositionOnMap(sender: UIButton) {
        geocodingIndicator.hidden = false
        geocodingIndicator.startAnimating()
        let enteredLocation = enteredLocationField.text!
        geoCoder.geocodeAddressString(enteredLocation, completionHandler: handleGeoLocationData)
    }
    
    private func handleGeoLocationData(placemarks: [CLPlacemark]?, error: NSError?) {
        geocodingIndicator.stopAnimating()
        geocodingIndicator.hidden = true
        if error != nil {
            let alert = AlertBox.makeAlert("Geocoding Error", message: error!.localizedDescription)
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            whereStudyingLabel.hidden = true
            enterURLField.hidden = false
            mainBackgroundView.backgroundColor = UIColor(red: 65.0/255, green: 94.0/255, blue: 154.0/255, alpha: 1.0)
            showPositionOnMap(placemarks)
        }
    }
    
    // http://www.raywenderlich.com/90971/introduction-mapkit-swift-tutorial
    
    private func showPositionOnMap(placemarks: [CLPlacemark]?) {
        if placemarks != nil && placemarks!.count > 0 {
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = placemarks![0].location!.coordinate
            if placemarks![0].name != nil {
               annotation.title = placemarks![0].name!
            }
            mapView.addAnnotations([annotation])
            
            let firstLocationResult = placemarks![0]
            locationEntered = firstLocationResult.location! // CLLocation?
            let regionRadius: CLLocationDistance = 1000
            let coordinateRegion = MKCoordinateRegionMakeWithDistance(locationEntered!.coordinate, regionRadius * 2.0, regionRadius * 2.0)
            mapView.hidden = false
            mapView.setRegion(coordinateRegion, animated: true)
            cancelButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            findOnMapButton.hidden = true
            submitButton.hidden = false
        }
    }
    
    @IBAction func postStudyLocation(sender: UIButton) {
        let locationString = enteredLocationField.text!
        let mediaURL = enterURLField.text!
        let latitude = locationEntered!.coordinate.latitude
        let longitude = locationEntered!.coordinate.longitude
    
        apiClient.postStudentLocation(locationString, mediaURL: mediaURL, latitude: latitude, longitude: longitude) { error in
            if error == nil {
                self.refreshData()
            } else {
                NSOperationQueue.mainQueue().addOperationWithBlock() {
                    self.enterURLField.hidden = true
                    let alert = AlertBox.makeAlert("Failed to Post Student", message: error!.localizedDescription)
                    self.presentViewController(alert, animated: true, completion: nil)
                    self.whereStudyingLabel.textColor = UIColor.whiteColor()
                    self.whereStudyingLabel.hidden = false
                }
            }
        }
    }
    
    
    private func refreshData() {
        apiClient.getAllStudentData() { studentDataRaw in
            if studentDataRaw != nil {
                self.convertToStudentInformation(studentDataRaw!)
                self.dismissViewControllerAnimated(false, completion: nil)
            } else {
                print("request error")
            }
        }
    }
    
    private func convertToStudentInformation(studentDataRaw: [[String : AnyObject]]) {
        StudentAPIClient.allStudents = []
        for individualStudentData in studentDataRaw {
            var udacityStudent = StudentInformation(individualStudentData: individualStudentData, containsError: false, errorMessage: "")
            if individualStudentData["error"] != nil {
                udacityStudent.containsError = true
                udacityStudent.errorMessage = individualStudentData["error"] as! String
            }
            StudentAPIClient.allStudents.append(udacityStudent)
        }
    }
}