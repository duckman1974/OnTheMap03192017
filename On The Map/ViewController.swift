//
//  ViewController.swift
//  On The Map
//
//  Created by Candice Reese on 3/11/17.
//  Copyright © 2017 Kevin Reese. All rights reserved.
//

import UIKit
import MapKit
import Foundation


class ViewController: UIViewController, MKMapViewDelegate {

    
    @IBOutlet weak var mapView: MKMapView!

    @IBOutlet weak var logOutButton: UIBarButtonItem!
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    
    @IBAction func logOut(_ sender: Any) {
        
        dismiss(animated: true, completion: {
            UdacityClient.sharedInstance().logoutSession()
        })
        
    }
    
        
        
    }




