//
//  ActivityDetailController.swift
//  SportRecording
//
//  Created by Jan Prokorát on 18/03/2020.
//  Copyright © 2020 Jan Prokorát. All rights reserved.
//

import UIKit

protocol UpdateTableDelegate {
    func updateTableView()
}

class ActivityDetailController: UIViewController {

    @IBOutlet weak var tf_name: UITextField!
    @IBOutlet weak var tf_location: UITextField!
    @IBOutlet weak var dp_activityDate: UIDatePicker!
    @IBOutlet weak var dp_length: UIDatePicker!
    @IBOutlet weak var sw_favorite: UISwitch!
    @IBOutlet weak var btn_save: UIButton!
    @IBOutlet weak var btn_edit: UIButton!
    
    var activityToDisplay = Activity()
    var delegate : UpdateTableDelegate?
    
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
        
        tf_name.addTarget(self, action:  #selector(textFieldDidChange(_:)),  for:.editingChanged )
        tf_location.addTarget(self, action:  #selector(textFieldDidChange(_:)),  for:.editingChanged )
        
        initLoad()
        enableUserInteraction(enable: false)
    }
    
    func initLoad(){
        btn_save.backgroundColor = .clear
        btn_save.layer.cornerRadius = 5
        btn_save.layer.borderWidth = 1
        btn_save.layer.borderColor = UIColor.systemRed.cgColor
        btn_edit.backgroundColor = .clear
        btn_edit.layer.cornerRadius = 5
        btn_edit.layer.borderWidth = 1
        btn_edit.layer.borderColor = UIColor.systemBlue.cgColor
        
        tf_name.text = activityToDisplay.Name
        tf_location.text = activityToDisplay.Location
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm"
        if dateFormatter.date(from: activityToDisplay.Length) == nil {
            dateFormatter.dateFormat = "hh:mm a"
        }
        dp_length.date = dateFormatter.date(from: activityToDisplay.Length)!
        dp_activityDate.date = activityToDisplay.ActivityDate
        sw_favorite.isOn = activityToDisplay.IsFavorite
    }
    
    func enableUserInteraction(enable: Bool){
        switch enable {
        case false:
            tf_name.isEnabled = false
            tf_location.isEnabled = false
            dp_activityDate.isEnabled = false
            dp_length.isEnabled = false
            sw_favorite.isEnabled = false
            btn_save.isHidden = true
            break
        case true:
            tf_name.isEnabled = true
            tf_location.isEnabled = true
            dp_activityDate.isEnabled = true
            dp_length.isEnabled = true
            sw_favorite.isEnabled = true
            btn_save.isHidden = false
            break
        }
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

    @IBAction func edit_Clicked(_ sender: Any) {
        switch btn_edit.currentTitle {
        case "Edit":
            btn_edit.setTitle("Cancel",for: .normal)
            enableUserInteraction(enable: true)
            break
        case "Cancel":
            initLoad()
            enableUserInteraction(enable: false)
            btn_edit.setTitle("Edit",for: .normal)
            break
        default:
            break
        }
        
    }
    
    @IBAction func save_Clicked(_ sender: Any) {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm"
        let length = formatter.string(from: dp_length.date )
        if !activityToDisplay.updateActivity(newName: tf_name.text, newLocation: tf_location.text, newLength: length, newActivityDate: dp_activityDate.date, newFavorite: sw_favorite.isOn) {
            let alertController = UIAlertController(title: title, message: "Could not update record.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }else{
            delegate?.updateTableView()
            dismiss(animated: true, completion: nil)
        }
    }
}
