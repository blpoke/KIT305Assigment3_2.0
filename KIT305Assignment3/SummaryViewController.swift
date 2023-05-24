//
//  SummaryViewController.swift
//  KIT305Assignment3
//
//  Created by mobiledev on 10/5/2023.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift

class SummaryViewController: UIViewController {

    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var wetNappies: UILabel!
    @IBOutlet weak var dirtyNappies: UILabel!
    @IBOutlet weak var leftFeeds: UILabel!
    @IBOutlet weak var rightFeeds: UILabel!
    @IBOutlet weak var sleepsTotal: UILabel!
    
    var date: Date?
    var timestamp: Timestamp?
    var startTimestamp: Timestamp?
    var endTimestamp: Timestamp?
    
    var dirtyNappiesCount = 0
    var wetNappiesCount = 0
    var leftFeedsCount = 0
    var rightFeedsCount = 0
    var sleepCount = 0
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        wetNappies.text = "Loading..."
        dirtyNappies.text = "Loading..."
        leftFeeds.text = "Loading..."
        rightFeeds.text = "Loading..."
        sleepsTotal.text = "Loading..."
        
        date = datePicker.date
        timestamp = Timestamp(date: date!)
        timestampRange()
        fetchNappiesByDate()
        fetchFeedsByDate()
        fetchSleepsByDate()
        
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
            // Handle the date change event
            date = sender.date

            timestamp = Timestamp(date: date!)
            timestampRange()
            fetchNappiesByDate()
            fetchFeedsByDate()
            fetchSleepsByDate()
            
        }
    
    func fetchNappiesByDate(){
        
        let nappyCollection = db.collection("nappies")
        
            nappyCollection.whereField("dateTime", isGreaterThanOrEqualTo: startTimestamp)
            .whereField("dateTime", isLessThanOrEqualTo: endTimestamp).getDocuments() { (result, err) in
            if let err = err
            {
                print("Error getting documents: \(err)")
            }
            else
            {
                for document in result!.documents
                {
                    let conversionResult = Result
                    {
                        try document.data(as: Nappy.self)
                    }
                    switch conversionResult
                    {
                        case .success(let nappy):
                            print("Nappy: \(nappy)")

                            //NOTE THE ADDITION OF THIS LINE
                        if(nappy.dirty == true)
                        {
                            self.dirtyNappiesCount = self.dirtyNappiesCount + 1
                        }
                        else
                        {
                            self.wetNappiesCount = self.wetNappiesCount + 1
                        }
                        
                        self.wetNappies.text = String(self.wetNappiesCount)
                        self.dirtyNappies.text = String(self.dirtyNappiesCount)

                        case .failure(let error):
                            // A `Movie` value could not be initialized from the DocumentSnapshot.
                            print("Error decoding Nappy: \(error)")
                    }
                }
            }
        }
  
        
        self.wetNappies.text = String(wetNappiesCount)
        self.dirtyNappies.text = String(dirtyNappiesCount)
    }
    
    func fetchFeedsByDate(){
    
        let feedCollection = db.collection("feeds")
        
            feedCollection.whereField("dateTime", isGreaterThanOrEqualTo: startTimestamp)
            .whereField("dateTime", isLessThanOrEqualTo: endTimestamp).getDocuments() { (result, err) in
            if let err = err
            {
                print("Error getting documents: \(err)")
            }
            else
            {
                for document in result!.documents
                {
                    let conversionResult = Result
                    {
                        try document.data(as: Feed.self)
                    }
                    switch conversionResult
                    {
                        case .success(let feed):
                            print("Feed: \(feed)")

                        if(feed.left == true)
                        {
                            self.leftFeedsCount = self.leftFeedsCount + 1
                        }
                        else
                        {
                            self.rightFeedsCount = self.rightFeedsCount + 1
                        }
                        
                        self.leftFeeds.text = String(self.leftFeedsCount)
                        self.rightFeeds.text = String(self.rightFeedsCount)

                        case .failure(let error):
                            // A `Movie` value could not be initialized from the DocumentSnapshot.
                            print("Error decoding Feed: \(error)")
                    }
                }
            }
        }
    }
    
    func fetchSleepsByDate(){

        let sleepCollection = db.collection("sleeps")
        
            sleepCollection.whereField("dateTime", isGreaterThanOrEqualTo: startTimestamp)
            .whereField("dateTime", isLessThanOrEqualTo: endTimestamp).getDocuments() { (result, err) in
            if let err = err
            {
                print("Error getting documents: \(err)")
            }
            else
            {
                for document in result!.documents
                {
                    let conversionResult = Result
                    {
                        try document.data(as: Sleep.self)
                    }
                    switch conversionResult
                    {
                        case .success(let sleep):
                            print("Sleep: \(sleep)")

                        self.sleepCount = self.sleepCount + sleep.duration
                        self.sleepsTotal.text = String(self.sleepCount)

                        case .failure(let error):
                            // A `Movie` value could not be initialized from the DocumentSnapshot.
                            print("Error decoding Feed: \(error)")
                    }
                }
            }
        }
    }
    
    func timestampRange() {
        // Get the start and end timestamps for the selected date
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date!)
        let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: startOfDay)!

        // Convert the start and end timestamps to Firestore Timestamp objects
        startTimestamp = Timestamp(date: startOfDay)
        endTimestamp = Timestamp(date: endOfDay)
    }

    @IBAction func shareSummary(_ sender: Any) {
        
    }
    
    
}
