//
//  ViewController.swift
//  Axel_Iradukunda_multec_werkstuk2
//
//  Created by student on 30/04/18.
//  Copyright © 2018 student. All rights reserved.
//

import UIKit
import CoreData
import MapKit



class ViewController: UIViewController, MKMapViewDelegate {
    var opgehaaldeStations:[Villo] = []
    var locationManager = CLLocationManager()
    
    @IBOutlet weak var update: UILabel!
    
    
    let urlRequest=URLRequest(url:URL(string: "https://api.jcdecaux.com/vls/v1/stations?apiKey=6d5071ed0d0b3b68462ad73df43fd9e5479b03d6&contract=Bruxelles-Capitale")!)
    let urlSession=URLSession(configuration:URLSessionConfiguration.default)
    let managedContext = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    
    
    @IBOutlet weak var mijnMapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        update.text = NSLocalizedString("update", comment: " ")
        self.title = NSLocalizedString("TitleScherm", comment: "test")
        // Do any additional setup after loading the view, typically from a nib.
        locationManager.requestAlwaysAuthorization()
        
        locationManager.startUpdatingLocation()
        /*haalt de gegevens op,indien ze al opgehaald zijn worden ze getoond*/
        /*"https://stackoverflow.com/questions/27208103/detect-first-launch-of-ios-app?utm_medium=organic&utm_source=google_rich_qa&utm_campaign=google_rich_qa"*/
        let launch = UserDefaults.standard.bool(forKey: "launchbefore")
        if !launch{
            self.Ophalen()
        }else{
            self.Gegevenstonen()
        }
        
    }
    
    
    
    func Ophalen(){
        let task = urlSession.dataTask(with: urlRequest) {(data, response, error) in
            guard error == nil else{
                
                print("kon get functie niet aanroepen")
                print(error!)
                return
            }
            
            guard let responseData = data else {
                print("Error: geen data ontvangen")
                return
            }
            
            do{
                let villoData = try JSONSerialization.jsonObject(with: responseData, options: []) as? [AnyObject]
                
                for villo in villoData! {
                    DispatchQueue.main.async {
                        let stations = NSEntityDescription.insertNewObject(forEntityName: "Villo", into: self.managedContext!) as! Villo
                        
                        stations.number = (villo["number"] as? Int16)!
                        stations.name = villo["name"] as? String
                        stations.address = villo["address"] as? String!
                        stations.status = villo["status"] as? String!
                        stations.beschikbare_fietsen = (villo["available_bikes"] as? Int16)!
                        
                        var position=villo["position"] as? [String: Double]
                        stations.position = "\(position!["lat"]!) \(position!["lng"]!)"
                        /*  print(stations.position!)*/
                        do{
                            try self.managedContext?.save()
                        } catch{
                            fatalError("kon context niet opslaan: \(error)")
                        }
                    }
                    
                }
                self.Gegevenstonen()
                
            } catch {
                print(error)
            }
            
            
        }
        task.resume()
    }
    func Gegevenstonen(){
        DispatchQueue.main.async {
            let stationsFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Villo")
            
            do{
                self.opgehaaldeStations.removeAll()
                self.opgehaaldeStations = try self.managedContext?.fetch(stationsFetch) as! [Villo]
                
                
                for opgehaaldestation in self.opgehaaldeStations {
                    let annotation = MKPointAnnotation()
                    annotation.title = opgehaaldestation.name
                    
                    /*var namen:Array<String> = opgehaaldestation.name!.components(separatedBy: "/")
                    if namen.count == 2 {
                        namen[1] = namen[1].trimmingCharacters(in: .whitespaces)
                        annotation.title = NSLocalizedString("\(opgehaaldestation.number) - \(namen[1])", comment: "")
                        
                    }else{
                        annotation.title = namen[0]

                    }*/
                    
                    var coord:Array<String> = opgehaaldestation.position!.components(separatedBy: " ")
                    let lat: Double = Double(coord[0])!
                    let long: Double = Double(coord[1])!
                    
                    annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                    self.mijnMapView.addAnnotation(annotation)
                    /* self.mijnMapView.showAnnotations(self.mijnMapView.annotations, animated: true)*/
                    
                }
                
                
            } catch{fatalError("Failedtofetchemployees: \(error)")}
            
            
        }
        
        
    }
    /* "https://stackoverflow.com/questions/24658641/ios-delete-all-core-data-swift"*/
    func deleteAllData(entity: String){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.returnsObjectsAsFaults = false
        
        do
        {
            let results = try managedContext.fetch(fetchRequest)
            for managedObject in results
            {
                let managedObjectData:NSManagedObject = managedObject as! NSManagedObject
                managedContext.delete(managedObjectData)
            }
        } catch let error as NSError {
            print("Detele all data in \(entity) error : \(error) \(error.userInfo)")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        
        let center = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: center, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationview = mapView.dequeueReusableAnnotationView(withIdentifier: "annotation")
        if annotationview == nil{
            annotationview = MKAnnotationView(annotation: annotation, reuseIdentifier: "meerInfo")
            annotationview?.image = UIImage(named:"station")
            annotationview!.canShowCallout = true
            annotationview!.rightCalloutAccessoryView = UIButton(type: .infoDark)
            annotationview!.sizeToFit()
        }
        if let title = annotation.title, title == "Mijn locatie" || title == "Ma position"{
            annotationview=MKAnnotationView(annotation: annotation, reuseIdentifier: "gebruiker")
            annotationview?.image = UIImage(named:"gebruikerP")
            
        }
        annotationview?.canShowCallout = true
        return annotationview
    }
    
    //Bron: https://stackoverflow.com/questions/15270085/pass-data-between-view-controllers-without-segues
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let ViewControllerMeerInfo = self.storyboard?.instantiateViewController(withIdentifier: "ViewControllerMeerInfoID") as! ViewControllerMeerInfo
            ViewControllerMeerInfo.naamfiestenstalling = (view.annotation?.title)!
            self.navigationController?.pushViewController(ViewControllerMeerInfo, animated: true)
            
        }
    }
    /*"https://stackoverflow.com/questions/39513258/get-current-date-in-swift-3"*/
    func Tijd() -> String {
        let date = Date()
        let format=DateFormatter()
        format.dateFormat = "dd.MM.yyyy"
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        return "\(hour):\(minutes) \(format.string(from: date))"
    }
    @IBAction func refresh(_ sender: UIBarButtonItem) {
        update.text = NSLocalizedString("updateChange", comment: "") + "\(Tijd())"
        let allannotations=mijnMapView.annotations
        mijnMapView.removeAnnotations(allannotations)
        self.deleteAllData(entity: "Villo")
        Ophalen()
        
    }
    
}




