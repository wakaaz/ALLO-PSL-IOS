//
//  CategoriesJob.swift
//  PSL
//
//  Created by MacBook on 26/03/2021.
//

import UIKit
import SwiftQueue
import Alamofire
import CoreData
class CategoriesJob: Job {
    static let type = "CategoriesJob"
    // Param
    private let tweet: [String: Any]
    
    required init(params: [String: Any]) {
        // Receive params from JobBuilder.with()
        self.tweet = params
        print("job required")
    }
    
    func onRun(callback: JobResult) {
        
        
        print("job run")
        
        requestCategoryPayload(callback: callback)
        
        
    }
    
    func onRetry(error: Error) -> RetryConstraint {
        // Check if error is non fatal
        print("job retry")
        
        return  RetryConstraint.cancel// immediate retry
        
    }
    
    func onRemove(result: JobCompletion) {
        print("job remove")
        
        // This job will never run anymore
        switch result {
        case .success:
            // Job success
            
            
            break
            
        case .fail(let error):
            // Job fail
            print(error)
            
            break
            
        }
    }
    
    func requestCategoryPayload(callback: JobResult){
        let headers: HTTPHeaders = [
            "session": AuthenticationPreference.getSession(),
            "userType": UIContant.GUEST_USER
        ]
        print(headers)
        let parameter:  Parameters = [:]
        AF.request(UIContant.PREFERENCE, method: .get, parameters: parameter, encoding: URLEncoding(destination: .methodDependent),headers: headers).responseDecodable(of: RootPreference.self)  { response in
            
            switch response.result {
            
            case .success:
                guard let model = response.value else { return }
                if let responseCode = model.code {
                    if responseCode ==  200{
                        guard let innermodel = model.object else { return }
                        if let dicList = innermodel.dictionaryCategories, !dicList.isEmpty {
                            
                            if dicList.count == self.checkRecord(){
                                callback.done(.success)
                            }else{
                                self.resetAllRecords(in: "Categories")

                                self.createData(callback: callback, data: dicList)

                            }
                            
                            
                        }
                        if let teacherList = innermodel.tutGrades, !teacherList.isEmpty {
                            
                        }
                        if let storyList = innermodel.storyTypes, !storyList.isEmpty {
                            
                        }
                        if let learningList = innermodel.learningTutGrades, !learningList.isEmpty {
                            
                        }
                        if let skillList = innermodel.lifeSkills, !skillList.isEmpty {
                            
                        }
                        
                    }else {
                        
                    }
                }
            case .failure(let error):
                print(error)
                
                
            }
        }
    }
    
    func createData(callback: JobResult,data : [DictionaryCategory]){
        
        //As we know that container is set up in the AppDelegates so we need to refer that container.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        //We need to create a context from this container
        let manager = CoreDataManager.Instance

        let managedContext = manager.managedObjectContext
        
        //Now let’s create an entity and new user records.
        let userEntity = NSEntityDescription.entity(forEntityName: "Categories", in: managedContext)!
        
        //final, we need to add some data to our newly created record for each keys using
        //here adding 5 data with loop
        
        for i in 0..<data.count {
            let model:DictionaryCategory = data[i]
            let user = NSManagedObject(entity: userEntity, insertInto: managedContext)
            user.setValue(model.id, forKeyPath: "id")
            user.setValue(model.videos, forKey: "videos")
            let poster = model.image ?? ""
            user.setValue(poster, forKey: "image")
            let englishWord = model.title ?? ""
            user.setValue(englishWord, forKey: "title")
           



        }

        //Now we have set all the values. The next step is to save them inside the Core Data
        
        do {
            try managedContext.save()
            callback.done(.success)

        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    func checkRecord()->Int {
        var count:Int = 0
        //As we know that container is set up in the AppDelegates so we need to refer that container.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return 0 }
        
        //We need to create a context from this container
        let manager = CoreDataManager.Instance

        let managedContext = manager.managedObjectContext
        //Prepare the request of type NSFetchRequest  for the entity
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Categories")
        //let predicateID = NSPredicate(format: "id == %@","")
        //    fetchRequest.predicate = predicateID
        //        fetchRequest.fetchLimit = 1
        //        fetchRequest.predicate = NSPredicate(format: "username = %@", "Ankur")
        //        fetchRequest.sortDescriptors = [NSSortDescriptor.init(key: "email", ascending: false)]
        //
        do {
            let result = try managedContext.fetch(fetchRequest)
            count = result.count ?? 0
            /*for data in result as! [NSManagedObject] {
             print(data.value(forKey: "username") as! String)
             }*/
            
        } catch {
            
            print("Failed")
        }
        
        return count
    }
    func resetAllRecords(in entity : String) // entity = Your_Entity_Name
    {
        
      
        
        let manager = CoreDataManager.Instance

        let managedContext = manager.managedObjectContext
        
                  let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
                  let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
                  do {
                      try managedContext.execute(deleteRequest)
                      try managedContext.save()
                  } catch {
                      print ("There is an error in deleting records")
                  }
          
    }
}
