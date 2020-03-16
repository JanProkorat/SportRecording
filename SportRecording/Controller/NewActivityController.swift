//
//  NewActivityController.swift
//  SportRecording
//
//  Created by Jan Prokorát on 08/03/2020.
//  Copyright © 2020 Jan Prokorát. All rights reserved.
//

import UIKit
import CoreData

protocol DataSendDelegate {
    func transferRecord(data: Activity)
}

class NewActivityController: UIViewController{
    
    @IBOutlet weak var tf_name: UITextField!
    @IBOutlet weak var tf_location: UITextField!
    @IBOutlet weak var btn_setFavorite: UIButton!
    @IBOutlet weak var btn_save: UIButton!
    @IBOutlet weak var dp_length: UIDatePicker!
    @IBOutlet weak var sw_storageType: UISwitch!
    @IBOutlet weak var dp_activityDate: UIDatePicker!
    
    var activity : Activity!
    var isFavorite = false
    var delegate : DataSendDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setButtonBorder(button: btn_setFavorite, color: UIColor.systemYellow.cgColor)
        setButtonBorder(button: btn_save, color: UIColor.red.cgColor)
        btn_save.isEnabled = false
        btn_save.alpha = 0.2
        tf_name.addTarget(self, action:  #selector(textFieldDidChange(_:)),  for:.editingChanged )
        tf_location.addTarget(self, action:  #selector(textFieldDidChange(_:)),  for:.editingChanged )
    }
    
    func setButtonBorder(button: UIButton, color: CGColor){
        button.backgroundColor = .clear
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 1
        button.layer.borderColor = color
    }
    
    @objc func textFieldDidChange(_ sender: UITextField) {
        if tf_name.text == "" || tf_location.text == "" {
            btn_save.isEnabled = false;
            btn_save.alpha = 0.2
        }else{
             btn_save.isEnabled = true;
            btn_save.alpha = 1
        }
    }

    @IBAction func fovourite_Clicked(_ sender: Any) {
        if !isFavorite {
            isFavorite = true
            btn_setFavorite.setImage(UIImage(named: "star.fill"), for: .normal)
        } else {
            isFavorite = false
            btn_setFavorite.setImage(UIImage(named: "star"), for: .normal)
        }
    }
    
    @IBAction func save_Clicked(_ sender: Any) {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        activity = Activity(Name: tf_name.text!, Length: formatter.string(from: dp_length.date), Location: tf_location.text!, ActivityDate: dp_activityDate.date, TypeOfStorage: sw_storageType.isOn ? true : false, IsFavorite: isFavorite)
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        guard let recordEntity = NSEntityDescription.entity(forEntityName: "Record", in: managedContext) else { return }
        switch activity.TypeOfStorage {
            case false:
                activity.insertRecordToCoreData(entity: recordEntity, context: managedContext) ? displayMessage(message: "Activity record successfully saved") : displayMessage(message: "Could not save record")
            case true:
                activity.storeDataOnCloud()
            displayMessage(message: "Activity record successfully saved")
        }
        //delegate?.transferRecord(data: record)
        //performSegue(withIdentifier: "newRecordSegue", sender: self)
        tf_name.text = ""
        tf_location.text = ""
        isFavorite = false
        btn_save.isEnabled = false;
        btn_save.alpha = 0.2
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        let vc = segue.destination as! ViewController
//        vc.records.append(record)
//    }
    
    
    
    func displayMessage(message: String){
        let alertController = UIAlertController(title: "Result", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
}
