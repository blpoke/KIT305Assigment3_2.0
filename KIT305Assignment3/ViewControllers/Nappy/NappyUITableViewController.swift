//
//  NappyUITableViewController.swift
//  KIT305Assignment3
//
//  Created by mobiledev on 16/5/2023.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift

class NappyUITableViewController: UITableViewController {
    
    var nappies = [Nappy]()

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        navigationItem.title = "Nappies"
        
        let db = Firestore.firestore()
        
        let nappyCollection = db.collection("nappies")
        
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
                        try document.data(as: Nappy.self)
                    }
                    switch conversionResult
                    {
                        case .success(let nappy):
                            print("Nappy: \(nappy)")

                            //NOTE THE ADDITION OF THIS LINE
                            self.nappies.append(nappy)

                        case .failure(let error):
                            // A `Movie` value could not be initialized from the DocumentSnapshot.
                            print("Error decoding Nappy: \(error)")
                    }
                }
                
                //resort entries by date
                self.nappies.sort { (date1, date2) -> Bool in
                    return date1.dateTime.dateValue() > date2.dateTime.dateValue()
                }
                self.tableView.reloadData()
            }
        }
            
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return nappies.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NappyUITableViewCell", for: indexPath)

        //get the nappy for this row
        let nappy = nappies[indexPath.row]

        //note, this could fail, so we use an if let.
        if let nappyCell = cell as? NappyUITableViewCell
        {
            //populate the cell
            //following date formatting produced by ChatGPT
            let date = nappy.dateTime.dateValue()
            
            let dateFormatter = DateFormatter()
            
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .medium
            
            let dateString = dateFormatter.string(from: date)
            
            nappyCell.titleLabel.text = dateString
            
            if(nappy.dirty == true){
                nappyCell.subTitleLabel.text = "Dirty"
            }
            else{
                nappyCell.subTitleLabel.text = "Wet"
            }
            
        }

        return cell
    }

    
    // MARK: - Navigation

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        super.prepare(for: segue, sender: sender)
        
        // is this the segue to the details screen? (in more complex apps, there is more than one segue per screen)
        if segue.identifier == "ShowNappyDetailSegue"
        {
              //down-cast from UIViewController to DetailViewController (this could fail if we didn’t link things up properly)
              guard let detailViewController = segue.destination as? NappyDetailsViewController else
              {
                  fatalError("Unexpected destination: \(segue.destination)")
              }

              //down-cast from UITableViewCell to MovieUITableViewCell (this could fail if we didn’t link things up properly)
              guard let selectedNappyCell = sender as? NappyUITableViewCell else
              {
                  fatalError("Unexpected sender: \( String(describing: sender))")
              }

              //get the number of the row that was pressed (this could fail if the cell wasn’t in the table but we know it is)
              guard let indexPath = tableView.indexPath(for: selectedNappyCell) else
              {
                  fatalError("The selected cell is not being displayed by the table")
              }

              //work out which movie it is using the row number
              let selectedNappy = nappies[indexPath.row]

              //send it to the details screen
              detailViewController.nappy = selectedNappy
              detailViewController.nappyIndex = indexPath.row
        }
    }
    
    @IBAction func unwindToNappyList(sender: UIStoryboardSegue)
    {
        if let detailScreen = sender.source as? NappyDetailsViewController
           {
               nappies[detailScreen.nappyIndex!] = detailScreen.nappy!
               tableView.reloadData()
           }
    }
    
    @IBAction func unwindToNappyListDelete(sender: UIStoryboardSegue)
    {
        if let detailScreen = sender.source as? NappyDetailsViewController
        {
            nappies.remove(at: detailScreen.nappyIndex!)
            tableView.reloadData()
        }
    }
    
    @IBAction func unwindToNappyListAddNew(sender: UIStoryboardSegue)
    {
        if let detailScreen = sender.source as? AddNappyUIViewController
        {
            //add new sleep to list
            nappies.append(detailScreen.nappy!)
        }
        //resort entries by date
        self.nappies.sort { (date1, date2) -> Bool in
            return date1.dateTime.dateValue() > date2.dateTime.dateValue()
        }
        
        tableView.reloadData()
    }
    
}
