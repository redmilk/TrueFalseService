//
//  AppDelegate.swift
//  OneMoreInstagramKFR
//
//  Created by Artem on 4/28/17.
//  Copyright © 2017 ApiqA. All rights reserved.
//

import UIKit
import Firebase

var ref: FIRDatabaseReference!
var storage: FIRStorageReference!

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    var container: UIView!
    //MARK: - did finish launching with options
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        FIRApp.configure()
        storage = FIRStorage.storage().reference(forURL: "gs://triviakfr.appspot.com/")
        ref = FIRDatabase.database().reference()
        
        return true
    }
 
    class func instance() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    func setupGradient(gradient: CAGradientLayer, viewForGradient: UIView, color: UIColor) {
        gradient.colors = [color.cgColor, UIColor.white.cgColor]
        gradient.locations = [0.0 , 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradient.frame = CGRect(x: 0.0, y: 0.0, width: viewForGradient.frame.size.width, height: viewForGradient.frame.size.height)
        gradient.zPosition = -10
        viewForGradient.layer.addSublayer(gradient)
    }
    
    func showActivityIndicator() {
        if let window = window {
            self.container = UIView()
            self.container.frame = window.frame
            self.container.center = window.center
            self.container.backgroundColor = UIColor(white: 0, alpha: 0.8)
            
            self.activityIndicator.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            self.activityIndicator.hidesWhenStopped = true
            self.activityIndicator.center = CGPoint(x: self.container.frame.size.width/2, y: self.container.frame.size.height/2)
            
            self.container.addSubview(self.activityIndicator)
            self.window?.addSubview(self.container)
            
            self.activityIndicator.startAnimating()
        }
    }

    func dismissActivityIndicator() {
        if let _ = self.window {
            self.container.removeFromSuperview()
        }
    }
}

