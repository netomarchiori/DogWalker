//
//  MapaViewController.swift
//  Dog Walker
//
//  Created by Usuário Convidado on 15/03/16.
//  Copyright © 2016 FIAP. All rights reserved.
//

import UIKit
import MapKit
import Firebase

class MapaViewController: UIViewController, MKMapViewDelegate{

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var btnDebug: UIButton!
    
    let locationManager: CLLocationManager = CLLocationManager()
    
    let ref2 = Firebase(url:"https://dog-walker-app.firebaseio.com/users/alanisawesome")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.locationManager.requestWhenInUseAuthorization()
        self.mapView.showsUserLocation = true
        
        
        let ref = Firebase(url:"https://dog-walker-app.firebaseio.com")
        
        let alanisawesome = ["full_name": "Gustavo Melki", "date_of_birth": "June 23, 1912", "location": "-2111"]
        let gracehop = ["full_name": "Grace Hopper", "date_of_birth": "December 9, 1906"]
        
        let usersRef = ref.childByAppendingPath("users")
        
        var users = ["alanisawesome": alanisawesome, "gracehop": gracehop]
        usersRef.setValue(users)
        
        // Get a reference to our posts
        
        // Attach a closure to read the data at our posts reference
            self.ref2.observeEventType(.Value, withBlock: { snapshot in
            print(snapshot.value)
            let title = snapshot.value.objectForKey("full_name") as? String
            self.btnDebug.setTitle(title, forState: .Normal)
            
            }, withCancelBlock: { error in
                print(error.description)
        })
        
        
    }

    override func viewDidDisappear(animated: Bool) {
        
        let handle = ref2.observeEventType(.Value, withBlock: { snapshot in
            print("Snapshot value: \(snapshot.value)")
            
        })
        
        ref2.removeObserverWithHandle(handle)
        

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
