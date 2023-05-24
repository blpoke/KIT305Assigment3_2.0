//
//  SleepDetailsUIViewController.swift
//  KIT305Assignment3
//
//  Created by Broderick Poke on 23/5/2023.
//

import SwiftUI
import Firebase
import FirebaseFirestore

class SleepDetailsUIViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var sleep: Sleep?
    var sleepIndex: Int?
    let db = Firestore.firestore()
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var noteField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        pickerView.dataSource = self
        pickerView.delegate = self
        
        if let displaySleep = sleep
        {
            //ChatGPT reference 2
            //convert timestamp to displayable date
            let timestampValue = displaySleep.dateTime.seconds
            let timeInterval = TimeInterval(timestampValue)
            let date = Date(timeIntervalSince1970: timeInterval)
            
            //assign UI values based on selected feed
            datePicker.date = date
            if(sleep!.duration < 1000)
            {
                pickerView.selectRow(sleep!.duration, inComponent: 0, animated: true)
            }
            noteField.text = sleep!.note
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 999 
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(row)" // Display the row number as the title
    }
    
    // MARK: - Navigation

    @IBAction func onSaveSleep(_ sender: Any) {
        
        sleep!.dateTime = Timestamp(date: datePicker.date)
        sleep!.duration = pickerView.selectedRow(inComponent: 0)
       
        do
        {
            //update the database (code from lectures)
            try db.collection("sleeps").document(sleep!.documentID!).setData(from: sleep!){ err in
                if let err = err {
                    print("Error updating document: \(err)")
                } else {
                    print("Document successfully updated")
                    //this code triggers the unwind segue manually
                    self.performSegue(withIdentifier: "UpdateSleepSegue", sender: sender)
                }
            }
        } catch { print("Error updating document \(error)") } //note "error" is a magic variable
        
    }
    
    @IBAction func onDeleteSleep(_ sender: Any) {
        let alertController = UIAlertController(title: "Confirm Deletion", message: "Are you sure you want to delete this item?", preferredStyle: .alert)
            
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            do
            {
                //update the database (code from lectures)
                self.db.collection("sleeps").document(self.sleep!.documentID!).delete(){ err in
                    if let err = err {
                        print("Error updating document: \(err)")
                    } else {
                        print("Document successfully updated")
                        //this code triggers the unwind segue manually
                        self.performSegue(withIdentifier: "DeleteSleepSegue", sender: sender)
                    }
                }
            }
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
}
