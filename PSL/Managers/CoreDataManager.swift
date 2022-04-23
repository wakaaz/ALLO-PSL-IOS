//
//  CoreDataManager.swift
//  Lists
//
//  Created by Bart Jacobs on 07/03/2017.
//  Copyright © 2017 Cocoacasts. All rights reserved.
//

import CoreData

var sharedInstance : CoreDataManager? = nil;

class CoreDataManager: NSObject {
    static let Instance = CoreDataManager()
    
        
        lazy var applicationDocumentsDirectory: URL = {
            // The directory the application uses to store the Core Data store file. This code uses a directory named "com.irfanali.Lynk" in the application's documents Application Support directory.
            return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!

        }()
        
        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
        
        lazy var managedObjectModel: NSManagedObjectModel = {
            // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
            let modelURL = Bundle.main.url(forResource: "PSL", withExtension: "momd")!
            return NSManagedObjectModel(contentsOf: modelURL)!
        }()
        
        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
        
        lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
            // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
            // Create the coordinator and store
           /* let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
            let url = self.applicationDocumentsDirectory.appendingPathComponent("PSL.sqlite")
            print(url)
            var failureReason = "There was an error creating or loading the application's saved data."
            do {
                try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
            } catch {
                // Report any error we got.
                var dict = [String: AnyObject]()
                dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
                dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
                
                dict[NSUnderlyingErrorKey] = error as NSError
                let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
                // Replace this with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            }*/
            
            
            
            //return coordinator
            
            
            let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
                
                let persistentStoreURL = self.applicationDocumentsDirectory.appendingPathComponent("PSL.sqlite")
               print(persistentStoreURL)
                var failureReason = "There was an error creating or loading the application's saved data."
                do {
                  try coordinator.addPersistentStore(ofType: NSSQLiteStoreType,
                                                             configurationName: nil,
                                                             at: persistentStoreURL,
                                                             options: [NSMigratePersistentStoresAutomaticallyOption: true,
                                                              NSInferMappingModelAutomaticallyOption: true])
                } catch {
                  var dict = [String: AnyObject]()
                  dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
                  dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
                  dict[NSUnderlyingErrorKey] = error as NSError
                  let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
                  //* Replace this with code to handle the error appropriately.
                  //* abort() causes the application to generate a crash log and terminate.
                  //* We should not use this function in a shipping application,
                  //* although it may be useful during development.
                  NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
                  
                  //* If you encounter schema incompatibility errors during development,
                  //* we can reduce their frequency by:
                  //* Simply deleting the existing store:
                  do {
                    try FileManager.default.removeItem(at: persistentStoreURL)
                  } catch {
                    NSLog("Unresolved error \(error)")
                  }
                  fatalError("Persistent store error! \(error)")
                }
                return coordinator
            
        }()
        
        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
            //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
    // MARK: - Core Data stack
    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~//
    
    public func saveContext () {
          if managedObjectContext.hasChanges {
              do {
                  try managedObjectContext.save()
              } catch {
                  // Replace this implementation with code to handle the error appropriately.
                  // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                  let nserror = error as NSError
                  NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                  //abort()
              }
          }
      }
  
        
        lazy var managedObjectContext: NSManagedObjectContext = {
            // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
            let coordinator = self.persistentStoreCoordinator
            var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            managedObjectContext.persistentStoreCoordinator = coordinator
            return managedObjectContext
        }()
        
}
