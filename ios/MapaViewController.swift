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

class MapaViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var btnDebug: UIButton!
    
    let locationManager: CLLocationManager = CLLocationManager()
    
    let ref = Firebase(url:"https://dog-walker-app.firebaseio.com")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.locationManager.requestWhenInUseAuthorization()
        self.mapView.showsUserLocation = true
        self.locationManager.delegate = self
        self.locationManager.startUpdatingLocation()
        
        let location = self.locationManager.location
        let latitude: Double = (location?.coordinate.latitude)!
        let longitude: Double = (location?.coordinate.longitude)!
        
        // Define minha localizacao e centraliza o mapa nela
        let baseLocation:CLLocationCoordinate2D  = CLLocationCoordinate2DMake(latitude, longitude)
        self.mapView.region = MKCoordinateRegionMakeWithDistance(baseLocation, 2400, 2400)

        // Get a reference to our posts
        
        // Attach a closure to read the data at our posts reference
        self.ref.observeEventType(.Value, withBlock: { snapshot in
            //print(snapshot.value)

            // Adiciona users no mapa
            self.loadUsersOnMapView(snapshot.value!)
            
            // let title = snapshot.value.objectForKey("full_name") as? String
            // self.btnDebug.setTitle(title, forState: .Normal)
            
            }, withCancelBlock: { error in
                print(error.description)
        })

    }
    
    override func viewDidDisappear(animated: Bool) {
        
        let handle = ref.observeEventType(.Value, withBlock: { snapshot in
            print("Snapshot value: \(snapshot.value)")
            
        })
        
        ref.removeObserverWithHandle(handle)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func loadUsersOnMapView(json: AnyObject) {
            if let users = json["users"] as? [[String: AnyObject]] {
                for user in users {

                var u:User = User()
                u.uuid = (user["uuid"] as? String)!
                u.name = (user["name"] as? String)!
                u.email = (user["email"] as? String)!
                u.cellphone = (user["cellphone"] as? String)!
                u.picture = (user["picture"] as? String)!
                u.description = (user["description"] as? String)!
                u.location = (user["location"] as? String)!
                u.rating = (user["rating"] as? String)!
                u.profile = (user["profile"] as? String)!
                u.status = (user["status"] as? String)!

                var locationArr = u.location.componentsSeparatedByString(",")
                let lat: Double! = Double(locationArr[0])
                let long: Double! = Double(locationArr[1])
                    
                //print(lat!)
                //print(long!)

                let userAnnotation: UserAnnotation = UserAnnotation(coordinate: CLLocationCoordinate2D(latitude: lat, longitude: long), title: u.profile + " - " +  u.name, subtitle: u.status, image: u.picture, user: u)

                self.mapView.addAnnotation(userAnnotation)
            }
        }
    }

    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if (annotation is UserAnnotation) {
            //verificar se a marcação já existe para tentar reutilizá-la
            let reuseId = "reuseUserAnnotation"
            var anView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
            //se a view não existir
            if (anView == nil) {
                //criar a view como subclasse de MKAnnotationView
                anView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
                //trocar a imagem pelo logo dogWalker ou usuario normal (que contrata um passeio)
                
                let userAnnotation: UserAnnotation = anView!.annotation! as! UserAnnotation
                //anView!.image = UIImage(named:"bluePin")
                print("Foto: \((userAnnotation.user?.picture)!)")
                anView!.image = loadUIImage((userAnnotation.user?.picture)!)
                //permitir que mostre o "balão" com informações da marcação
                anView!.canShowCallout = true
                //adiciona um botão do lado direito do balão
                anView!.rightCalloutAccessoryView = UIButton(type: UIButtonType.DetailDisclosure)
            }
            return anView
        }
        return nil
    }

    func loadUIImage(imagem: String) -> UIImage {
        let url = NSURL(string:imagem)
        let data: NSData = NSData(contentsOfURL:url!)!
        return UIImage(data:data)!
    }
}
