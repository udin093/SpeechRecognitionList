//
//  Persistence.swift
//  SpeechRecognitionList
//
//  Created by M Khalid Assiddiq on 03/06/24.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    
    let container : NSPersistentContainer
    
    init(){
        container = NSPersistentContainer(name: "SpeechRecognitionList")
        container.loadPersistentStores {(_, error) in
            if let error = error as NSError? { 
                fatalError("Unresolved Error : \(error), \(error.userInfo)")
            }
        }
    }
}
