//
//  NewActivityController.swift
//  SportRecording
//
//  Created by Jan Prokorát on 08/03/2020.
//  Copyright © 2020 Jan Prokorát. All rights reserved.
//

import UIKit
import CoreData


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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        let blurEffect = UIBlurEffect(style: .extraLight)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(blurView, at: 0)
        NSLayoutConstraint.activate([
        blurView.heightAnchor.constraint(equalTo: view.heightAnchor),
        blurView.widthAnchor.constraint(equalTo: view.widthAnchor),
        ])
        
        setButtonBorder(button: btn_setFavorite, color: UIColor.systemYellow.cgColor)
        setButtonBorder(button: btn_save, color: UIColor.red.cgColor)
        btn_save.isEnabled = false
        btn_save.alpha = 0.2
        tf_name.addTarget(self, action:  #selector(textFieldDidChange(_:)),  for:.editingChanged )
        tf_location.addTarget(self, action:  #selector(textFieldDidChange(_:)),  for:.editingChanged )
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
        isFavorite = !isFavorite
        if isFavorite {
            btn_setFavorite.setImage(UIImage(systemName: "star.fill"), for: .normal)
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
                activity.storeDataOnCloud(newName: nil, newLocation: nil, newLength: nil, newActivityDate: nil, newFavorite: nil)
            displayMessage(message: "Activity record successfully saved")
        }
        resetControls()
    }
    
    private func setButtonBorder(button: UIButton, color: CGColor){
        button.backgroundColor = .clear
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 1
        button.layer.borderColor = color
    }
    
    private func resetControls(){
        tf_name.text = ""
        tf_location.text = ""
        isFavorite = false
        dp_activityDate.date = Date()
        dp_length.date = Date()
        btn_save.isEnabled = false;
        btn_save.alpha = 0.2
    }
    
    private func displayMessage(message: String){
        let alertController = UIAlertController(title: "Result", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
}
