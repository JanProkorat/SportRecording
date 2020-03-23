//
//  Record.swift
//  SportRecording
//
//  Created by Jan Prokorát on 07/03/2020.
//  Copyright © 2020 Jan Prokorát. All rights reserved.
//

import Foundation
import CoreData
import Firebase

class Activity {
    
    private(set) var Name: String
    private(set) var Length: String
    private(set) var Location: String
    private(set) var ActivityDate: Date
    private(set) var TypeOfStorage: Bool
    private(set) var IsFavorite: Bool
    
    init(Name: String, Length: String, Location: String, ActivityDate: Date, TypeOfStorage: Bool, IsFavorite: Bool) {
        self.Name = Name
        self.Length = Length
        self.Location = Location
        self.ActivityDate = ActivityDate
        self.TypeOfStorage = TypeOfStorage
        self.IsFavorite = IsFavorite
    }

    init(){
        self.Name = ""
        self.Length = ""
        self.Location = ""
        self.ActivityDate = Date()
        self.TypeOfStorage = false
        self.IsFavorite = false
    }
    
    func insertRecordToCoreData(entity: NSEntityDescription, context: NSManagedObjectContext) -> Bool {
        let record = NSManagedObject(entity: entity, insertInto: context)
        record.setValue(self.Name, forKeyPath: "name")
        record.setValue(self.Location, forKeyPath: "location")
        record.setValue(self.Length, forKeyPath: "length")
        record.setValue(self.ActivityDate, forKeyPath: "activitydate")
        record.setValue(self.IsFavorite, forKeyPath: "isfavorite")
        
        do {
            try context.save()
            return true
           
        } catch  {
            return false
        }
    }
    
    
    func storeDataOnCloud(newName: String?, newLocation: String?, newLength: String?, newActivityDate: Date?, newFavorite: Bool?) {
        var favorite : String
        let formatter = DateFormatter()
        var date : String
        formatter.dateFormat = "dd.MM.yyyy hh:mm"
        var infoDictionary = [String: Any]()
        var ref : DatabaseReference
        if newName == nil {
            favorite = self.IsFavorite == true ? "true" : "false"
            date = formatter.string(from: self.ActivityDate)
            infoDictionary = [ "name" : self.Name, "location" : self.Location, "length" : self.Length, "activitydate" : date, "isfavorite" : favorite ]
            formatter.dateFormat = "ddMMyyyyhhmm"
            date = formatter.string(from: self.ActivityDate)
            ref = Database.database().reference().child("Records").child("\(self.Name.replacingOccurrences(of: " ", with: "-"))_\(date)")
        }else{
            favorite = newFavorite == true ? "true" : "false"
            date = formatter.string(from: newActivityDate!)
            infoDictionary = [ "name" : newName!, "location" : newLocation!, "length" : newLength!, "activitydate" : date, "isfavorite" : favorite ]
            formatter.dateFormat = "ddMMyyyyhhmm"
            date = formatter.string(from: newActivityDate!)
            ref = Database.database().reference().child("Records").child("\(newName!.replacingOccurrences(of: " ", with: "-"))_\(date)")
        }
        ref.setValue(infoDictionary)
    }
    
    func deleteObjectFromCloud() {
        let formatter = DateFormatter()
        formatter.dateFormat = "ddMMyyyyhhmm"
        let date = formatter.string(from: self.ActivityDate)
        let ref = Database.database().reference()
        ref.child("Records").child("\(self.Name.replacingOccurrences(of: " ", with: "-"))_\(date)").removeValue()
    }
    
    func updateActivity(newName: String?, newLocation: String?, newLength: String?, newActivityDate: Date?,newFavorite: Bool?) -> Bool {
        switch self.TypeOfStorage {
        case false:
            return updateRecordCoreData(newName: newName, newLocation: newLocation, newLength: newLength, newActivityDate: newActivityDate,newFavorite: newFavorite)
        case true:
            return updateRecordOnCloud(newName: newName, newLocation: newLocation, newLength: newLength, newActivityDate: newActivityDate,newFavorite: newFavorite)
        }
    }
    
    private func updateRecordCoreData(newName: String?, newLocation: String?, newLength: String?, newActivityDate: Date?, newFavorite: Bool?) -> Bool {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return false }
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Record")
        let namePredicate = NSPredicate(format:"name = %@", self.Name)
        let datePredicate = NSPredicate(format:"activitydate = %@", self.ActivityDate as NSDate)
        let andPredicate = NSCompoundPredicate(type: .and, subpredicates: [namePredicate, datePredicate])
        fetchRequest.predicate = andPredicate
        do
         {
            let test = try context.fetch(fetchRequest)
            let record = test[0] as! NSManagedObject
            record.setValue(newName == nil ? self.Name : newName, forKeyPath: "name")
            record.setValue(newLocation == nil ? self.Location : newLocation, forKeyPath: "location")
            record.setValue(newLength == nil ? self.Length : newLength, forKeyPath: "length")
            record.setValue(newActivityDate == nil ? self.ActivityDate : newActivityDate, forKeyPath: "activitydate")
            record.setValue(newFavorite == nil ? self.IsFavorite : newFavorite, forKeyPath: "isfavorite")
                do{
                     try context.save()
                 }
                 catch
                 {
                     print(error)
                    return false
                 }
             }
         catch
         {
             print(error)
            return false
         }
        self.Name = newName != nil ? newName! : self.Name
        self.Location = newLocation != nil ? newLocation! : self.Location
        self.Length = newLength != nil ? newLength! : self.Length
        self.ActivityDate = newActivityDate != nil ? newActivityDate! : self.ActivityDate
        self.IsFavorite = newFavorite != nil ? newFavorite! : self.IsFavorite
        return true
    }
    
    private func updateRecordOnCloud(newName: String?, newLocation: String?, newLength: String?, newActivityDate: Date?, newFavorite: Bool?) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "ddMMyyyyhhmm"
        let date = formatter.string(from: self.ActivityDate)
        formatter.dateFormat = "dd.MM.yyyy hh:mm"
        let dateAgain = formatter.string(from: self.ActivityDate)
        if newName == nil && newLength == nil && newLocation == nil && newActivityDate == nil && newFavorite != nil {
            Database.database().reference().child("Records").child("\(self.Name.replacingOccurrences(of: " ", with: "-"))_\(date)").updateChildValues([ "isfavorite" : newFavorite! ? "true" : "false"])
            self.IsFavorite = !self.IsFavorite
            return true
        }
        if newName == self.Name && newActivityDate == self.ActivityDate {
            Database.database().reference().child("Records").child("\(self.Name.replacingOccurrences(of: " ", with: "-"))_\(date)").updateChildValues(["name" : newName!, "location" : newLocation!, "length" : newLength!, "isfavorite" : newFavorite! ? "true" : "false", "activitydate" : dateAgain])
        }else{
            storeDataOnCloud(newName: newName, newLocation: newLocation, newLength: newLength, newActivityDate: newActivityDate, newFavorite: newFavorite)
            deleteObjectFromCloud()
            self.Name = newName!
            self.ActivityDate = newActivityDate!
        }
        self.Location = newLocation!
        self.Length = newLength!
        self.IsFavorite = newFavorite!
        return true
    }
    
    static func deleteRecordFromCoreData(activity: Activity, context: NSManagedObjectContext) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Record")

        let namePredicate = NSPredicate(format:"name = %@", activity.Name)
        let datePredicate = NSPredicate(format:"activitydate = %@", activity.ActivityDate as NSDate)
        let andPredicate = NSCompoundPredicate(type: .and, subpredicates: [namePredicate, datePredicate])
        request.predicate = andPredicate

        let result = try? context.fetch(request)
        let resultData = result as! [NSManagedObject]

        for object in resultData {
            context.delete(object)
        }

        do {
            try context.save()
        } catch let error as NSError  {
            print("Could not delete \(error), \(error.userInfo)")
        } catch {
        }
    }
    
    static func retrieveRecordsLocalData() -> [Activity] {
        var activities = [Activity]()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let context = appDelegate!.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Record")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

        do {
            let result = try context.fetch(fetchRequest)
            var activity : Activity
            for data in result as! [NSManagedObject] {
                activity = Activity()
                activity.Name = data.value(forKey: "name") as! String
                activity.Length = data.value(forKey: "length") as! String
                activity.Location = data.value(forKey: "location") as! String
                activity.ActivityDate = data.value(forKey: "activitydate") as! Date
                activity.IsFavorite = data.value(forKey: "isfavorite") as! Bool
                activities.append(activity)
            }
        } catch let error as NSError {
            print("Could not retrieve data. \(error), \(error.userInfo)")
        }
        return activities
    }
    
    
}
