//
//  AuthJob.swift
//  PSL
//
//  Created by MacBook on 26/03/2021.
//

import UIKit
import SwiftQueue
import Alamofire
import CoreData

class AuthJob: Job {
    // Type to know which Job to return in job creator
    static let type = "AuthJob"
    // Param
    private let tweet: [String: Any]
    
    required init(params: [String: Any]) {
        // Receive params from JobBuilder.with()
        self.tweet = params
        print("job required")
    }
    
    func onRun(callback: JobResult) {
        
        
        print("job run")
       // callback.done(.success)

        processAuth(callback: callback)


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
           /* let jobmanager = SwiftQueueManagerBuilder(creator: AuthjobCreator()).build()
                JobBuilder(type: CategoriesJob.type)
                        // Requires internet to run
                        .internet(atLeast: .cellular)
                        // params of my job
                        .with(params: ["content": "Hello world"])
                        // Add to queue manager
                        .schedule(manager: jobmanager)*/
           
            break
            
        case .fail(let error):
            // Job fail
            print(error)
          
            break
            
        }
    }
    func processAuth(callback: JobResult){
        if !AuthenticationPreference.getSession().isEmpty{
            requestAllWords(callback: callback)
        }else{
            requestAuth(callback: callback)
        }
    }
    
    
    
    
    
    
    func requestAuth(callback: JobResult){
        let login :Parameters = [:]
        AF.request(UIContant.SKIP, method: .post, parameters: login, encoding: URLEncoding(destination: .methodDependent)).responseDecodable(of: RootClass.self)  { response in
            print(response)
           
            switch response.result {

            case .success:
                guard let model = response.value else { return }
                guard let innermodel = model.object else { return }
                 AuthenticationPreference.saveAuth(model: innermodel)
                self.requestAllWords(callback: callback)

            case .failure(let error):
                print(error)
                 AuthenticationPreference.removeAuth()

              //  UICommonMethods.showAlert(title: "Error",message: "Invalid Credential", viewController: self)

            }
        }
    }
    
    func requestAllWords(callback: JobResult){
        let headers: HTTPHeaders = [
            "session": AuthenticationPreference.getSession(),
            "userType": UIContant.GUEST_USER
        ]
        let parameter:  Parameters = [:]
        print(parameter)
        
        AF.request(UIContant.DICTIONARY, method: .post, parameters: parameter, encoding: URLEncoding(destination: .methodDependent),headers: headers).responseDecodable(of: RootDictionary.self)  { response in
            //print(response)
            switch response.result {
            
            case .success:
                guard let model = response.value else { return }
                if let responseCode = model.code {
                    if responseCode ==  200{
                        if let dicList = model.data, !dicList.isEmpty {
                            
                            let dbRecordCount = self.checkRecord()

                            if dicList.count ==  dbRecordCount{
                                callback.done(.success)
                                self.startAnotherJob()
                            }else{
                                NotificationCenter.default.post(name: Notification.Name("SyncFinished"), object: nil, userInfo: ["task":"0"])

                                self.resetAllRecords(in: "Words")
                                let list =  dicList.sorted { $0.englishWord?.lowercased() ?? "" < $1.englishWord?.lowercased() ?? "" }

                                self.createData(callback: callback, data: list)

                            }
                        }

                        
                    }else {
                        
                    }
                }
            case .failure(let error):
                print(error)
                callback.done(.success)

                
                
            }
        }
    }
    
    
    func createData(callback: JobResult,data : [DictionaryDatum]){
        let number = "8005551234"
        let numberCharacters = NSCharacterSet.decimalDigits
        //As we know that container is set up in the AppDelegates so we need to refer that container.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        //We need to create a context from this container
        let manager = CoreDataManager.Instance

        let managedContext = manager.managedObjectContext

        //Now let’s create an entity and new user records.
        let userEntity = NSEntityDescription.entity(forEntityName: "Words", in: managedContext)!
        
        //final, we need to add some data to our newly created record for each keys using
        //here adding 5 data with loop
        
        var urdu = [DictionaryDatum]()
        var numbers = [DictionaryDatum]()

        for i in 0..<data.count {
            let model:DictionaryDatum = data[i]
            let englishWord = model.englishWord ?? ""
    
            let otherStr = englishWord as NSString
            if otherStr == "-"{
                urdu.append(model)
            }else if  englishWord.doStringContainsNumber(_string: englishWord) {
                numbers.append(model)
            }else{
                let user = NSManagedObject(entity: userEntity, insertInto: managedContext)
                user.setValue(model.id, forKeyPath: "id")
                user.setValue(model.categoryId, forKey: "category_id")
                let poster = model.poster ?? ""
                user.setValue(poster, forKey: "poster")
                let title = model.title ?? ""
                user.setValue(title, forKey: "title")
                user.setValue(englishWord, forKey: "english_word")
                let urduWord = model.urduWord ?? ""
                user.setValue(urduWord, forKey: "urdu_word")
                let filename = model.filename ?? ""
                user.setValue(filename, forKey: "filename")
                let youtubeLink = model.youtubeLink ?? ""
                user.setValue(youtubeLink, forKey: "youtube_link")
                let vimeoLink = model.vimeoLink ?? ""
                user.setValue(vimeoLink, forKey: "vimeo_link")
                let quality1080p = model.quality1080p?.url ?? ""
                user.setValue(quality1080p, forKey: "p1080")
                let quality720p = model.quality720p?.url ?? ""
                user.setValue(quality720p, forKey: "p720")
                let quality480p = model.quality480p?.url ?? ""
                user.setValue(quality480p, forKey: "p480")
                let quality360p = model.quality360p?.url ?? ""
                user.setValue(quality360p, forKey: "p360")
                let quality240p = model.quality240p?.url ?? ""
                user.setValue(quality240p, forKey: "p240")
                user.setValue(model.favorite, forKey: "favorite")
                user.setValue(model.shareablURL, forKey: "shareableurl")
            }
            



        }
        for i in 0..<numbers.count {
            let model:DictionaryDatum = numbers[i]
            let englishWord = model.englishWord ?? ""
            let user = NSManagedObject(entity: userEntity, insertInto: managedContext)
            user.setValue(model.id, forKeyPath: "id")
            user.setValue(model.categoryId, forKey: "category_id")
            let poster = model.poster ?? ""
            user.setValue(poster, forKey: "poster")
            let title = model.title ?? ""
            user.setValue(title, forKey: "title")
            user.setValue(englishWord, forKey: "english_word")
            let urduWord = model.urduWord ?? ""
            user.setValue(urduWord, forKey: "urdu_word")
            let filename = model.filename ?? ""
            user.setValue(filename, forKey: "filename")
            let youtubeLink = model.youtubeLink ?? ""
            user.setValue(youtubeLink, forKey: "youtube_link")
            let vimeoLink = model.vimeoLink ?? ""
            user.setValue(vimeoLink, forKey: "vimeo_link")
            let quality1080p = model.quality1080p?.url ?? ""
            user.setValue(quality1080p, forKey: "p1080")
            let quality720p = model.quality720p?.url ?? ""
            user.setValue(quality720p, forKey: "p720")
            let quality480p = model.quality480p?.url ?? ""
            user.setValue(quality480p, forKey: "p480")
            let quality360p = model.quality360p?.url ?? ""
            user.setValue(quality360p, forKey: "p360")
            let quality240p = model.quality240p?.url ?? ""
            user.setValue(quality240p, forKey: "p240")
            user.setValue(model.favorite, forKey: "favorite")
            user.setValue(model.shareablURL, forKey: "shareableurl")

        }
        
        for i in 0..<urdu.count {
            let model:DictionaryDatum = urdu[i]
            let englishWord = model.englishWord ?? ""
            let user = NSManagedObject(entity: userEntity, insertInto: managedContext)
            user.setValue(model.id, forKeyPath: "id")
            user.setValue(model.categoryId, forKey: "category_id")
            let poster = model.poster ?? ""
            user.setValue(poster, forKey: "poster")
            let title = model.title ?? ""
            user.setValue(title, forKey: "title")
            user.setValue(englishWord, forKey: "english_word")
            let urduWord = model.urduWord ?? ""
            user.setValue(urduWord, forKey: "urdu_word")
            let filename = model.filename ?? ""
            user.setValue(filename, forKey: "filename")
            let youtubeLink = model.youtubeLink ?? ""
            user.setValue(youtubeLink, forKey: "youtube_link")
            let vimeoLink = model.vimeoLink ?? ""
            user.setValue(vimeoLink, forKey: "vimeo_link")
            let quality1080p = model.quality1080p?.url ?? ""
            user.setValue(quality1080p, forKey: "p1080")
            let quality720p = model.quality720p?.url ?? ""
            user.setValue(quality720p, forKey: "p720")
            let quality480p = model.quality480p?.url ?? ""
            user.setValue(quality480p, forKey: "p480")
            let quality360p = model.quality360p?.url ?? ""
            user.setValue(quality360p, forKey: "p360")
            let quality240p = model.quality240p?.url ?? ""
            user.setValue(quality240p, forKey: "p240")
            user.setValue(model.favorite, forKey: "favorite")
            user.setValue(model.shareablURL, forKey: "shareableurl")

        }
        
        //Now we have set all the values. The next step is to save them inside the Core Data
        
        do {
            try managedContext.save()
            callback.done(.success)
            startAnotherJob()
            NotificationCenter.default.post(name: Notification.Name("SyncFinished"), object: nil, userInfo: ["task":"1"])

        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    func resetAllRecords(in entity : String) // entity = Your_Entity_Name
    {
        
       /* let context = ( UIApplication.shared.delegate as! AppDelegate ).persistentContainer.viewContext
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        do
        {
            try context.execute(deleteRequest)
            try context.save()
        }
        catch
        {
            print ("There was an error")
        }*/
        
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
    
    
    func checkRecord()->Int {
        var count:Int = 0
        //As we know that container is set up in the AppDelegates so we need to refer that container.
        
        //We need to create a context from this container
        let manager = CoreDataManager.Instance

        let managedContext = manager.managedObjectContext
        
        //Prepare the request of type NSFetchRequest  for the entity
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Words")
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
    
    
    func startAnotherJob(){
        let jobmanager = SwiftQueueManagerBuilder(creator: AuthjobCreator()).build()
            JobBuilder(type: CategoriesJob.type)
                    // Requires internet to run
                    .internet(atLeast: .cellular)
                    // params of my job
                    .with(params: ["content": "Hello world"])
                    // Add to queue manager
                    .schedule(manager: jobmanager)
    }
    
    
    
    
    
}
