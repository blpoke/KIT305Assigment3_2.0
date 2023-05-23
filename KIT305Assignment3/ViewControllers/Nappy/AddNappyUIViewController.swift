//
//  AddNappyUIViewController.swift
//  KIT305Assignment3
//
//  Created by Broderick Poke on 23/5/2023.
//

import SwiftUI
import Firebase
import FirebaseFirestore

class AddNappyUIViewController: UIViewController {
    
    var nappy: Nappy?
    var nappyIndex: Int?
    let db = Firestore.firestore()

    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var dirtySwitch: UISwitch!
    @IBOutlet weak var noteField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

    // MARK: - Navigation
    
    @IBAction func onSave(_ sender: Any) {
        let nappyCollection = self.db.collection("nappies")
        
        var dirty: Bool
        
        if(dirtySwitch.isOn == true)
        {
            dirty = true
        }
        else
        {
            dirty = false
        }
        
        nappy = Nappy(
                dateTime: Timestamp(date: datePicker.date),
                dirty: dirty,
                note: noteField.text!)
        
        do
        {
            //update the database (code from lectures)
            let nappyData = try Firestore.Encoder().encode(nappy)
            nappyCollection.addDocument(data: nappyData){ err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    print("Nappy successfully added")
                    //this code triggers the unwind segue manually
                    self.performSegue(withIdentifier: "AddNappySegue", sender: sender)
                }
            }
        } catch { print("Error adding document \(error)") } //note "error" is a magic variable
        
        
    }
    

}
