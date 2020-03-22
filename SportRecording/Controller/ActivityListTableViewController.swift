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

class ActivityListTableViewController: UITableViewController, UpdateTableDelegate {
    
    var activities = [[Activity]]()
    //var indicator = UIActivityIndicatorView()
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()
        indicator.startAnimating()
        retrieveData()
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        tableView.reloadData()
//    }
    
    func retrieveData(){
        let ref = Database.database().reference()
        ref.child("Records").observe(.value, with: {
            snapshot in
            var cloudActivities = [Activity]()
            let value = snapshot.value as? NSDictionary
            if value != nil {
                for (_, subdict) in value! {
                    let recordDataDict = subdict as? NSDictionary
                    let formatter = DateFormatter()
                    formatter.dateFormat = "dd.MM.yyyy hh:mm"
                    let date = formatter.date(from: recordDataDict?["activitydate"] as! String)
                    cloudActivities.append(Activity(Name: recordDataDict?["name"] as! String, Length: recordDataDict?["length"] as! String, Location: recordDataDict?["location"] as! String, ActivityDate: date!, TypeOfStorage: true, IsFavorite: recordDataDict?["isfavorite"] as! String == "true" ? true : false))
                }
            }
            let localActivities = Activity.retrieveRecordsLocalData()
            self.activities.append(localActivities.sorted(by: { ($0.ActivityDate).compare($1.ActivityDate) == .orderedDescending }))
            self.activities.append(cloudActivities.sorted(by: { ($0.ActivityDate).compare($1.ActivityDate) == .orderedDescending }))
            for i in 0...self.activities.count-1{
                self.activities[i].sort(by: {
                    $0.IsFavorite && !$1.IsFavorite
                })
            }
            //self.indicator.stopAnimating()
            self.indicator.isHidden = true
            self.tableView.reloadData()
        })
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return activities.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if activities.count == 0 {
            tableView.setEmptyView(title: "No data to display.", message: "Your activities will be in here.")
        }else {
            tableView.restore()
        }
        return activities[section].count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = (tableView.dequeueReusableCell(withIdentifier: ActivityTableViewCell.reuseIdentifier, for: indexPath) as! ActivityTableViewCell)
        let activity = activities[indexPath.section][indexPath.row]
        cell.lb_name?.text = activity.Name
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy hh:mm"
        cell.lb_date?.text = formatter.string(from: activity.ActivityDate )
        cell.lb_location?.text = activity.Location
        if activity.IsFavorite {
            cell.btn_isFavorite.setImage(UIImage(systemName: "star.fill"), for: .normal)
        }
        return cell
    }
    
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
         if editingStyle == .delete {
            let activity = activities[indexPath.section][indexPath.row]
            switch activity.TypeOfStorage {
            case true:
                activity.deleteObjectFromCloud()
            case false:
                guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
                let context = appDelegate.persistentContainer.viewContext
                Activity.deleteRecordFromCoreData(activity: activity, context: context)
                break
            }
            activities[indexPath.section].remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
         }
     }
     
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var sectionName : String = ""
        switch section {
        case 0:
            sectionName = "Local data"
            break
        case 1:
            sectionName = "Cloud data"
            break
        default:
            break
        }
        return sectionName
    }
    
    @IBAction func btn_favorite_Clicked(_ sender: UIButton) {
        guard let cell = (sender as AnyObject).superview?.superview as? ActivityTableViewCell else {
            return // or fatalError() or whatever
        }
        let indexPath = tableView.indexPath(for: cell)
        let activity = activities[indexPath!.section][indexPath!.row]
        if !activity.updateActivity(newName: nil, newLocation: nil, newLength: nil, newActivityDate: nil, newFavorite: !activity.IsFavorite) {
            let alertController = UIAlertController(title: title, message: "Could not update record.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
        switch activity.IsFavorite {
        case true:
            cell.btn_isFavorite.setImage(UIImage(systemName: "star.fill"), for: .normal)
            break
        case false:
            cell.btn_isFavorite.setImage(UIImage(systemName: "star"), for: .normal)
            break
        }
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is ActivityDetailController
        {
            let vc = segue.destination as? ActivityDetailController
            vc?.activityToDisplay = activities[tableView.indexPathForSelectedRow!.section][tableView.indexPathForSelectedRow!.row]
            vc?.delegate = self
        }
    }
    
    func updateTableView() {
        self.tableView.reloadData()
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
