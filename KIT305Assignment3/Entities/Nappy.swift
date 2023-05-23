//
//  Nappy.swift
//  KIT305Assignment3
//
//  Created by mobiledev on 10/5/2023.
//

import Firebase
import FirebaseFirestoreSwift

public struct Nappy : Codable
{
    @DocumentID var documentID:String?
    var dateTime:Firebase.Timestamp
    var dirty:Bool
    var note:String
}
