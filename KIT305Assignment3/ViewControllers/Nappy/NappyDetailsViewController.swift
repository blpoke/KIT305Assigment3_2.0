//
//  NappyDetailsViewController.swift
//  KIT305Assignment3
//
//  Created by mobiledev on 16/5/2023.
//

import SwiftUI
import Firebase
import FirebaseFirestore

class NappyDetailsViewController: UIViewController {

    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var dirtySwitch: UISwitch!
    @IBOutlet var noteField: UITextField!
    @IBOutlet var saveButton: UIButton!
    @IBOutlet var deleteButton: UIButton!
    
    var nappy : Nappy?
    var nappyIndex : Int?
    let db = Firestore.firestore()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        print("\nShould be able to see this\n")
        
        if let displayNappy = nappy
        {
            let timestampValue = displayNappy.dateTime.seconds
            let timeInterval = TimeInterval(timestampValue)
            let date = Date(timeIntervalSince1970: timeInterval)
            
            datePicker.date = date
            print(date)
            if(displayNappy.dirty == true)
            {
                dirtySwitch.isOn = true
            }
            else
            {
                dirtySwitch.isOn = false
            }
            noteField.text = displayNappy.note
        }
    }
    

    // MARK: - Navigation

    @IBAction func onNappySave(_ sender: Any) {

        //assign nappy values from details form
        nappy!.dateTime = Timestamp(date: datePicker.date)
        
        if(dirtySwitch.isOn == true)
        {
            nappy!.dirty = true
        }
        else
        {
            nappy!.dirty = false
        }
        
        nappy!.note = noteField.text!
       
        do
        {
            //update the database (code from lectures)
            try db.collection("nappies").document(nappy!.documentID!).setData(from: nappy!){ err in
                if let err = err {
                    print("Error updating document: \(err)")
                } else {
                    print("Document successfully updated")
                    //this code triggers the unwind segue manually
                    self.performSegue(withIdentifier: "saveNappySegue", sender: sender)
                }
            }
        } catch { print("Error updating document \(error)") } //note "error" is a magic variable
    }
    
    @IBAction func onNappyDelete(_ sender: Any) {
        let alertController = UIAlertController(title: "Confirm Deletion", message: "Are you sure you want to delete this item?", preferredStyle: .alert)
            
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            do
            {
                //update the database (code from lectures)
                self.db.collection("nappies").document(self.nappy!.documentID!).delete(){ err in
                    if let err = err {
                        print("Error updating document: \(err)")
                    } else {
                        print("Document successfully updated")
                        //this code triggers the unwind segue manually
                        self.performSegue(withIdentifier: "DeleteNappySegue", sender: sender)
                    }
                }
            }
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    
}
