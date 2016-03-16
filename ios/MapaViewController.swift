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
        self.mapView.region = MKCoordinateRegionMakeWithDistance(baseLocation, 1200, 1200)

        // Get a reference to our posts
        
        // Attach a closure to read the data at our posts reference
        self.ref.observeEventType(.Value, withBlock: { snapshot in
            //print(snapshot.value)®

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

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("didUpdateLocations disparado")
        let location = locations.last! as CLLocation
        
        let center = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        self.mapView.setRegion(region, animated: true)
        
        // @TODO: buscar usuario atual logado...
        var user:User = User()
        user.uuid = "XPTO"
        
        let userPoint:UserAnnotation! = UserAnnotation(coordinate: center, title: "Eu", subtitle: "Sua localização atual", image: "userLogo", userUuid: user.uuid)

        self.mapView.addAnnotation(userPoint)
        
        // Stop updating location to save battery life
        locationManager.stopUpdatingLocation()
    }

    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl){
        if (view.annotation is UserAnnotation) {
            print("Vamos agendar o passeio, blz...")
        }
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        print("viewForAnnotation disparado")
        if annotation is UserAnnotation {
            print("porra!")
            let reuseId = "reuseUserAnnotation"
            var anView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
            if anView == nil {
                anView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
                anView!.image = UIImage(named: "userLogo")
                anView!.canShowCallout = true
                anView!.rightCalloutAccessoryView = UIButton(type: UIButtonType.DetailDisclosure)
            }
            return anView
        }
        print("putz!")
        return nil
    }

    // metodos de negocio
    
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
                //print(u.picture)

                let imgName:String = getImageNameByProfile(u.profile)
                //print(imgName)

                let userAnnotation: UserAnnotation = UserAnnotation(coordinate: CLLocationCoordinate2DMake(lat, long), title: u.name, subtitle: u.profile + " - " +  u.status, image: imgName, userUuid: u.uuid)
                
                self.mapView.addAnnotation(userAnnotation)
            }
        }
    }
    
    func getImageNameByProfile(profile: String) -> String {
        var imgName:String = ""

        switch profile {
        case "customer":
            imgName = "bluePin"
            print("Usuario comum. Imagem: \(imgName)")
        case "dogWalker":
            imgName = "userLogo"
            print("Usuario DogWalker. Imagem: \(imgName)")
        default:
            print("Usuario com o perfil nao tratado.")
        }

        return imgName
    }
}
