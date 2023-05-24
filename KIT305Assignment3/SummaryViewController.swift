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
    @IBOutlet weak var bottleFeedsTotal: UILabel!
    
    
    var date: Date?
    var timestamp: Timestamp?
    var startTimestamp: Timestamp?
    var endTimestamp: Timestamp?
    
    var dirtyNappiesCount = 0
    var wetNappiesCount = 0
    var leftFeedsCount = 0
    var rightFeedsCount = 0
    var sleepCount = 0
    var bottleFeedsCount = 0
    
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
    
    func fetchNappiesByDate() {
        
        let nappyCollection = db.collection("nappies")
        
            nappyCollection.whereField("dateTime", isGreaterThanOrEqualTo: startTimestamp)
            .whereField("dateTime", isLessThanOrEqualTo: endTimestamp).getDocuments() { (result, err) in
            if let err = err
            {
                print("Error getting documents: \(err)")
            }
            else
            {
                self.dirtyNappiesCount = 0 // Reset the count before updating
                self.wetNappiesCount = 0
                
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

                        if nappy.dirty {
                            self.dirtyNappiesCount += 1
                        } else {
                            self.wetNappiesCount += 1
                        }
                        
//                        self.wetNappies.text = String(self.wetNappiesCount)
//                        self.dirtyNappies.text = String(self.dirtyNappiesCount)

                        case .failure(let error):
                            // A `Movie` value could not be initialized from the DocumentSnapshot.
                            print("Error decoding Nappy: \(error)")
                    }
                }
                self.wetNappies.text = String(self.wetNappiesCount)
                self.dirtyNappies.text = String(self.dirtyNappiesCount)
            }
        }
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
                self.leftFeedsCount = 0
                self.rightFeedsCount = 0
                self.bottleFeedsCount = 0
                
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

                        if(feed.feedOpt == .left)
                        {
                            self.leftFeedsCount += feed.duration
                        }
                        else if(feed.feedOpt == .right)
                        {
                            self.rightFeedsCount += feed.duration
                        }
                        else
                        {
                            self.bottleFeedsCount += feed.duration
                        }
                        
                        case .failure(let error):
                            // A `Movie` value could not be initialized from the DocumentSnapshot.
                            print("Error decoding Feed: \(error)")
                    }
                }
                
                self.leftFeeds.text = String(self.leftFeedsCount)
                self.rightFeeds.text = String(self.rightFeedsCount)
                self.bottleFeedsTotal.text = String(self.bottleFeedsCount)
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
                self.sleepCount = 0
                
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

                        case .failure(let error):
                            // A `Movie` value could not be initialized from the DocumentSnapshot.
                            print("Error decoding Feed: \(error)")
                    }
                }
                self.sleepsTotal.text = String(self.sleepCount)
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

    @IBAction func shareSummary(_ sender: UIView) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd" // Custom date format

        let formattedDate = dateFormatter.string(from: date!)
        print(formattedDate)
        
        let shareViewController = UIActivityViewController(
            activityItems: ["Baby Summary for \(formattedDate)\nTotal Wet Nappies: \(wetNappiesCount)\nTotal Dirty Nappies: \(dirtyNappiesCount)\nTotal Feed Time on Left: \(leftFeedsCount) Mins\nTotal Feed Time on Right: \(rightFeedsCount)\nTotal Sleep Time: \(sleepCount)"],
            applicationActivities: [])
        
        shareViewController.popoverPresentationController?.sourceView = sender
        
        present(shareViewController, animated: true, completion: nil)
    }
}
