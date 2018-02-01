//
//  CoreDataStack.swift
//  Goalit
//
//  Created by Sterling Mortensen on 1/19/18.
//  Copyright © 2018 Sterling Mortensen. All rights reserved.
//

import Foundation
import CoreData

enum CoreDataStack {
    
    static let container: NSPersistentContainer =  {
        let container = NSPersistentContainer(name: "Goalit")
        container.loadPersistentStores(completionHandler: {(storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Error loading persistent stores: \(error.userInfo)")
            }
        })
        return container
    }()
    
    static var context: NSManagedObjectContext {return container.viewContext}
}
