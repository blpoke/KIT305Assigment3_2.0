//
//  SleepUITableViewController.swift
//  KIT305Assignment3
//
//  Created by Broderick Poke on 23/5/2023.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift

class SleepUITableViewController: UITableViewController {

    var sleeps = [Sleep]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let db = Firestore.firestore()
        
        let nappyCollection = db.collection("sleeps")
        
        nappyCollection.getDocuments() { (result, err) in
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

                            //NOTE THE ADDITION OF THIS LINE
                            self.sleeps.append(sleep)

                        case .failure(let error):
                            // A `Movie` value could not be initialized from the DocumentSnapshot.
                            print("Error decoding Nappy: \(error)")
                    }
                }
                
                // Sort the array by dateTime property in descending order (most recent first)
                self.sleeps.sort { (sleep1, sleep2) -> Bool in
                    return sleep1.dateTime.dateValue() > sleep2.dateTime.dateValue()
                }

                self.tableView.reloadData()
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return sleeps.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SleepUITableViewCell", for: indexPath)

        //get the nappy for this row
        let sleep = sleeps[indexPath.row]

        //note, this could fail, so we use an if let.
        if let sleepCell = cell as? SleepUITableViewCell
        {
            //populate the cell
            //ChatGPT Refernce 1
            let date = sleep.dateTime.dateValue()
            
            let dateFormatter = DateFormatter()
            
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .medium
            
            let dateString = dateFormatter.string(from: date)

            sleepCell.titleLabel.text = dateString
            sleepCell.subTitleLabel.text = "\(sleep.duration) Mins"
            
        }

        return cell
    }

    // MARK: - Navigation
    
    @IBAction func unwindToSleepListAddNew(sender: UIStoryboardSegue)
    {
        if let detailScreen = sender.source as? AddSleepUIViewController
        {
            //add new sleep to list
            sleeps.append(detailScreen.sleep!)
        }
        //resort entries by date
        self.sleeps.sort { (sleep1, sleep2) -> Bool in
            return sleep1.dateTime.dateValue() > sleep2.dateTime.dateValue()
        }
        
        tableView.reloadData()
    }
    
    @IBAction func unwindToSleepListUpdate(sender: UIStoryboardSegue)
    {
        if let detailScreen = sender.source as? SleepDetailsUIViewController
        {
            sleeps[detailScreen.sleepIndex!] = detailScreen.sleep!
        }
        
        //resort entries by date
        self.sleeps.sort { (sleep1, sleep2) -> Bool in
            return sleep1.dateTime.dateValue() > sleep2.dateTime.dateValue()
        }
        
        tableView.reloadData()
    }
    
    @IBAction func unwindToSleepListDelete(sender: UIStoryboardSegue)
    {
        if let detailScreen = sender.source as? SleepDetailsUIViewController
        {
            sleeps.remove(at: detailScreen.sleepIndex!)
        }
        
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        super.prepare(for: segue, sender: sender)
        
        // is this the segue to the details screen? (in more complex apps, there is more than one segue per screen)
        if segue.identifier == "showSleepDetailsSegue"
        {
              //down-cast from UIViewController to DetailViewController (this could fail if we didn’t link things up properly)
              guard let detailViewController = segue.destination as? SleepDetailsUIViewController else
              {
                  fatalError("Unexpected destination: \(segue.destination)")
              }

              //down-cast from UITableViewCell to MovieUITableViewCell (this could fail if we didn’t link things up properly)
              guard let selectedSleepCell = sender as? SleepUITableViewCell else
              {
                  fatalError("Unexpected sender: \( String(describing: sender))")
              }

              //get the number of the row that was pressed (this could fail if the cell wasn’t in the table but we know it is)
              guard let indexPath = tableView.indexPath(for: selectedSleepCell) else
              {
                  fatalError("The selected cell is not being displayed by the table")
              }

              //work out which movie it is using the row number
              let selectedSleep = sleeps[indexPath.row]

              //send it to the details screen
              detailViewController.sleep = selectedSleep
              detailViewController.sleepIndex = indexPath.row
        }
    }

}
