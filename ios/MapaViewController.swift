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
    
    let ref = Firebase(url:"https://dog-walker-app.firebaseio.com/users")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.locationManager.requestWhenInUseAuthorization()
        self.mapView.showsUserLocation = true
        
        // Define minha localizacao e centraliza o mapa nela
        let fiapLocation:CLLocationCoordinate2D  = CLLocationCoordinate2DMake(-23.550303, -46.634184)
        self.mapView.region = MKCoordinateRegionMakeWithDistance(fiapLocation, 1200, 1200)

        /*
        let ref = Firebase(url:"https://dog-walker-app.firebaseio.com/users")
        let usersRef = ref.childByAppendingPath("users")
        
        var users = ["alanisawesome": alanisawesome, "gracehop": gracehop]
        usersRef.setValue(users)
        */

        // Get a reference to our posts
        
        // Attach a closure to read the data at our posts reference
        self.ref.observeEventType(.Value, withBlock: { snapshot in
            //print(snapshot.value)

            // chama func para carregar users no mapa
            self.loadUsersOnMapView(snapshot.value!)
            
            // let title = snapshot.value.objectForKey("full_name") as? String
            // self.btnDebug.setTitle(title, forState: .Normal)
            
            }, withCancelBlock: { error in
                print(error.description)
        })

    }

    // teste para puxar localizacao atual e centralizar no mapa: 
    // http://stackoverflow.com/questions/25449469/swift-show-current-location-and-update-location-in-a-mkmapview
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [AnyObject]!) {
        let location = locations.last as! CLLocation
        
        print(location.coordinate.latitude)
        print(location.coordinate.longitude)
        
        let center = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        self.mapView.setRegion(region, animated: true)
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
        do {
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
                    
                    let userAnnotation: UserAnnotation = UserAnnotation(coordinate: CLLocationCoordinate2D(latitude: lat, longitude: long), title: u.name, subtitle: u.status, image: u.picture, user: u)

                    self.mapView.addAnnotation(userAnnotation)
                }
            }
        } catch {
            print("Erro no parser JSON")
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
                //trocar a imagem pelo logo do metro
                anView!.image = UIImage(named:"bluePin")
                //permitir que mostre o "balão" com informações da marcação
                anView!.canShowCallout = true
                //adiciona um botão do lado direito do balão
                anView!.rightCalloutAccessoryView = UIButton(type: UIButtonType.DetailDisclosure)
            }
            return anView
        }
        return nil
    }
}
