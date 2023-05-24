//
//  FeedDetailsUIViewController.swift
//  KIT305Assignment3
//
//  Created by Broderick Poke on 23/5/2023.
//

import SwiftUI
import Firebase
import FirebaseFirestore

class FeedDetailsUIViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var sideSelector: UISegmentedControl!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var noteField: UITextField!
    @IBOutlet weak var deleteFeed: UIButton!
    @IBOutlet weak var saveFeed: UIButton!
    
    var feed : Feed?
    var feedIndex : Int?
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerView.dataSource = self
        pickerView.delegate = self
        
        if let displayFeed = feed
        {
            //convert timestamp to displayable date
            let timestampValue = displayFeed.dateTime.seconds
            let timeInterval = TimeInterval(timestampValue)
            let date = Date(timeIntervalSince1970: timeInterval)
            
            //assign UI values based on selected feed
            datePicker.date = date
            
            if(feed!.feedOpt == .left)
            {
                sideSelector.selectedSegmentIndex = 0
            }
            else if(feed!.feedOpt == .right)
            {
                sideSelector.selectedSegmentIndex = 1
            }
            else
            {
                sideSelector.selectedSegmentIndex = 2
            }
            
            if(feed!.duration < 100)
            {
                pickerView.selectRow(feed!.duration, inComponent: 0, animated: true)
            }
            
        }
        
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 100 // We want to show numbers from 0 to 99, so return 100 rows
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(row)" // Display the row number as the title
    }

//    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        let _selectedInteger = row
//    }
    

    
    // MARK: - Navigation
    
    @IBAction func onFeedSave(_ sender: Any) {
        
        feed!.dateTime = Timestamp(date: datePicker.date)
        if(sideSelector.selectedSegmentIndex == 0)
        {
            feed!.feedOpt = .left
        }
        else if(sideSelector.selectedSegmentIndex == 1)
        {
            feed!.feedOpt = .right
        }
        else
        {
            feed!.feedOpt = .bottle
        }
        feed!.duration = pickerView.selectedRow(inComponent: 0)
       
        do
        {
            //update the database (code from lectures)
            try db.collection("feeds").document(feed!.documentID!).setData(from: feed!){ err in
                if let err = err {
                    print("Error updating document: \(err)")
                } else {
                    print("Document successfully updated")
                    //this code triggers the unwind segue manually
                    self.performSegue(withIdentifier: "saveFeedSegue", sender: sender)
                }
            }
        } catch { print("Error updating document \(error)") } //note "error" is a magic variable
    }
    
    @IBAction func onFeedDelete(_ sender: Any) {
        
        let alertController = UIAlertController(title: "Confirm Deletion", message: "Are you sure you want to delete this item?", preferredStyle: .alert)
            
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
            
            do
            {
                //update the database (code from lectures)
                self.db.collection("feeds").document(self.feed!.documentID!).delete(){ err in
                    if let err = err {
                        print("Error updating document: \(err)")
                    } else {
                        print("Document successfully deleted")
                        //this code triggers the unwind segue manually
                        self.performSegue(withIdentifier: "DeleteFeedSegue", sender: sender)
                    }
                }
            }
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        
        present(alertController, animated: true, completion: nil)
    }
            
}
