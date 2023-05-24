//
//  Feed.swift
//  KIT305Assignment3
//
//  Created by mobiledev on 10/5/2023.
//

import Firebase
import FirebaseFirestoreSwift



public struct Feed : Codable
{
    @DocumentID var documentID:String?
    var dateTime:Firebase.Timestamp
    var duration:Int
    var feedOpt: FeedingOption
    var note:String
    
    enum FeedingOption: String, Codable {
        case left
        case right
        case bottle
    }
}
