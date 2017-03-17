//
//  VMWCoreDataStorage.swift
//  vmwatch
//
//  Created by Tuo Zhang on 2016-11-06.
//  Copyright © 2016 ECE496. All rights reserved.
//

import Foundation
import CoreData

internal class VMWEC2HistoryStorage {
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).getContext()
    
    public func storeEC2History (accessID: String, accessKey: String, instanceID: String, region:String) throws {
        let entity =  NSEntityDescription.entity(forEntityName: "History_EC2", in: self.context)
        let transc = NSManagedObject(entity: entity!, insertInto: context)
        
        //set the entity values
        transc.setValue(accessID, forKey: "access_id")
        transc.setValue(accessKey, forKey: "access_key")
        transc.setValue(instanceID, forKey: "instance_id")
        transc.setValue(region, forKey: "region")
        transc.setValue(Date(), forKey: "date")
        
        //save the object
        do {
            try context.save()
            NSLog("Save success")
        } catch let error as NSError {
            NSLog("Could not save \(error), \(error.userInfo)")
            throw VMWEC2CoreDataStorageError.DatabaseStoreError
        }
    }
    
    public func getEC2History() throws -> NSMutableArray {
        let fetchRequest: NSFetchRequest<History_EC2> = History_EC2.fetchRequest()
        let resultArr = NSMutableArray()
        do {
            let searchResults = try self.context.fetch(fetchRequest)
            NSLog("Fetch success")
            for trans in searchResults as [NSManagedObject]{
                var dict = [String : Any]()
                dict["access_id"] = trans.value(forKey: "access_id") as! String
                dict["access_key"] = trans.value(forKey: "access_key") as! String
                dict["instance_id"] = trans.value(forKey: "instance_id") as! String
                dict["date"] = trans.value(forKey: "date") as! Date
                resultArr.add(dict)
            }
            return resultArr
        } catch let error as NSError {
            NSLog("Error with request: \(error)")
            throw VMWEC2CoreDataStorageError.DatabaseFetchError
        }
    }
    
    public func deleteHistoryRecord(accessID:String, accessKey:String, instanceID: String, region:String) throws {
        let fetchRequest: NSFetchRequest<History_EC2> = History_EC2.fetchRequest()
        fetchRequest.returnsObjectsAsFaults = false;
        
        let resultPredicate1 = NSPredicate(format: "access_id = %@", accessID)
        let resultPredicate2 = NSPredicate(format: "access_key = %@", accessKey)
        let resultPredicate3 = NSPredicate(format: "instance_id = %@", instanceID)
        let resultPredicate4 = NSPredicate(format: "region = %@", region)
        
        let compound = NSCompoundPredicate(andPredicateWithSubpredicates: [resultPredicate1, resultPredicate2, resultPredicate3, resultPredicate4])
        fetchRequest.predicate = compound
        do {
            let searchResults = try self.context.fetch(fetchRequest)
            
            if(searchResults.count > 0){
                for managedObject in searchResults
                {
                    let managedObjectData:NSManagedObject = managedObject as NSManagedObject
                    self.context.delete(managedObjectData)
                }
                NSLog("Delete record success")
            }
        } catch let error as NSError {
            NSLog("Error with request: \(error)")
            throw VMWEC2CoreDataStorageError.DatabaseDeleteError
        }
    }
    
    public func clearHistory() throws {
        let fetchRequest: NSFetchRequest<History_EC2> = History_EC2.fetchRequest()
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let results = try self.context.fetch(fetchRequest)
            for managedObject in results
            {
                let managedObjectData:NSManagedObject = managedObject as NSManagedObject
                self.context.delete(managedObjectData)
            }
            NSLog("Database clear success")
        } catch let error as NSError {
            NSLog("Error : \(error) \(error.userInfo)")
            throw VMWEC2CoreDataStorageError.DatabaseDeleteError
        }
    }
}

internal class VMWHistoryDate {
    private func getCurrentDate() -> Date {
        return Date()
    }
    
    public func getHistoryDateRange(date:Date){

    }
}

enum VMWEC2CoreDataStorageError: Error {
    case DatabaseStoreError
    case DatabaseFetchError
    case DatabaseDeleteError
}


