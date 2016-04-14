//
//  ViewController.swift
//  smap
//
//  Created by Lee, Marika on 4/9/16.
//  Copyright © 2016 Lee, Marika. All rights reserved.
//

import UIKit
import SwiftyJSON
import AFNetworking
import GoogleMaps

class ViewController: UIViewController {
    
    var directions = GoogleDirectionsRoute()
    
    
    var businesses: [Business]!
    
    //Mark: properties
    @IBOutlet var _originAddr: UITextField!
    @IBOutlet var _destAddr: UITextField!

    
    override func viewDidLoad() {
        
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func setDefaultDestination(sender: UIButton) {
        
        let service = "https://maps.googleapis.com/maps/api/directions/json"
        
        let originAddr = _originAddr.text!
        let destAddr = _destAddr.text!
        
        let urlString = ("\(service)?origin=\(originAddr)&destination=\(destAddr)&mode=driving&units=metric&sensor=true&key=AIzaSyC-LflNZIou4Lzdk8Wg_RM-MfvaWpqVdng").stringByReplacingOccurrencesOfString(" ", withString: "+")
        
        let directionsURL = NSURL(string: urlString)
        
        let request = NSMutableURLRequest(URL: directionsURL!)
        
        request.HTTPMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let operation = AFHTTPRequestOperation(request: request)
        operation.responseSerializer = AFJSONResponseSerializer()
        
        operation.setCompletionBlockWithSuccess({ (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) -> Void in
            
            if let result = responseObject as? NSDictionary {
                if let routes = result["routes"] as? [NSDictionary] {
                    
                    let routesJson = JSON(routes)
                    let points = routesJson[0]["overview_polyline"]["points"].stringValue
                    
                    //get the bounds lat/lon
                    let bound_northeast_lat = routesJson[0]["bounds"]["northeast"]["lat"].number!
                    let bound_northeast_lng = routesJson[0]["bounds"]["northeast"]["lng"].number!
                    let bound_southwest_lat = routesJson[0]["bounds"]["southwest"]["lat"].number!
                    let bound_southwest_lng = routesJson[0]["bounds"]["southwest"]["lng"].number!
                    let bounds:String? = String(bound_northeast_lat)+","+String(bound_northeast_lng)+"|"+String(bound_southwest_lat)+","+String(bound_southwest_lng)
                    print (bounds)
                    
                    Business.searchWithTerm("Thai", bounds: bounds!, sort: nil, categories: nil, deals: nil, completion: { (businesses: [Business]!, error: NSError!) -> Void in
                        self.businesses = businesses
                        
                        for business in businesses {
                            print (business)
                        }
                    })

                    
                    let path = GMSPath(fromEncodedPath: points)
                    
                    let camera = GMSCameraPosition.cameraWithLatitude(
                        (path?.coordinateAtIndex(0).latitude)!,
                        longitude: (path?.coordinateAtIndex(0).longitude)!,
                        zoom: 15)
                    
                    let mapView = GMSMapView.mapWithFrame(CGRectZero, camera: camera)
                    mapView.myLocationEnabled = true
                    self.view = mapView
                    
                    self.directions.drawOnMap(mapView, path: path)
                    self.directions.drawOriginMarkerOnMap(mapView, path: path)
                    self.directions.drawDestinationMarkerOnMap(mapView, path: path)
                    
                }
            }
            }) { (operation: AFHTTPRequestOperation!, error: NSError!)  -> Void in
                print("\(error)")
        }
        operation.start()
    }
}
