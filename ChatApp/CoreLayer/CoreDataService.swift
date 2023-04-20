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
            print("loadPersistentStore error:", error)
        }
        
        return persistentContainer
    }()
    
    private var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    func fetchChannels() throws -> [ChannelManagedObject] {
        let fetchRequest = ChannelManagedObject.fetchRequest()
        return try viewContext.fetch(fetchRequest)
    }
    
    func fetchMessages(for channelId: String) throws -> [MessageManagedObject] {
        let fetchRequest = ChannelManagedObject.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", channelId)
        
        let channelManagedObject = try viewContext.fetch(fetchRequest).first
        
        guard let channelManagedObject,
              let messagesManagedObjects = channelManagedObject.messages?.array as? [MessageManagedObject] else {
            return []
        }
        
        return messagesManagedObjects
    }
    
    func save(completion: @escaping (NSManagedObjectContext) throws -> Void) {
        let backgroundContext = persistentContainer.newBackgroundContext()
        backgroundContext.performAndWait {
            do {
                try completion(backgroundContext)
                if backgroundContext.hasChanges {
                    try backgroundContext.save()
                }
            } catch {
                print("Save to CoreData error:", error)
            }
        }
    }
}
