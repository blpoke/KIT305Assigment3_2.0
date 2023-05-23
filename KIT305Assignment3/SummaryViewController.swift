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

    @IBOutlet weak var summaryLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        summaryLabel.text = "Summary!!!"
    }

}
