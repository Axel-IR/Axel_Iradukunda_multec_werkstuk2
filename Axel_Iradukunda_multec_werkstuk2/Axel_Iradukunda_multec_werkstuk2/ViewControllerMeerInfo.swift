//
//  ViewControllerMeerInfo.swift
//  Axel_Iradukunda_multec_werkstuk2
//
//  Created by student on 06/05/18.
//  Copyright © 2018 student. All rights reserved.
//

import UIKit
import CoreData

class ViewControllerMeerInfo: UIViewController {
    
    
    @IBOutlet weak var labelStatus: UILabel!
    @IBOutlet weak var labelFiesten: UILabel!
    @IBOutlet weak var Status: UILabel!
    @IBOutlet weak var stationNaam: UILabel!
    @IBOutlet weak var bikes: UIImageView!
    @IBOutlet weak var BeschkFietsen: UILabel!
    var naamfiestenstalling:String?
    let ManagedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    override func viewDidLoad() {
        super.viewDidLoad()
        /*print(naamfiestenstalling!)*/
        // Do any additional setup after loading the view.
        labelFiesten.text = NSLocalizedString("besckbareFietsen", comment: "")
        labelStatus.text = NSLocalizedString("status", comment: "")
        bikes.image = #imageLiteral(resourceName: "achtergrond")
        Gegeventonen()
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    /*"https://medium.com/kkempin/coredata-basics-xcode-9-swift-4-56a0fc1d40cb"*/
    func Gegeventonen(){
        
        DispatchQueue.main.async {
            let statn = NSFetchRequest<NSFetchRequestResult>(entityName: "Villo")
            statn.fetchLimit = 1
            
            statn.predicate = NSPredicate(format: "name == %@",  self.naamfiestenstalling!)
            
            do{
                
                let statns = try self.ManagedContext.fetch(statn)
                
                let geSelecteerdeStation:Villo = statns.first as! Villo
                
                
                let naam = geSelecteerdeStation.name!
                let beschikbarefietsen = geSelecteerdeStation.beschikbare_fietsen
                let status = geSelecteerdeStation.status!
                
                self.stationNaam.text = naam
                self.BeschkFietsen.text = "\(beschikbarefietsen)"
                self.Status.text = status
                
            }catch{
                print("error")
            }
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
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
