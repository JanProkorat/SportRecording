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
    
    static func retrieveRecordsLocalData(context: NSManagedObjectContext) -> [Activity] {
        var activities = [Activity]()
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
