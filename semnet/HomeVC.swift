//
//  HomeVC.swift
//  semnet
//
//  Created by ceyda on 17/12/16.
//  Copyright © 2016 celikel. All rights reserved.
//

import UIKit
import CarbonKit
import CoreLocation

class HomeVC: UIViewController, CarbonTabSwipeNavigationDelegate, CLLocationManagerDelegate {

    var items = NSArray()
    var carbonTabSwipeNavigation: CarbonTabSwipeNavigation = CarbonTabSwipeNavigation()
    
    var locationManager:CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        items = ["Friend", "Popular", "NearBy"]
        carbonTabSwipeNavigation = CarbonTabSwipeNavigation(items: items as [AnyObject], delegate: self)
        carbonTabSwipeNavigation.insert(intoRootViewController: self)
        self.style()
        
        self.navigationItem.title = "SemNet"
        self.navigationController?.title = "Home"
        
        style()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        ContentManager.sharedInstance.location = locations[0]
    }
    
    func style() {
        
        let color: UIColor = UIColor(red: 24.0 / 255, green: 75.0 / 255, blue: 152.0 / 255, alpha: 1)
        
        carbonTabSwipeNavigation.toolbar.isTranslucent = false
        carbonTabSwipeNavigation.setIndicatorColor(color)
        carbonTabSwipeNavigation.setTabExtraWidth(30)
        carbonTabSwipeNavigation.carbonSegmentedControl!.setWidth(screenWidth/3, forSegmentAt: 0)
        carbonTabSwipeNavigation.carbonSegmentedControl!.setWidth(screenWidth/3, forSegmentAt: 1)
        carbonTabSwipeNavigation.carbonSegmentedControl!.setWidth(screenWidth/3, forSegmentAt: 2)
        
        carbonTabSwipeNavigation.setNormalColor(UIColor.black.withAlphaComponent(0.6))
        carbonTabSwipeNavigation.setSelectedColor(color, font: UIFont.boldSystemFont(ofSize: 14))
    }
    
    func carbonTabSwipeNavigation(_ carbonTabSwipeNavigation: CarbonTabSwipeNavigation, viewControllerAt index: UInt) -> UIViewController {
       
        switch index {
        case 0:
            let view = self.storyboard!.instantiateViewController(withIdentifier: "AppHomeVC") as! AppHomeVC
            view.action = "FRIEND"
            return view
        case 1:
            let view = self.storyboard!.instantiateViewController(withIdentifier: "AppHomeVC") as! AppHomeVC
            view.action = "POPULAR"
            return view
        case 2:
            let view = self.storyboard!.instantiateViewController(withIdentifier: "AppHomeVC") as! AppHomeVC
            view.action = "LOCATION"
            return view
            
            
            
        default:
            let view = self.storyboard!.instantiateViewController(withIdentifier: "AppHomeVC") as! AppHomeVC
            
            
            return view
        }
    }
    
    
}
