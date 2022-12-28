//
//  DictionaryViewController.swift
//  PSL
//
//  Created by MacBook on 26/03/2021.
//

import UIKit
import ScrollableSegmentedControl
import CoreData
import Alamofire
import AlamofireImage
import RSSelectionMenu
import DropDown
class DictionaryViewController: UIViewController,UITableViewDataSource, UITableViewDelegate,UISearchBarDelegate {
    @IBOutlet weak var parentSegementControl: ScrollableSegmentedControl!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var btnScrollUp: UIButton!
    var dataList = [CategoryModel]()
    var wordList = [DictionaryDatum]()
    var animationOn:Bool = false

    var sortAscending:Bool = true

    var carSectionTitles = [String]()
    var carSectionTitlesTemp = [String]()
    
    var carsDictionary = [String: [CategoryModel]]()
    var carsDictionaryTemp = [String: [CategoryModel]]()
    
    
    
    var carSectionTitlesWords = [String]()
    var carSectionTitlesWordsTemp = [String]()
    
    var carsDictionaryWords = [String: [DictionaryDatum]]()
    var carsDictionaryWordsTemp = [String: [DictionaryDatum]]()
    
    
    var IndexesTitlesWords = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]

    /*
     it
     */
    
    
    var offsetLimit =  100;
    var offsetLimitResult =  0;

    var simpleDataArray = ["Default", "Ascending", "Descending"]
    var simplesSelectedArray = [String]()
    
    public enum SelectionType {
        case Single        // default
        case Multiple
    }
    /*
     Image Cache
     */
    let imageCache = AutoPurgingImageCache( memoryCapacity: 111_111_111, preferredMemoryUsageAfterPurge: 90_000_000)
    fileprivate var activityIndicator: LoadMoreActivityIndicator!
    var dropButton = DropDown()
    var data: [String] = ["apple","appear","Azhar","code","BCom"]
    var dataFiltered: [String] = []
    
    var  isDropSelected = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        navigationItem.title = "Dictionary"

        setUpSearchBar()
        setupSegmentControl()
        setUpTableView()
        //loadAnimation()
        setUpCategoryData()
        DispatchQueue.global(qos: .background).async {
            self.offsetLimitResult  = self.checkoffset()
           
            self.getAllWords()
           
        }
    }
    override func viewWillAppear(_ animated: Bool) {
       super.viewWillAppear(animated)
       
       //AppUtility.lockOrientation(.portrait)
       // Or to rotate and lock
       // AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
       
   }

   override func viewWillDisappear(_ animated: Bool) {
       super.viewWillDisappear(animated)
       
       // Don't forget to reset when view is being removed
     //  AppUtility.lockOrientation(.all)
   }
    func setUpSearchBar(){
        self.hideKeyboardWhenTappedAround()
        searchBar.delegate = self
        searchBar.layer.cornerRadius = 5
        searchBar.clipsToBounds = true
        searchBar.searchBarStyle = .prominent // or default
        searchBar.searchTextPositionAdjustment = UIOffset(horizontal: 8.0, vertical: 0.0)
        if #available(iOS 13.0, *) {
            searchBar.searchTextField.font = UIFont(name: "Inter-Regular", size: 15.0)
            searchBar.searchTextField.tintColor = UIColor.black
            searchBar.searchTextField.borderStyle = .none
            
            searchBar.searchTextField.backgroundColor = UIColor.clear
            searchBar.searchTextField.returnKeyType = .done
            searchBar.searchTextField.layer.cornerRadius = 8
            searchBar.searchTextField.clipsToBounds = true;
            searchBar.backgroundImage = UIImage()
            searchBar.searchTextField.enablesReturnKeyAutomatically = false
        } else {
            // Fallback on earlier versions
            let textFieldInsideSearchBar = self.searchBar.value(forKey: "searchField") as! UITextField
            textFieldInsideSearchBar.font =  UIFont(name: "ProximaNova-Semibold", size: 15.0)
            textFieldInsideSearchBar.tintColor = UIColor.black
            textFieldInsideSearchBar.borderStyle = .none
            textFieldInsideSearchBar.backgroundColor = UIColor.clear
            textFieldInsideSearchBar.returnKeyType = .done
            textFieldInsideSearchBar.enablesReturnKeyAutomatically = false
            textFieldInsideSearchBar.layer.cornerRadius = 5
            textFieldInsideSearchBar.clipsToBounds = true
        }
        
        
        dropButton.anchorView = searchBar
        dropButton.bottomOffset = CGPoint(x: 0, y:(dropButton.anchorView?.plainView.bounds.height)!)
         dropButton.backgroundColor = UIColor.bothColor(lightMode: UICommonMethods.hexStringToUIColor(hex: "#FFFFFF"), darkMode: UICommonMethods.hexStringToUIColor(hex: "#282828"))
        dropButton.direction = .bottom
     
        dropButton.textColor = UIColor.bothColor(lightMode: UICommonMethods.hexStringToUIColor(hex: "#FFFFFF"), darkMode: UICommonMethods.hexStringToUIColor(hex: "#282828"))
        dropButton.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)") //Selected item: code at index: 0
         print(index)
         /*let mainstoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
         let newViewcontroller:SearchResultViewController  = mainstoryboard.instantiateViewController(withIdentifier: "SearchResultViewController") as! SearchResultViewController
         newViewcontroller.searchword = item
         self.navigationController?.pushViewController(newViewcontroller, animated: true)*/
            isDropSelected = true

         let mainstoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
         let newViewcontroller:PlayerViewController  = mainstoryboard.instantiateViewController(withIdentifier: "PlayerViewController") as! PlayerViewController
         newViewcontroller.selectType = UIContant.TYPE_DICTIONARY
         newViewcontroller.isSingleVideo = true
         newViewcontroller.videoName =  item
         
         self.navigationController?.pushViewController(newViewcontroller, animated: true)
         
        }
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
        activityIndicator = LoadMoreActivityIndicator(scrollView: tableView, spacingFromLastCell: 10, spacingFromLastCellWhenLoadMoreActionStart: 60)

    }
    func setUpCategoryData(){
        
        loadAnimation()
        DispatchQueue.global(qos: .background).async {
            
            let manager = CoreDataManager.Instance
            let mainContext = manager.managedObjectContext
                 
                 let privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
                 privateContext.parent = mainContext
              
                 privateContext.perform {
                    
                    self.dataList = self.getAllCategories(privateContext: privateContext)
                    
                    // Bounce back to the main thread to update the UI
                    for car in self.dataList {
                        let carKey = String(car.title?.prefix(1) ?? "")
                        if var carValues = self.carsDictionary[carKey] {
                            carValues.append(car)
                            self.carsDictionary[carKey] = carValues
                        } else {
                            self.carsDictionary[carKey] = [car]
                        }
                    }
                    
                    
                    
                    
                    self.carSectionTitles = [String](self.carsDictionary.keys)
                    self.carSectionTitles = self.carSectionTitles.sorted(by: { $0 < $1 })
                    self.carSectionTitlesTemp = self.carSectionTitles
                  
                    
                    
                    self.carsDictionaryTemp = self.carsDictionary
                    DispatchQueue.main.async {
                        //self.hideAnimation()
                        //  self.lblcontactsize.text = "All Contacts "+String(self.poc.count)+""
                        

                        self.hideAnimation()
                        if self.parentSegementControl.selectedSegmentIndex == 0{
                            self.tableView.reloadData()

                        }
                        // self.dataTableView.reloadData()
                    }
                 }
            
           
        }
        
        print(dataList.count)
    }
    
    
    
    func loadMoreItemsForList(){
          offsetLimit += 200
          setUpWordsData()
      }
    
    func setUpWordsData(){
        
       // loadAnimation()
        DispatchQueue.global(qos: .background).async {
            
            let manager = CoreDataManager.Instance
            let mainContext = manager.managedObjectContext
                 
                // let privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
               //  privateContext.parent = mainContext
              
               //  privateContext.perform {
                    var datalist  = [DictionaryDatum]()
                    
                    datalist  = self.getAllWordsOffset(privateContext: mainContext,offset:self.offsetLimit)
                    //self.wordList.append(contentsOf: datalist)
                    
                    print(datalist.count)
                    // Bounce back to the main thread to update the UI
                   
                    

          
 
                   
                    
                    //self.carSectionTitlesWords.append(contentsOf: [String](self.carsDictionaryWords.keys))
                 //   self.carSectionTitlesWords = self.carSectionTitlesWords.sorted(by: { $0 < $1 })
                    //self.carSectionTitlesWordsTemp.append(contentsOf: self.carSectionTitlesWords)
                    
                    
                    
                    

                    DispatchQueue.main.async {
                        //self.hideAnimation()
                        //  self.lblcontactsize.text = "All Contacts "+String(self.poc.count)+""
                        
                        for car in datalist {
                            let carKey = String(car.englishWord?.prefix(1) ?? "").localizedCapitalized
                            if var carValues = self.carsDictionaryWords[carKey] {
                                carValues.append(car)
                                self.carsDictionaryWords[carKey] = carValues
                            } else {
                                
                                
                                self.carSectionTitlesWords.append(carKey)
                                self.carSectionTitlesWordsTemp.append(carKey)
                                self.carsDictionaryWords[carKey] = [car]
                            }
                        }
                      self.carsDictionaryWordsTemp = self.carsDictionaryWords
                        
                        if self.parentSegementControl.selectedSegmentIndex == 1{
                            self.hideAnimation()
                            self.tableView.reloadData()

                        }
                        // self.dataTableView.reloadData()
                    }
               //  }
            
           
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
    func setupSegmentControl() {
        
        parentSegementControl.segmentStyle = .textOnly
        parentSegementControl.insertSegment(withTitle: "Categories", image:#imageLiteral(resourceName: "teachericon"), at: 0)
        parentSegementControl.insertSegment(withTitle: "Words", image: #imageLiteral(resourceName: "teachericon"), at: 1)
        parentSegementControl.underlineSelected = true
        parentSegementControl.segmentContentColor = UIColor(named: "labelcolor")
        parentSegementControl.selectedSegmentContentColor = UIColor(named: "AccentColor")
        parentSegementControl.tintColor = UIColor(named: "AccentColor")
        parentSegementControl.selectedSegmentIndex = 0
        parentSegementControl.fixedSegmentWidth = false
        parentSegementControl.addTarget(self, action: #selector(segmentSelected(sender:)), for: .valueChanged)
    }
    @objc func segmentSelected(sender:ScrollableSegmentedControl) {
        print("Segment at index \(sender.selectedSegmentIndex)  selected")
        parentSegementControl.selectedSegmentIndex = sender.selectedSegmentIndex
        switch sender.selectedSegmentIndex {
        case 0:
            
            print("category")
            self.offsetLimit =  0;

            self.tableView.reloadData()
            
        case 1:
            
            print("words")
            self.offsetLimit = self.offsetLimitResult;

            if carSectionTitlesWords.count == 0{
                loadAnimation()
            }
            self.carSectionTitlesWords.removeAll()
            self.carSectionTitlesWordsTemp.removeAll()
            self.carsDictionaryWords.removeAll()
            self.carsDictionaryWordsTemp.removeAll()

            self.setUpWordsData()

            self.tableView.reloadData()
            
            
        default:
            break
        }
        
    }
    
    @IBAction func onTappedSort(_ sender: Any) {
        // showAsAlertController(style: .actionSheet, title: "Select Sorting", action: nil, height: nil)
        selectSorting()
    }
    
    
    
    func getAllCategories(privateContext:NSManagedObjectContext)->[CategoryModel] {
        var dataList = [CategoryModel]()
        //As we know that container is set up in the AppDelegates so we need to refer that container.
       // guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return [CategoryModel]() }
        
        //We need to create a context from this container
      
        //Prepare the request of type NSFetchRequest  for the entity
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Categories")
        //let predicateID = NSPredicate(format: "id == %@","")
        //    fetchRequest.predicate = predicateID
        //        fetchRequest.fetchLimit = 1
        //        fetchRequest.predicate = NSPredicate(format: "username = %@", "Ankur")
        //        fetchRequest.sortDescriptors = [NSSortDescriptor.init(key: "email", ascending: false)]
        //
        do {
            let result = try privateContext.fetch(fetchRequest)
            for data in result as! [NSManagedObject] {
                
                let id = data.value(forKey: "id") as? Int
                let image = data.value(forKey: "image") as? String
                let title = data.value(forKey: "title") as? String
                let videos = data.value(forKey: "videos") as? Int
                let model = CategoryModel()
                model.id = id
                model.image = image
                model.title = title
                model.videos = videos
                
                dataList.append(model)
                
            }
            
        } catch {
            
            print("Failed")
        }
        
        return dataList
    }
    
    func getAllWords(privateContext:NSManagedObjectContext)->[DictionaryDatum] {
       
        let alhaallowed = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
          let numic = "1234567890"
        
        
        var dataList = [DictionaryDatum]()
        
        
        var aplhabeticOrder  = [DictionaryDatum]()
        
        var numericOrder = [DictionaryDatum]()
        var urduOrder = [DictionaryDatum]()

        //As we know that container is set up in the AppDelegates so we need to refer that container.
      //  guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return [DictionaryDatum]() }
        
        //We need to create a context from this container
  
        //Prepare the request of type NSFetchRequest  for the entity
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Words")
        //let predicateID = NSPredicate(format: "id == %@","")
        //    fetchRequest.predicate = predicateID
        //        fetchRequest.fetchLimit = 1
        //        fetchRequest.predicate = NSPredicate(format: "username = %@", "Ankur")
        //        fetchRequest.sortDescriptors = [NSSortDescriptor.init(key: "email", ascending: false)]
        //
        do {
            let result = try privateContext.fetch(fetchRequest)
            print(result.count)
            for data in result as! [NSManagedObject] {
                let title = data.value(forKey: "title") as? String
                let id = data.value(forKey: "id") as? Int
                let category_id = data.value(forKey: "category_id") as? Int
                let poster = data.value(forKey: "poster") as? String
                
                let english_word = data.value(forKey: "english_word") as? String
                
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
                
                let quality720p: NSMutableDictionary = NSMutableDictionary()
                quality720p.setValue("", forKey: "filesize")
                quality720p.setValue(p720, forKey: "url")
                 pocData.setObject(quality720p, forKey: "720p" as NSCopying)
                
                
                let quality480p: NSMutableDictionary = NSMutableDictionary()
                quality480p.setValue("", forKey: "filesize")
                quality480p.setValue(p480, forKey: "url")
                 pocData.setObject(quality480p, forKey: "480p" as NSCopying)
                
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
                    
                    
                    let key = String(title?.prefix(1) ?? "")
                    
                    if key.contains("-"){
                        urduOrder.append(dataReceived)
                    }else if numic.contains(key){
                        numericOrder.append(dataReceived)

                    }else{
                        aplhabeticOrder.append(dataReceived)

                    }


                    print(dataReceived)
                }
                
            }
            
        } catch {
            
            print("Failed")
        }
        
        dataList.append(contentsOf: aplhabeticOrder)
        dataList.append(contentsOf: numericOrder)
        dataList.append(contentsOf: urduOrder)

    
        return dataList
    }
    func checkoffset()-> Int{
        let manager = CoreDataManager.Instance
        let mainContext = manager.managedObjectContext
             
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Words")

        var subPredicates : [NSPredicate] = []

        
        let key = "english_word"                // the entity attribute
        let value = "-"   // the attribute value
        let predicate = NSPredicate(format: "%K == %@", argumentArray: [key, value])
        subPredicates.append(predicate)
        let numic = "0"
        let resultPredicate = NSPredicate(format: "english_word contains[cd] %@", numic)
        subPredicates.append(resultPredicate)
        request.predicate =  NSCompoundPredicate(type: .or, subpredicates: [predicate, resultPredicate])
        request.resultType = .countResultType

        var results: Int = 0

        do {

            results = try mainContext.count(for: request)
        }
        catch {

            let fetchError = error
            print(fetchError)
        }
        return results
    }
    
    func getAllWordsOffset(privateContext:NSManagedObjectContext,offset:Int)->[DictionaryDatum] {
       
        let alhaallowed = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
          let numic = "1234567890"
        
        
        var dataList = [DictionaryDatum]()
        
        
        var aplhabeticOrder  = [DictionaryDatum]()
        
        var numericOrder = [DictionaryDatum]()
        var urduOrder = [DictionaryDatum]()

        //As we know that container is set up in the AppDelegates so we need to refer that container.
      //  guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return [DictionaryDatum]() }
        
        //We need to create a context from this container
  
        //Prepare the request of type NSFetchRequest  for the entity
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Words")
        
        let searchString = "/^[a-zA-Z]+$/"
       // let predicate = NSPredicate(format: "english_word == %@",searchString)
        let sort = NSSortDescriptor(key: "english_word", ascending: sortAscending, selector: #selector(NSString.caseInsensitiveCompare(_:)))
        
       //fetchRequest.predicate = predicate

        fetchRequest.sortDescriptors = [sort]
        fetchRequest.fetchOffset = offset;
        fetchRequest.fetchLimit = 200;
        //let predicateID = NSPredicate(format: "id == %@","")
        //    fetchRequest.predicate = predicateID
        //        fetchRequest.fetchLimit = 1
        //        fetchRequest.predicate = NSPredicate(format: "username = %@", "Ankur")
        //        fetchRequest.sortDescriptors = [NSSortDescriptor.init(key: "email", ascending: false)]
        //
        do {
            let result = try privateContext.fetch(fetchRequest)
            for data in result as! [NSManagedObject] {
                let title = data.value(forKey: "title") as? String

                let id = data.value(forKey: "id") as? Int
                let category_id = data.value(forKey: "category_id") as? Int
                let poster = data.value(forKey: "poster") as? String
                
                let english_word = data.value(forKey: "english_word") as? String

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
                let shareablURL = data.value(forKey: "shareableurl") as? String

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
                pocData.setValue(shareablURL, forKey: "shareablURL")

                let quality1080p: NSMutableDictionary = NSMutableDictionary()
                quality1080p.setValue("", forKey: "filesize")
                quality1080p.setValue(p1080, forKey: "url")
                 pocData.setObject(quality1080p, forKey: "1080p" as NSCopying)
                
                let quality720p: NSMutableDictionary = NSMutableDictionary()
                quality720p.setValue("", forKey: "filesize")
                quality720p.setValue(p720, forKey: "url")
                 pocData.setObject(quality720p, forKey: "720p" as NSCopying)
                
                
                let quality480p: NSMutableDictionary = NSMutableDictionary()
                quality480p.setValue("", forKey: "filesize")
                quality480p.setValue(p480, forKey: "url")
                 pocData.setObject(quality480p, forKey: "480p" as NSCopying)
                
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
                    
                    
                    let key = String(title?.prefix(1) ?? "")
                    
                    if key.contains("-"){
                        urduOrder.append(dataReceived)
                    }else if numic.contains(key){
                        numericOrder.append(dataReceived)

                    }else{
                        aplhabeticOrder.append(dataReceived)

                    }


                }
                
            }
            
        } catch {
            
            print("Failed")
        }
        
        dataList.append(contentsOf: aplhabeticOrder)
        dataList.append(contentsOf: numericOrder)
        dataList.append(contentsOf: urduOrder)

    
        return dataList
    }

    
    
    
    /*
     Table View
     */
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if animationOn{
            return 1
        }else{
            if parentSegementControl.selectedSegmentIndex == 0{
                return carSectionTitles.count
            }else{
                return carSectionTitlesWords.count
            }
        }
       
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if animationOn{
            return 10
        }else{
            
      
        if parentSegementControl.selectedSegmentIndex == 0{
            let carKey = carSectionTitles[section]
            if let carValues = carsDictionary[carKey] {
                return carValues.count
            }
            
        }else if parentSegementControl.selectedSegmentIndex == 1{
            let carKey = carSectionTitlesWords[section]
            if let carValues = carsDictionaryWords[carKey] {
                print ("carsDictionaryWords \(carValues.count).")

                return carValues.count
            }
            
        }else{

            return 0
        }
        }

        return 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if animationOn{
           let identifier = "AnimatedContactTableViewCell"
           
           var cell: AnimatedContactTableViewCell! = tableView.dequeueReusableCell(withIdentifier: identifier) as? AnimatedContactTableViewCell
           
           if cell == nil {
               tableView.register(UINib(nibName: "AnimatedContactTableViewCell", bundle: nil), forCellReuseIdentifier: identifier)
               cell = (tableView.dequeueReusableCell(withIdentifier: identifier) as? AnimatedContactTableViewCell)!
           }
           cell.s1.startAnimating()
           cell.s2.startAnimating()
           cell.s3.startAnimating()
           cell.s4.startAnimating()
            cell.s5.startAnimating()
           cell.selectionStyle =  .none
           return cell
        }else{
        if parentSegementControl.selectedSegmentIndex == 0{
            let identifier = "DictionaryCategoryTableViewCell"
            
            var cell: DictionaryCategoryTableViewCell! = tableView.dequeueReusableCell(withIdentifier: identifier) as? DictionaryCategoryTableViewCell
            if cell == nil {
                tableView.register(UINib(nibName: "DictionaryCategoryTableViewCell", bundle: nil), forCellReuseIdentifier: identifier)
                cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? DictionaryCategoryTableViewCell
            }
            // Configure the cell...
            let carKey = carSectionTitles[indexPath.section]
            if let carValues = carsDictionary[carKey] {
                cell.lbltitle.text = carValues[indexPath.row].title
                cell.lbltotalCount.text = String(carValues[indexPath.row].videos ?? 0)+" Words"
                
            }
            cell.selectionStyle = .none

            return cell
        }else{
            
            
            
            let identifier = "WordsTableViewCell"
            
            var cell: WordsTableViewCell! = tableView.dequeueReusableCell(withIdentifier: identifier) as? WordsTableViewCell
            if cell == nil {
                tableView.register(UINib(nibName: "WordsTableViewCell", bundle: nil), forCellReuseIdentifier: identifier)
                cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? WordsTableViewCell
            }
            // Configure the cell...
            print(indexPath.section)

            let carKey = carSectionTitlesWords[indexPath.section]
            print(indexPath.row)
            print(carKey)
              
            if let carValues = carsDictionaryWords[carKey] {
                cell.lbltitle.text = carValues[indexPath.row].englishWord?.firstCharacterUpperCase()
                cell.lblCount.text = carValues[indexPath.row].urduWord ?? ""
                
            }
            cell.selectionStyle = .none
            return cell
        }
        
        }
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if animationOn{
            return 100
        }else{
            return 45

        }
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if animationOn{
            return ""
        }else{
            if parentSegementControl.selectedSegmentIndex == 0{
                return carSectionTitles[section]
                
            }else{
                return carSectionTitlesWords[section]
                
            }
        }
       
    }
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.bothColor(lightMode: UICommonMethods.hexStringToUIColor(hex: "#F2F2F2"), darkMode: UICommonMethods.hexStringToUIColor(hex: "#1D1D1D"))
        
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if parentSegementControl.selectedSegmentIndex == 0{
            
            
            let carKey = carSectionTitles[indexPath.section]
            if let carValues = carsDictionary[carKey] {
              
               let catId =  carValues[indexPath.row].id ?? 0
                let categoryName =  carValues[indexPath.row].title ?? ""
                navigateToNext(categoryId: catId, categoryName: categoryName)
                
            }
            
            
        }else{
            let carKey = carSectionTitlesWords[indexPath.section]
            if let carValues = carsDictionaryWords[carKey] {
              
             
                let selectedModel = carValues[indexPath.row]
                navigateToChild(selectedModel: selectedModel, list: carValues)
            }
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerFrame = tableView.frame
        
        let title = UILabel()
        title.frame =  CGRect(x: 15, y: 10, width: headerFrame.size.width-20, height: 20) //width equals to parent view with 10 left and right margin
        title.font = title.font.withSize(14)
        title.text = self.tableView(tableView, titleForHeaderInSection: section) //This will take title of section from 'titleForHeaderInSection' method or you can write directly
        title.textColor = UIColor.bothColor(lightMode: UICommonMethods.hexStringToUIColor(hex: "#000000"), darkMode: UICommonMethods.hexStringToUIColor(hex: "#FFFFFF"))
        
        let headerView:UIView = UIView(frame: CGRect(x: 0, y: 0, width: headerFrame.size.width, height: headerFrame.size.height))
        headerView.addSubview(title)
        headerView.backgroundColor = UIColor.bothColor(lightMode: UICommonMethods.hexStringToUIColor(hex: "#F2F2F2"), darkMode: UICommonMethods.hexStringToUIColor(hex: "#1D1D1D"))
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        
        
        if let c = cell as?  DictionaryCategoryTableViewCell{
            // c.photoImageView.af_setImage(withURL: url)
            var imageUrlString:String = ""
            let carKey = carSectionTitles[indexPath.section]
            if let carValues = carsDictionary[carKey] {
                imageUrlString = carValues[indexPath.row].image ?? ""
                
                
            }
            
            imageUrlString =  imageUrlString.removingPercentEncoding ?? ""
            if !imageUrlString.isEmpty{
                let imageRequest = URLRequest(url: URL(string: imageUrlString)!)
                let finalurl:String = imageUrlString.removingPercentEncoding ?? ""
                if let image = imageCache.image(withIdentifier: finalurl)
                {
                    c.img.image = image
                }else{
                    c.img.af_setImage(withURL: URL(string: finalurl)!, completion: { response in
                        switch response.result {
                        
                        case .success:
                            guard let image = response.value else { return }
                            c.img.image = image
                            self.imageCache.add(image, withIdentifier: finalurl)
                            
                        case .failure(let error):
                            print(error)
                            
                            
                        }
                        
                    })
                }
            }
            
        }
        
        if parentSegementControl.selectedSegmentIndex == 1{
            let searchtext = searchBar.text ?? ""

            
            if !searchtext.isEmpty{
                
            }else{
                let parentindex = carSectionTitlesWords.count - 1
                if indexPath.section == parentindex{
                    let carKey:String = carSectionTitlesWords[indexPath.section]
                         if let carValues = carsDictionaryWords[carKey]{
                            let lastItem = carValues.count  - 1
                            
                             
                             
                             
                            //print("Section:"+String(indexPath.section)+"|Row:"+String((indexPath.row))+"|Last:"+String(lastItem)+"|Titlesize:"+String(carSectionTitlesWords.count)+"|Content size"+String(carsDictionaryWords[carKey]?.count ?? 0))
                                 if indexPath.row == lastItem {
                                    // print("IndexRow\(indexPath.row)")
                                     loadMoreItemsForList()
                                 }
                         }
                
               /*
                }*/
               
               
            }
            }
         
        }
        
        
        
        
        
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
       let translation = scrollView.panGestureRecognizer.translation(in: scrollView.superview)
        if translation.y > 0 {
            // swipes from top to bottom of screen -> down
            print("top to bottom")
            btnScrollUp.isHidden =  false


        } else {
            // swipes from bottom to top of screen -> up
            print("bottom to top")
            btnScrollUp.isHidden =  true



        }
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
       

        if parentSegementControl.selectedSegmentIndex == 1{
            activityIndicator.start {
                       DispatchQueue.global(qos: .utility).async {
                           for i in 0..<3 {
                               print("!!!!!!!!! \(i)")
                               sleep(1)
                           }
                           DispatchQueue.main.async { [weak self] in
                               self?.activityIndicator.stop()
                           }
                       }
                   }
            
            
            
        }
       
    }
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        
        let searchtext = searchBar.text ?? ""
        
        if (searchtext.isEmpty){
            if parentSegementControl.selectedSegmentIndex == 0{
                return carSectionTitles
                
            }else{
                return IndexesTitlesWords
              

            }
       

        }else{
            return [String]()
        }
        
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        var finalindex:Int  = 0
        if parentSegementControl.selectedSegmentIndex == 1{
            
            getFilterResult(value: title)
            return 0
           
        }
        if let index1 = carSectionTitles.firstIndex(where: { $0 == title }) {
            finalindex =  index1//0 for a, 2 for b, 3 for c, 4 for d
        }
      
        return finalindex
    }
    
    func getFilterResult(value:String){
        carSectionTitlesWords.removeAll(keepingCapacity: false)
        carsDictionaryWords.removeAll(keepingCapacity: false)
       
        
        let filterTitlesWords = [value]
        var filterWords = [String: [DictionaryDatum]]()
        var datalist  = [DictionaryDatum]()
        
        datalist = getSpecficWords(searchTerm: value)
        
        for car in datalist {
            let carKey = String(car.englishWord?.prefix(1) ?? "").localizedCapitalized
            if var carValues = filterWords[carKey] {
                carValues.append(car)
               filterWords[carKey] = carValues
            } else {
                
                
                
                filterWords[carKey] = [car]
            }
        }
        
        
        
        
        
        carsDictionaryWords =  filterWords
        carSectionTitlesWords =  filterTitlesWords
        searchBar.text =  value
        tableView.reloadData()
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
       // searchBar.setShowsCancelButton(true, animated: true)
        for ob: UIView in ((searchBar.subviews[0] )).subviews {
            if let z = ob as? UIButton {
                let btn: UIButton = z
                btn.setTitleColor(UIColor.white, for: .normal)
            }
        }
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        //searchBar.showsCancelButton = false
        if parentSegementControl.selectedSegmentIndex == 1{
            let searchText = searchBar.text ?? ""
            if !searchText.isEmpty{
                dropButton.hide()
                if isDropSelected{
                    isDropSelected = false
                }else{
                   
                }
                
                
            }else{
                dropButton.hide()
                searchBar.resignFirstResponder()

            }
        }
       
       
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.text = ""
        dataFiltered = data
        dropButton.hide()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        if  (searchText == "")
        {
            
            if parentSegementControl.selectedSegmentIndex == 0{
                carSectionTitles.removeAll(keepingCapacity: false)
                carsDictionary.removeAll(keepingCapacity: false)
                carsDictionary =  carsDictionaryTemp
                carSectionTitles =  carSectionTitlesTemp
                
                
                
            }else{
                carSectionTitlesWords.removeAll(keepingCapacity: false)
                carsDictionaryWords.removeAll(keepingCapacity: false)
                carsDictionaryWords =  carsDictionaryWordsTemp
                carSectionTitlesWords =  carSectionTitlesWordsTemp
                
                dropButton.hide()
                
            }
            
            tableView.reloadData()
            
            
            
            
        }else
        {
            
            if parentSegementControl.selectedSegmentIndex == 0{
                carsDictionary.removeAll(keepingCapacity: false)
                let predicateString = searchBar.text!
                
                
                carSectionTitles =  ["Results"]
                var filterList =  dataList.filter({$0.title?.range(of: predicateString, options: .caseInsensitive) != nil})
                filterList.sort {$0.title ?? "" < $1.title ?? ""}
                self.carsDictionary = ["Results":filterList]
                
                
                
            }else{
              /*  carsDictionaryWords.removeAll(keepingCapacity: false)
                
                let predicateString = searchBar.text!
                
                carSectionTitlesWords =  ["Results"]
                var filterList =  wordList.filter({$0.englishWord?.range(of: predicateString, options: .caseInsensitive) != nil})
                filterList.sort {$0.title ?? "" < $1.title ?? ""}
                carsDictionaryWords = ["Results":filterList]*/
                
                dataFiltered = searchText.isEmpty ? data : data.filter({ (dat) -> Bool in
                       dat.range(of: searchText, options: .caseInsensitive) != nil
                   })
                let letterA = searchText.suffix(0)
               // dataFiltered = dataFiltered.filter({ $0.first == letterA)
                let sorted = dataFiltered.filter({ ($0.hasPrefix(String(letterA)))}).sorted { $0 < $1}

                 dropButton.dataSource = sorted
                   dropButton.show()
                
            }
            
            
            tableView.reloadData()
            
            
        }
    }
    
    /*
     Sorting
     */
    func showAsAlertController(style: UIAlertController.Style, title: String?, action: String?, height: Double?) {
        let selectionType: SelectionType = style == .alert ? .Single : .Multiple
        
        let selectionMenu =  RSSelectionMenu(selectionStyle: .single, dataSource: simpleDataArray) { (cell, name, indexPath) in
            cell.textLabel?.text = name
            cell.tintColor = UICommonMethods.hexStringToUIColor(hex: "#009E4F")
            
        }
        selectionMenu.dismissAutomatically = true
        
        selectionMenu.setSelectedItems(items: simplesSelectedArray) { [weak self] (item, index, isSelected, selectedItems) in
            
            // update your existing array with updated selected items, so when menu show menu next time, updated items will be default selected.
            self?.simplesSelectedArray = selectedItems
            print("hello"+String(selectedItems.count))
            if(selectedItems.count > 0){
                let textStr = selectedItems[0]
                self?.sortArray(textStr: textStr)
            }
            
            //   self?.lblFilter.text =
        }
        
        
        selectionMenu.onDismiss = { items in
            self.simplesSelectedArray = items
            if self.presentedViewController as? UIAlertController != nil {
                selectionMenu.dismiss()
            }
            
            //print("hello"+String(self.simplesSelectedArray.count))
            
        }
        selectionMenu.show(style: .actionSheet(title: nil, action: "Done", height:(Double(simpleDataArray.count) * 50)), from: self)
        
        // show
        
    }
    
    
    func sortArray(textStr:String){
        if  textStr == "Default"{
            
            
            
            carSectionTitles =  carSectionTitlesTemp
            carSectionTitlesWords = carSectionTitlesWordsTemp
        }else if textStr == "Ascending"{
            

            carSectionTitles =  carSectionTitlesTemp.sorted { (channel1, channel2) -> Bool in
                let channelName1 = channel1
                let channelName2 = channel2
                return (channelName1.localizedCaseInsensitiveCompare(channelName2) == .orderedAscending)}
            
            carSectionTitlesWords =  carSectionTitlesWords.sorted { (channel1, channel2) -> Bool in
                let channelName1 = channel1
                let channelName2 = channel2
                return (channelName1.localizedCaseInsensitiveCompare(channelName2) == .orderedAscending)}
            IndexesTitlesWords =  IndexesTitlesWords.sorted{ (channel1, channel2) -> Bool in
                let channelName1 = channel1
                let channelName2 = channel2
                return (channelName1.localizedCaseInsensitiveCompare(channelName2) == .orderedAscending)}
            
        }else if textStr == "Descending"{

            carSectionTitles =  carSectionTitlesTemp.sorted { (channel1, channel2) -> Bool in
                let channelName1 = channel1
                let channelName2 = channel2
                return (channelName1.localizedCaseInsensitiveCompare(channelName2) == .orderedDescending)}
            carSectionTitlesWords =  carSectionTitlesWords.sorted { (channel1, channel2) -> Bool in
                let channelName1 = channel1
                let channelName2 = channel2
                return (channelName1.localizedCaseInsensitiveCompare(channelName2) == .orderedDescending)}
            IndexesTitlesWords =  IndexesTitlesWords.sorted{ (channel1, channel2) -> Bool in
                let channelName1 = channel1
                let channelName2 = channel2
                return (channelName1.localizedCaseInsensitiveCompare(channelName2) == .orderedDescending)}
        }
        
        
        tableView.reloadData()
        
    }
    
    func navigateToNext(categoryId:Int, categoryName:String){
        let mainstoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewcontroller:ChildMedaitorViewController  = mainstoryboard.instantiateViewController(withIdentifier: "ChildMedaitorViewController") as! ChildMedaitorViewController
        newViewcontroller.selectType = UIContant.TYPE_DICTIONARY
        newViewcontroller.categoryId = categoryId
        newViewcontroller.categoryName =  categoryName
        self.navigationController?.pushViewController(newViewcontroller, animated: true)
    }
    func navigateToChild(selectedModel:DictionaryDatum,list:[DictionaryDatum]){
        let mainstoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewcontroller:PlayerViewController  = mainstoryboard.instantiateViewController(withIdentifier: "PlayerViewController") as! PlayerViewController
        newViewcontroller.selectType = UIContant.TYPE_DICTIONARY
        newViewcontroller.selectedDataModel =  selectedModel
        newViewcontroller.dictionaryCategories = list
        self.navigationController?.pushViewController(newViewcontroller, animated: true)
    }
    
    
    func selectSorting(){
        let optionMenu = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .actionSheet)
        
        
        optionMenu.view.tintColor  = UICommonMethods.hexStringToUIColor(hex: "#009E4F")

       // if let p240 =  selectedDataModel?.quality240p?.url{
            let deleteAction1 = UIAlertAction(title: "Alphabetically: A-Z", style: .default, handler:
                                                { [self]
                (alert: UIAlertAction!) -> Void in
                
                
                self.sortAscending = true

               // if self.parentSegementControl.selectedSegmentIndex == 1{
                self.offsetLimit = self.offsetLimitResult
                    self.carSectionTitlesWords.removeAll()
                self.carSectionTitlesWordsTemp.removeAll()

                    self.carsDictionaryWords.removeAll()
                    self.carsDictionaryWordsTemp.removeAll()
                    self.setUpWordsData()
                   // self.sortArray(textStr: "Descending")

                //}else{
                    self.sortArray(textStr: "Ascending")

               // }
                
                
               
            })
            optionMenu.addAction(deleteAction1)

       // }
        
            let deleteAction2 = UIAlertAction(title: "Alphabetically: Z-A", style: .default, handler:
            {
                (alert: UIAlertAction!) -> Void in
              //  let p240:String =  self.selectedDataModel?.quality240p?.url ?? ""
                self.sortAscending = false

               // if self.parentSegementControl.selectedSegmentIndex == 1{
                    self.offsetLimit = 0
                    self.sortAscending = false
                    self.carSectionTitlesWords.removeAll()
                    self.carSectionTitlesWordsTemp.removeAll()

                    self.carsDictionaryWords.removeAll()
                    self.carsDictionaryWordsTemp.removeAll()
                    self.setUpWordsData()
                   // self.sortArray(textStr: "Descending")

               // }else{
                    self.sortArray(textStr: "Descending")

               // }
                
              
            })
        
            optionMenu.addAction(deleteAction2)

        
        
      
        
       
        
       
       
        

         

        let cancelAction = UIAlertAction(title: "Cancel", style:.cancel, handler:
        {
            (alert: UIAlertAction!) -> Void in
        })
        
        cancelAction.setValue(UIColor.red, forKey: "titleTextColor")

        
           optionMenu.addAction(cancelAction)
          

        self.present(optionMenu, animated: true, completion: nil)
    }
   
    func loadAnimation(){
       animationOn = true
        tableView.reloadData()
    }
    func hideAnimation(){
        animationOn = false
      // dataTableView.reloadData()
    }
    
    
    
    
    
    func getSpecficWords(searchTerm:String)->[DictionaryDatum] {
        var dataList = [DictionaryDatum]()
        //As we know that container is set up in the AppDelegates so we need to refer that container.
      //  guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return [DictionaryDatum]() }
        
        //We need to create a context from this container
        let manager = CoreDataManager.Instance
        let mainContext = manager.managedObjectContext
             
             
                
                //Prepare the request of type NSFetchRequest  for the entity
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Words")
              //  let pattern = ".*\\b\(NSRegularExpression.escapedPattern(for: searchTerm))\\b.*"
             //   let predicateID = NSPredicate(format: "tagName MATCHES[c] %@", pattern)
                let predicate = NSPredicate(format: "english_word BEGINSWITH[c] %@", searchTerm)
                let sort = NSSortDescriptor(key: "english_word", ascending: sortAscending, selector: #selector(NSString.caseInsensitiveCompare(_:)))
                fetchRequest.predicate = predicate
               fetchRequest.sortDescriptors  =  [sort]
        
                
                //    fetchRequest.predicate = predicateID
                //        fetchRequest.fetchLimit = 1
                //        fetchRequest.predicate = NSPredicate(format: "username = %@", "Ankur")
                //        fetchRequest.sortDescriptors = [NSSortDescriptor.init(key: "email", ascending: false)]
                //
                do {
                    let result = try mainContext.fetch(fetchRequest)
                    //print(result.count)
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
                            let shareablURL = data.value(forKey: "shareableurl") as? String

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
                        pocData.setValue(shareablURL, forKey: "shareablURL")

                            
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
                    
                } catch {
                    
                    print("Failed")
                }
                
             
       
        
        return dataList
    }
    
    
    
    func getAllWords()->[String] {
        var dataList = [String]()
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
                
                do {
                    let result = try privateContext.fetch(fetchRequest)
                    print(result.count)
                    for datastr in result as! [NSManagedObject] {
                        
                      
                        if let english_word = datastr.value(forKey: "english_word") as? String{
                            if !english_word.isEmpty {
                                dataList.append(english_word)
                            }
                        }
                        
                       
                    }
                    
                   
                    
                   

                    DispatchQueue.main.async {
                        
                        print("hello")
                        self.data =  dataList
                        self.dataFiltered = self.data

                        //self.hideAnimation()
                        //  self.lblcontactsize.text = "All Contacts "+String(self.poc.count)+""
                        

                        // self.dataTableView.reloadData()
                    }
                    
                } catch {
                    
                    print("Failed")
                }
             }
        
       
        
        return dataList
    }
    
    @IBAction func onTappedScrollUp(_ sender: Any) {
        
        scrollToTop()
        btnScrollUp.isHidden =  true
        
    }
    
    private func scrollToTop() {
        // 1
        let topRow = IndexPath(row: 0,
                               section: 0)
                               
        // 2
        self.tableView.scrollToRow(at: topRow,
                                   at: .top,
                                   animated: true)
        
        

    }
}
