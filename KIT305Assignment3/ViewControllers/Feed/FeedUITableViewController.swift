//
//  FeedUITableViewController.swift
//  KIT305Assignment3
//
//  Created by mobiledev on 16/5/2023.
//

import SwiftUI
import Firebase
import FirebaseFirestore

class FeedUITableViewController: UITableViewController {
    
    var feeds = [Feed]()

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        navigationItem.title = "Feeds"
        
        let db = Firestore.firestore()
        
        let feedCollection = db.collection("feeds")
        
        feedCollection.getDocuments() { (result, err) in
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

                            //NOTE THE ADDITION OF THIS LINE
                            self.feeds.append(feed)

                        case .failure(let error):
                            // A `Movie` value could not be initialized from the DocumentSnapshot.
                            print("Error decoding feed: \(error)")
                    }
                }

                //NOTE THE ADDITION OF THIS LINE
                
                self.feeds.sort { (sleep1, sleep2) -> Bool in
                    return sleep1.dateTime.dateValue() > sleep2.dateTime.dateValue()
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
        return feeds.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedUITableViewCell", for: indexPath)

        //get the movie for this row
        let feed = feeds[indexPath.row]

        //note, this could fail, so we use an if let.
        if let feedCell = cell as? FeedUITableViewCell
        {
            //populate the cell
            //following date formatting produced by ChatGPT
            let date = feed.dateTime.dateValue()
            
            let dateFormatter = DateFormatter()
            
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .medium
            
            let dateString = dateFormatter.string(from: date)
            
            feedCell.titleLabel.text = dateString
            
            if(feed.feedOpt == .left){
                feedCell.subTitleLabel.text = "\(feed.duration) Mins (Left)"
            }
            else if (feed.feedOpt == .right)
            {
                feedCell.subTitleLabel.text = "\(feed.duration) Mins (Right)"
            }
            else
            {
                feedCell.subTitleLabel.text = "\(feed.duration) Mins (Bottle)"
            }
            
            
        }

        return cell
    }


    // MARK: - Navigation

     override func prepare(for segue: UIStoryboardSegue, sender: Any?)
     {
         super.prepare(for: segue, sender: sender)
         
         // is this the segue to the details screen? (in more complex apps, there is more than one segue per screen)
         if segue.identifier == "showFeedDetailsSegue"
         {
               //down-cast from UIViewController to DetailViewController (this could fail if we didn’t link things up properly)
               guard let detailViewController = segue.destination as? FeedDetailsUIViewController else
               {
                   fatalError("Unexpected destination: \(segue.destination)")
               }

               //down-cast from UITableViewCell to MovieUITableViewCell (this could fail if we didn’t link things up properly)
               guard let selectedFeedCell = sender as? FeedUITableViewCell else
               {
                   fatalError("Unexpected sender: \( String(describing: sender))")
               }

               //get the number of the row that was pressed (this could fail if the cell wasn’t in the table but we know it is)
               guard let indexPath = tableView.indexPath(for: selectedFeedCell) else
               {
                   fatalError("The selected cell is not being displayed by the table")
               }

               //work out which movie it is using the row number
               let selectedFeed = feeds[indexPath.row]

               //send it to the details screen
               detailViewController.feed = selectedFeed
               detailViewController.feedIndex = indexPath.row
         }
     }
    
    @IBAction func unwindToFeedList(sender: UIStoryboardSegue)
    {
        if let detailScreen = sender.source as? FeedDetailsUIViewController
           {
               feeds[detailScreen.feedIndex!] = detailScreen.feed!
            
                self.feeds.sort { (sleep1, sleep2) -> Bool in
                    return sleep1.dateTime.dateValue() > sleep2.dateTime.dateValue()
                }
                
               tableView.reloadData()
           }
    }
    
    @IBAction func unwindToFeedListDelete(sender: UIStoryboardSegue)
    {
        if let detailScreen = sender.source as? FeedDetailsUIViewController
        {
            feeds.remove(at: detailScreen.feedIndex!)
            
            tableView.reloadData()
        }
    }
    
    @IBAction func unwindToFeedListAddNew(sender: UIStoryboardSegue)
    {
        if let detailScreen = sender.source as? AddFeedUIViewController
        {
            //add new sleep to list
            feeds.append(detailScreen.feed!)
        }
        //resort entries by date
        self.feeds.sort { (date1, date2) -> Bool in
            return date1.dateTime.dateValue() > date2.dateTime.dateValue()
        }
        
        tableView.reloadData()
    }

}
