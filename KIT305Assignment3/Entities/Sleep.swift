//
//  Sleep.swift
//  KIT305Assignment3
//
//  Created by mobiledev on 10/5/2023.
//

import Firebase
import FirebaseFirestoreSwift

public struct Sleep : Codable
{
    @DocumentID var documentID:String?
    var dateTime:Timestamp
    var duration:Int
    var note:String
}
