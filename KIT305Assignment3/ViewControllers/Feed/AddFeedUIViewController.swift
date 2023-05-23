//
//  AddFeedUIViewController.swift
//  KIT305Assignment3
//
//  Created by Broderick Poke on 23/5/2023.
//

import SwiftUI
import Firebase
import FirebaseFirestore

class AddFeedUIViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    var feed: Feed?
    var feedIndex: Int?
    let db = Firestore.firestore()
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var sideSelector: UISegmentedControl!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var noteField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        pickerView.dataSource = self
        pickerView.delegate = self
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 100
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(row)" // Display the row number as the title
    }
    
    // MARK: - Navigation

    @IBAction func onSave(_ sender: Any) {
        let feedCollection = self.db.collection("feeds")
        
        var side: Bool
        
        if(sideSelector.selectedSegmentIndex == 0)
        {
            side = true
        }
        else
        {
            side = false
        }
        
        feed = Feed(
                dateTime: Timestamp(date: datePicker.date),
                duration: pickerView.selectedRow(inComponent: 0),
                left: side,
                note: noteField.text!)
        
        do
        {
            //update the database (code from lectures)
            let feedData = try Firestore.Encoder().encode(feed)
            feedCollection.addDocument(data: feedData){ err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    print("Feed successfully added")
                    //this code triggers the unwind segue manually
                    self.performSegue(withIdentifier: "AddFeedSegue", sender: sender)
                }
            }
        } catch { print("Error adding document \(error)") } //note "error" is a magic variable
    }
    

}
