//
//  ActivityListTableViewController.swift
//  SportRecording
//
//  Created by Jan Prokorát on 15/03/2020.
//  Copyright © 2020 Jan Prokorát. All rights reserved.
//

import UIKit
import CoreData
import Firebase

class ActivityListTableViewController: UITableViewController {
    
    var activities = [Activity]()
    @IBOutlet weak var btn_typeOfStorage: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activities = Activity.retrieveRecordsLocalData()
    }
    
    @IBAction func typeOfStorage_Clicked(_ sender: Any) {
        switch btn_typeOfStorage.title {
        case "Firebase":
            retrieveDataFirebase()
            btn_typeOfStorage.title = "Core data"
            break
        case "Core data":
            activities = Activity.retrieveRecordsLocalData()
            tableView.reloadData()
            btn_typeOfStorage.title = "Firebase"
            break
        default:
            break
        }
    }
    
    func retrieveDataFirebase(){
        let ref = Database.database().reference()
        ref.child("Records").observe(.value, with: {
            snapshot in
            var localActivities = [Activity]()
            let value = snapshot.value as? NSDictionary
            for (_, subdict) in value! {
                let recordDataDict = subdict as? NSDictionary
                let formatter = DateFormatter()
                formatter.dateFormat = "dd.MM.yyyy hh:mm"
                let date = formatter.date(from: recordDataDict?["activitydate"] as! String)
                localActivities.append(Activity(Name: recordDataDict?["name"] as! String, Length: recordDataDict?["length"] as! String, Location: recordDataDict?["location"] as! String, ActivityDate: date!, TypeOfStorage: true, IsFavorite: recordDataDict?["isfavorite"] as! String == "true" ? true : false))
            }
            self.activities = localActivities
            self.tableView.reloadData()
        })
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if activities.count == 0 {
            tableView.setEmptyView(title: "No data to display.", message: "Your activities will be in here.")
        }else {
            tableView.restore()
        }
        return activities.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = (tableView.dequeueReusableCell(withIdentifier: ActivityTableViewCell.reuseIdentifier, for: indexPath) as! ActivityTableViewCell)
        let activity = activities[indexPath.row]
        cell.lb_name?.text = activity.Name
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy hh:mm"
        cell.lb_date?.text = formatter.string(from: activity.ActivityDate )
        cell.lb_location?.text = activity.Location
        return cell
    }
    
    
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
         if editingStyle == .delete {
            let activity = activities[indexPath.row]
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            let context = appDelegate.persistentContainer.viewContext
            Activity.deleteRecordFromCoreData(activity: activity, context: context)
            activities.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
         }
     }
     

}

extension UITableView {
    func setEmptyView(title: String, message: String) {
        let emptyView = UIView(frame: CGRect(x: self.center.x, y: self.center.y, width: self.bounds.size.width, height: self.bounds.size.height))
        let titleLabel = UILabel()
        let messageLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = UIColor.black
        titleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
        messageLabel.textColor = UIColor.lightGray
        messageLabel.font = UIFont(name: "HelveticaNeue-Regular", size: 17)
        emptyView.addSubview(titleLabel)
        emptyView.addSubview(messageLabel)
        titleLabel.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
        messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20).isActive = true
        messageLabel.leftAnchor.constraint(equalTo: emptyView.leftAnchor, constant: 20).isActive = true
        messageLabel.rightAnchor.constraint(equalTo: emptyView.rightAnchor, constant: -20).isActive = true
        titleLabel.text = title
        messageLabel.text = message
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        // The only tricky part is here:
        self.backgroundView = emptyView
        self.separatorStyle = .none
    }
    func restore() {
        self.backgroundView = nil
        self.separatorStyle = .singleLine
    }
}
