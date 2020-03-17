//
//  ViewController.swift
//  SportRecording
//
//  Created by Jan Prokorát on 07/03/2020.
//  Copyright © 2020 Jan Prokorát. All rights reserved.
//

import UIKit
import CoreData
import Firebase

class ViewController: UIViewController, DataSendDelegate {
    
    var activities = [Activity]()
    
    var records = [Activity]()
    
    @IBOutlet weak var btn_NewActivity: UIButton!
    @IBOutlet weak var btn_PreviousActivities: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setButtonBorder(button: btn_NewActivity)
        setButtonBorder(button: btn_PreviousActivities)
        
    }

    func setButtonBorder(button: UIButton){
        button.backgroundColor = .clear
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "newRecordSegue"){
            let vc = segue.destination as! NewActivityController
            vc.delegate = self
        }
    }
    
    func transferRecord(data: Activity) {
//        records.append(data)
//        print("\(records.count)")
    }
    
    
}

