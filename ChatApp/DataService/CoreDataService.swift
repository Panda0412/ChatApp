//
//  CoreDataService.swift
//  ChatApp
//
//  Created by Anastasiia Bugaeva on 13.04.2023.
//

import CoreData
import Foundation

class CoreDataService {
    private lazy var persistentContainer: NSPersistentContainer = {
        let persistentContainer = NSPersistentContainer(name: "ChannelsDataModel")
        
        persistentContainer.loadPersistentStores { _, error in
            guard let error else { return }
            print(error)
        }
        
        return persistentContainer
    }()
    
    private var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    func getChannels() throws -> [ChannelManagedObject] {
        let fetchRequest = ChannelManagedObject.fetchRequest()
        return try viewContext.fetch(fetchRequest)
    }
    
    func save(completion: @escaping (NSManagedObjectContext) throws -> Void) {
        let backgroundContext = persistentContainer.newBackgroundContext()
        backgroundContext.perform {
            do {
                try completion(backgroundContext)
                if backgroundContext.hasChanges {
                    try backgroundContext.save()
                }
            } catch {
                print(error)
            }
        }
    }
}
