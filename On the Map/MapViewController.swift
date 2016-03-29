//
//  MapViewController.swift
//  On the Map
//
//  Created by Andrew Fruth on 11/22/15.
//  Copyright © 2015 Udacity. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if StudentAPIClient.allStudents.count > 0 && StudentAPIClient.allStudents[0].containsError == false { // if students array already exists, might have updated from list view, or if studentData is an error message
            mapView.removeAnnotations(mapView.annotations)
            placePinsOnMap(StudentAPIClient.allStudents)
        } else {
            loadMap()
        }
    }
    @IBAction func logout(sender: UIBarButtonItem) {
        let loginClient = LoginAPIClient(email: nil, password: nil)
        loginClient.makeLoginRequest("DELETE") { error, userID in
            let loginVC = self.storyboard?.instantiateViewControllerWithIdentifier("loginVC") as! UdacityLoginViewController
            NSOperationQueue.mainQueue().addOperationWithBlock() {
                self.presentViewController(loginVC, animated: true, completion: nil)
            }

        }
    }
    
    private func loadMap() { // gets data and populates map with annotations
        mapView.removeAnnotations(mapView.annotations)
        let apiClient = StudentAPIClient(endpoint: "https://api.parse.com/1/classes/StudentLocation", parseID: Config.parseID, parseAPIKey: Config.parseAPIKey)
        apiClient.getAllStudentData() { studentDataRaw in
                if studentDataRaw != nil && studentDataRaw![0]["error"] == nil {
                    self.convertToStudentInformation(studentDataRaw!)
                    self.placePinsOnMap(StudentAPIClient.allStudents)
                } else if (studentDataRaw != nil && studentDataRaw![0]["error"] != nil) {
                    NSOperationQueue.mainQueue().addOperationWithBlock() {
                    self.mapView.hidden = true
                    let errorMessage = studentDataRaw![0]["error"] as! String
                        let alert = AlertBox.makeAlert("Data Error", message: errorMessage)
                    self.presentViewController(alert, animated: true, completion: nil)
                }
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
    
    @IBAction func segueToEnterLocation(sender: UIBarButtonItem) {
        performSegueWithIdentifier("mapGetLocation", sender: self)
    }
    
    private func placePinsOnMap(studentData: [StudentInformation]) {
        var annotations = [MKPointAnnotation]()
        
        for individualStudentData in studentData {
            let annotation = individualStudentData.createMapAnnotation()
            annotations.append(annotation)
        }
        
        // When the array is complete, we add the annotations to the map.
        self.mapView.addAnnotations(annotations)
    }
    
    @IBAction func refreshData(sender: UIBarButtonItem) {
        mapView.removeAnnotations(mapView.annotations)
        loadMap()
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.redColor()
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            if let toOpen = view.annotation?.subtitle! {
                app.openURL(NSURL(string: toOpen)!)
            }
        }
    }
    
}