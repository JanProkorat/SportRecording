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
    
    
    func storeDataOnCloud() {
        let favorite : String = self.IsFavorite == true ? "true" : "false"
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy hh:mm"
        var date = formatter.string(from: self.ActivityDate)
        let infoDictionary = [ "name" : self.Name, "location" : self.Location, "length" : self.Length, "activitydate" : date, "isfavorite" : favorite ]
        formatter.dateFormat = "ddMMyyyyhhmm"
        date = formatter.string(from: self.ActivityDate)
        let ref = Database.database().reference().child("Records").child("\(self.Name.replacingOccurrences(of: " ", with: "-"))_\(date)")
        ref.setValue(infoDictionary)
    }
    
    func deleteObjectFromCloud() {
        let formatter = DateFormatter()
        formatter.dateFormat = "ddMMyyyyhhmm"
        let date = formatter.string(from: self.ActivityDate)
        let ref = Database.database().reference()
        let x =  "\(self.Name.replacingOccurrences(of: " ", with: "-"))_\(date)"
        ref.child("Records").child(x).removeValue()
    }
    
    func updateActivity(newName: String?, newLocation: String?, newLength: String?, newActivityDate: Date?,newFavorite: Bool?) -> Bool {
        switch self.TypeOfStorage {
        case false:
            return updateRecordCoreData(newName: newName, newLocation: newLocation, newLength: newLength, newActivityDate: newActivityDate,newFavorite: newFavorite)
        case true:
            return updateRecordFirebase()
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
    
    private func updateRecordFirebase() -> Bool {
//        var postData = {
//            "name": self.Name,
//            "location": self.Location,
//            "length": self.Length,
//            "activitydate": self.ActivityDate,
//            "isfavorite": self.IsFavorite == true? "true" : "false"
//        };
//
//        // Get a key for a new Post.
//        var newPostKey = Database.database().reference().child("Records").key;
//
//        // Write the new post's data simultaneously in the posts list and the user's post list.
//        var updates = {};
//        updates['/posts/' + newPostKey] = postData;
//        updates['/user-posts/' + uid + '/' + newPostKey] = postData;
//
//        return firebase.database().ref().update(updates)
//        let formatter = DateFormatter()
//        formatter.dateFormat = "ddMMyyyyhhmm"
//        var date = formatter.string(from: self.ActivityDate)
//        Database.database().reference().child("/Records/" + "\(self.Name.replacingOccurrences(of: " ", with: "-"))_\(date)")
//        .set({ title: "New title", body: "This is the new body" });
        return false
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
