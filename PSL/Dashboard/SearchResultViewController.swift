//
//  SearchResultViewController.swift
//  PSL
//
//  Created by MacBook on 03/04/2021.
//

import UIKit
import CoreData
import AlamofireImage
class SearchResultViewController: UIViewController,UISearchResultsUpdating,UITableViewDataSource, UITableViewDelegate {
    let searchController = UISearchController(searchResultsController: nil)
    var searchword:String = ""
    var dictionaryCategories = [DictionaryDatum]()
    var dictionaryCategoriesTemp = [DictionaryDatum]()

    let imageCache = AutoPurgingImageCache( memoryCapacity: 111_111_111, preferredMemoryUsageAfterPurge: 90_000_000)

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        
        navigationItem.title = searchword

        // Do any additional setup after loading the view.
        


        setUpData()
    }
    
    func setUpsearchController(){
    //    self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Oswald-Bold", size: 20)!]
       // self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Oswald-Bold", size: 30)!]
        navigationController?.navigationBar.prefersLargeTitles = true
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Video"
        navigationItem.searchController = searchController
        //navigationItem.hidesSearchBarWhenScrolling = true
        searchController.searchBar.sizeToFit()
    }
    
    func setUpTableView(){
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .singleLine
        self.tableView.estimatedRowHeight = 100
        self.tableView.separatorInset = .zero
        self.tableView.layoutMargins = .zero
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.isEmptyRowsHidden =  true
        // collectionView?.contentInsetAdjustmentBehavior = .always
        // collectionView?.collectionViewLayout = collectionViewLayout
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.view.setNeedsLayout() // force update layout
        navigationController?.view.layoutIfNeeded() // to fix height of the navigation bar
    }
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        print(text)
        if  (text == "")
        {
            dictionaryCategories.removeAll(keepingCapacity: false)
            dictionaryCategories =  dictionaryCategoriesTemp
            tableView.reloadData()
            
            
            
        }else
        {
            
            
            dictionaryCategories.removeAll(keepingCapacity: false)
            let predicateString = text
            dictionaryCategories = dictionaryCategoriesTemp.filter({$0.englishWord?.range(of: predicateString, options: .caseInsensitive) != nil})
            dictionaryCategories.sort {$0.englishWord ?? "" < $1.englishWord ?? "" }
            
            tableView.reloadData()

            
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dictionaryCategories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let identifier = "ChildMedaitorTableViewCell"
        
        var cell: ChildMedaitorTableViewCell! = tableView.dequeueReusableCell(withIdentifier: identifier) as? ChildMedaitorTableViewCell
        if cell == nil {
            tableView.register(UINib(nibName: "ChildMedaitorTableViewCell", bundle: nil), forCellReuseIdentifier: identifier)
            cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? ChildMedaitorTableViewCell
        }
        
        var headingName: String = ""
        var subHeadingName: String = ""
        var duration: String = ""
        
        var imgStr: String = ""
        headingName =  dictionaryCategories[indexPath.row].englishWord ?? ""
        subHeadingName =  dictionaryCategories[indexPath.row].urduWord ?? ""
        duration = dictionaryCategories[indexPath.row].duration ?? ""
        
        
        cell.lblTitleEnglish.text =  headingName
        cell.lblTitleUrdu.text = subHeadingName
        cell.lblDuration.text =  duration
        cell.typeImage.layer.cornerRadius = 8.0
        cell.typeImage.clipsToBounds = true
        cell.selectionStyle = .none
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        let dataModel = dictionaryCategories[indexPath.row]
        navigateToChild(selectedModel: dataModel, list: dictionaryCategories)
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        
        
        if let c = cell as?  ChildMedaitorTableViewCell{
            print("Downloading Image")
            // c.photoImageView.af_setImage(withURL: url)
            var imageUrlString:String = dictionaryCategories[indexPath.row].poster ?? ""
            
            imageUrlString =  imageUrlString.removingPercentEncoding ?? ""
            if !imageUrlString.isEmpty{
                let imageRequest = URLRequest(url: URL(string: imageUrlString)!)
                let finalurl:String = imageUrlString.removingPercentEncoding ?? ""
                if let image = imageCache.image(withIdentifier: finalurl)
                {
                    c.typeImage.image = image
                }else{
                    c.typeImage.af_setImage(withURL: URL(string: finalurl)!, completion: { response in
                        switch response.result {
                        
                        case .success:
                            guard let image = response.value else { return }
                            c.typeImage.image = image
                            
                            
                            self.imageCache.add(image, withIdentifier: finalurl)
                            
                        case .failure(let error):
                            print(error)
                            
                            
                        }
                        
                    })
                }
            }
            
        }
        
        
        
        
        
        
    }
    
    
    func setUpData(){
        
        
       // DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            DispatchQueue.global(qos: .background).async { [self] in
               getAllWords(searchTerm: searchword)
                
                
               
          //  }
        }
        
        
    }
    func getAllWords(searchTerm:String)->[DictionaryDatum] {
        var dataList = [DictionaryDatum]()
        //As we know that container is set up in the AppDelegates so we need to refer that container.
      //  guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return [DictionaryDatum]() }
        
        //We need to create a context from this container
        let manager = CoreDataManager.Instance
        let mainContext = manager.managedObjectContext
             
             let privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
             privateContext.parent = mainContext
          
             privateContext.perform {
                
                //Prepare the request of type NSFetchRequest  for the entity
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Words")
              //  let pattern = ".*\\b\(NSRegularExpression.escapedPattern(for: searchTerm))\\b.*"
             //   let predicateID = NSPredicate(format: "tagName MATCHES[c] %@", pattern)
                let predicate = NSPredicate(format: "english_word contains[c] %@", searchTerm)
                fetchRequest.predicate = predicate
                
                //    fetchRequest.predicate = predicateID
                //        fetchRequest.fetchLimit = 1
                //        fetchRequest.predicate = NSPredicate(format: "username = %@", "Ankur")
                //        fetchRequest.sortDescriptors = [NSSortDescriptor.init(key: "email", ascending: false)]
                //
                do {
                    let result = try privateContext.fetch(fetchRequest)
                    print(result.count)
                    for data in result as! [NSManagedObject] {
                        
                        let id = data.value(forKey: "id") as? Int
                        let category_id = data.value(forKey: "category_id") as? Int
                        let poster = data.value(forKey: "poster") as? String
                        
                        let english_word = data.value(forKey: "english_word") as? String
                     
                        print(searchTerm.suffix(0))
                        if (english_word != "-" &&  english_word?.suffix(0) == searchTerm.suffix(0)){
                            
                        
                        let urdu_word = data.value(forKey: "urdu_word") as? String
                        
                        let filename = data.value(forKey: "filename") as? String
                        
                        let youtube_link = data.value(forKey: "youtube_link") as? String
                        
                        let vimeo_link = data.value(forKey: "vimeo_link") as? String
                        
                        let p1080 = data.value(forKey: "p1080") as? String
                        
                        let p720 = data.value(forKey: "p720") as? String
                        
                        let p480 = data.value(forKey: "p480") as? String
                        let p360 = data.value(forKey: "p360") as? String
                        let p240 = data.value(forKey: "p240") as? String
                        let favorite = data.value(forKey: "favorite") as? Int
                       
                        let pocData: NSMutableDictionary = NSMutableDictionary()
                        pocData.setValue(category_id ?? 0, forKey: "category_id")
                        pocData.setValue("", forKey: "duration")
                        pocData.setValue(english_word ?? "", forKey: "english_word")
                        pocData.setValue(favorite ?? 0, forKey: "favorite")
                        pocData.setValue(filename ?? "", forKey: "filename")
                        pocData.setValue(id ?? 0, forKey: "id")
                        pocData.setValue(poster ?? "", forKey: "poster")
                        pocData.setValue(urdu_word ?? "", forKey: "urdu_word")
                        pocData.setValue(vimeo_link ?? "", forKey: "vimeo_link")
                        pocData.setValue(youtube_link ?? "", forKey: "youtube_link")
                        pocData.setValue("", forKey: "title")
                        pocData.setValue(0, forKey: "grade_id")
                        pocData.setValue(0, forKey: "subject_id")
                        
                            
                            let quality1080p: NSMutableDictionary = NSMutableDictionary()
                            quality1080p.setValue("", forKey: "filesize")
                            quality1080p.setValue(p1080, forKey: "url")

                            pocData.setObject(quality1080p, forKey: "1080p" as NSCopying)
                            
                            
                            
                            let qualityp720: NSMutableDictionary = NSMutableDictionary()
                            qualityp720.setValue("", forKey: "filesize")
                            qualityp720.setValue(p720, forKey: "url")

                            pocData.setObject(qualityp720, forKey: "720p" as NSCopying)
                            
                            
                            let qualityp480: NSMutableDictionary = NSMutableDictionary()
                            qualityp480.setValue("", forKey: "filesize")
                            qualityp480.setValue(p480, forKey: "url")

                            pocData.setObject(qualityp480, forKey: "480p" as NSCopying)
                            
                            
                            let quality360p: NSMutableDictionary = NSMutableDictionary()
                            quality360p.setValue("", forKey: "filesize")
                            quality360p.setValue(p360, forKey: "url")

                            pocData.setObject(quality360p, forKey: "360p" as NSCopying)
                            
                            
                            
                            let quality240p: NSMutableDictionary = NSMutableDictionary()
                            quality240p.setValue("", forKey: "filesize")
                            quality240p.setValue(p240, forKey: "url")

                            pocData.setObject(quality240p, forKey: "240p" as NSCopying)
                            
                        
                        if let theJSONData = try? JSONSerialization.data(
                             withJSONObject: pocData,
                             options: []) {
                             let theJSONText = String(data: theJSONData,
                                                        encoding: .utf8)
                           //  print("JSON string = \(theJSONText!)")
                            

                         let jsonData = theJSONText?.data(using: .utf8, allowLossyConversion: false)!
                            let dataReceived = try JSONDecoder().decode(DictionaryDatum.self, from: jsonData!)
                            dataList.append(dataReceived)

                            print(dataReceived)
                        }
                        
                    }
                    }
                    
                    let dataFiltered = dataList
                    let letterA = self.searchword.suffix(0)
                    let sorted = dataFiltered.filter({ ($0.englishWord?.hasPrefix(String(letterA)))!}).sorted { $0.englishWord ?? "" < $1.englishWord ?? ""}

                    self.dictionaryCategories = sorted
                    
                    self.dictionaryCategoriesTemp = self.dictionaryCategories
                    
                    DispatchQueue.main.async {
                      
                        
                        
                        self.setUpTableView()
                        self.setUpsearchController()
                    }
                   
                    
                } catch {
                    
                    print("Failed")
                }
                
             }
       
        
        return dataList
    }
    
    func navigateToChild(selectedModel:DictionaryDatum,list:[DictionaryDatum]){
        let mainstoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewcontroller:PlayerViewController  = mainstoryboard.instantiateViewController(withIdentifier: "PlayerViewController") as! PlayerViewController
        newViewcontroller.selectType = UIContant.TYPE_DICTIONARY
        newViewcontroller.selectedDataModel =  selectedModel
        newViewcontroller.dictionaryCategories = list
        self.navigationController?.pushViewController(newViewcontroller, animated: true)
    }
}
