//
//  CoreDataServiceProtocol.swift
//  ChatApp
//
//  Created by Anastasiia Bugaeva on 20.04.2023.
//

import Foundation
import CoreData

protocol CoreDataServiceProtocol {
    func fetchChannels() throws -> [ChannelManagedObject]
    func fetchMessages(for channelId: String) throws -> [MessageManagedObject]
    func save(completion: @escaping (NSManagedObjectContext) throws -> Void)
}
