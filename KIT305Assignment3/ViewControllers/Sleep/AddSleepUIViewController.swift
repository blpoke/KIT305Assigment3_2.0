//
//  AddSleepUIViewController.swift
//  KIT305Assignment3
//
//  Created by Broderick Poke on 23/5/2023.
//

import SwiftUI
import Firebase
import FirebaseFirestore

class AddSleepUIViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var noteField: UITextField!
    
    var sleep: Sleep?
    var sleepIndex: Int?
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        pickerView.dataSource = self
        pickerView.delegate = self
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    
    @IBAction func onSaveNewSleep(_ sender: Any) {
        
        let sleepCollection = self.db.collection("sleeps")
        
        sleep = Sleep(
            dateTime: Timestamp(date: datePicker.date),
            duration: pickerView.selectedRow(inComponent: 0),
            note: noteField.text!)
       
        do
        {
            //update the database (code from lectures)
            let sleepData = try Firestore.Encoder().encode(sleep)
            sleepCollection.addDocument(data: sleepData){ err in
                if let err = err {
                    print("Error updating document: \(err)")
                } else {
                    print("Sleep successfully added")
                    //this code triggers the unwind segue manually
                    self.performSegue(withIdentifier: "AddSleepSegue", sender: sender)
                }
            }
        } catch { print("Error adding document \(error)") } //note "error" is a magic variable
        
    }
}
