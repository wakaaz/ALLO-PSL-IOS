//
//  HomeViewController.swift
//  PSL
//
//  Created by MacBook on 04/03/2021.
//

import UIKit
import DropDown
import  CoreData
class HomeViewController: UIViewController,UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var loadingView: UIView!
    var array = [["Swift", false, 0], ["teste", false, 1], ["linguagem", false, 2], ["objectivec", false, 3]]
    var data: [String] = ["apple","appear","Azhar","code","BCom"]
    var dataFiltered: [String] = []
    var dropButton = DropDown()

    var  isDropSelected = false
    
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var btnViewAll: UIButton!
    
    let yourAttributes: [NSAttributedString.Key: Any] = [
        .font: UIFont(name: "Inter-Bold",size: 10.0),
        .foregroundColor: UICommonMethods.hexStringToUIColor(hex: "#009E4F"),
          .underlineStyle: NSUnderlineStyle.single.rawValue
      ] // .double.rawValue, .thick.rawValue
          
   
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        let nc = NotificationCenter.default
        nc.addObserver(forName: Notification.Name(rawValue: "SyncFinished"), object: nil, queue: nil, using: viewDidReceiveNotification)
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
          
        let nc = NotificationCenter.default
        nc.removeObserver(self, name: Notification.Name("SyncFinished"), object: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let count  =  checkRecord()
        if count < 100{
            loadingView.isHidden = false
        }else{
            loadingView.isHidden = true

        }
        print(checkRecord())
        self.hideKeyboardWhenTappedAround()
         let text  = "SEARCH FROM\nMORE THEN 6,000\nPSL DICTIONARY\nWORDS"
        // Do any additional setup after loading the view.
        stepUpSearchBar()
        var myMutableString = NSMutableAttributedString()
        myMutableString = NSMutableAttributedString(string: text, attributes: [NSAttributedString.Key.font:UIFont(name: "Inter-Bold", size: 14.0)!])

        myMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: UICommonMethods.hexStringToUIColor(hex: "#009E4F"), range: NSRange(location:22,length:20))
        
        // set label Attribute
        lblTitle.attributedText = myMutableString
        let attributeString = NSMutableAttributedString(
              string: "View All",
              attributes: yourAttributes
           )
        btnViewAll.setAttributedTitle(attributeString, for: .normal)
        DispatchQueue.global(qos: .background).async {
            
            self.getAllWords()
           
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
    
    func viewDidReceiveNotification(notification: Notification) -> Void
    {
        if (notification.name.rawValue == "SyncFinished")
        {
            
            if let userInfo = (notification.userInfo ?? nil ) as? [String: Any] // or use if you know the type  [AnyHashable : Any]
            {
                 print(userInfo)

              if let progressValue = userInfo["task"] as? String {
                if progressValue  == "0"{
                    loadingView.isHidden  =  false

                }
                if progressValue  == "1"{
                    DispatchQueue.global(qos: .background).async {
                        
                        self.getAllWords()
                       
                    }
                    loadingView.isHidden  =  true
                    
                    

                }
              }
            }
            
        }
    }
    
    func stepUpSearchBar(){
        searchBar.delegate = self
        searchBar.layer.cornerRadius = 5
        searchBar.clipsToBounds = true

        searchBar.searchBarStyle = .prominent // or default
        searchBar.searchTextPositionAdjustment = UIOffset(horizontal: 8.0, vertical: 0.0)
        searchBar.keyboardType = .default
        if #available(iOS 13.0, *) {
            searchBar.searchTextField.font = UIFont(name: "Inter-Regular", size: 15.0)
            searchBar.searchTextField.tintColor = UIColor.black
            searchBar.searchTextField.borderStyle = .none
        
            searchBar.searchTextField.backgroundColor = UIColor.clear
            searchBar.searchTextField.returnKeyType = .search
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
        if let searchTextField = self.searchBar.value(forKey: "searchField") as? UITextField , let clearButton = searchTextField.value(forKey: "_clearButton")as? UIButton {

             clearButton.addTarget(self, action: #selector(self.crosstapped), for: .touchUpInside)
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
    @objc func crosstapped(){
        searchBar.text =  ""
        searchBar.resignFirstResponder()
    }
    
    
    @IBAction func onTappedDictionary(_ sender: Any) {
      //  navigateToNext(selectType: UIContant.TYPE_DICTIONARY)
        navigateToDic()
    }
    @IBAction func onTappedTeacherTutorail(_ sender: Any) {
        navigateToNext(selectType: UIContant.TYPE_TEACHER)
    }
    
    @IBAction func onTappedStories(_ sender: Any) {
        navigateToNext(selectType: UIContant.TYPE_STORIES)
    }
    @IBAction func onTappedLearningTutorail(_ sender: Any) {
        navigateToNext(selectType: UIContant.TYPE_LEARNING)
    }
    
    @IBAction func onTappedLifeSkill(_ sender: Any) {
        navigateToNext(selectType: UIContant.TYPE_SKILL)

    }
    
    func navigateToNext(selectType :Int){
        let mainstoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewcontroller:MedaitorViewController  = mainstoryboard.instantiateViewController(withIdentifier: "MedaitorViewController") as! MedaitorViewController
        newViewcontroller.selectType = selectType
        self.navigationController?.pushViewController(newViewcontroller, animated: true)
    }
    func navigateToDic() {
        
        let mainstoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewcontroller:DictionaryViewController  = mainstoryboard.instantiateViewController(withIdentifier: "DictionaryViewController") as! DictionaryViewController
        self.navigationController?.pushViewController(newViewcontroller, animated: true)
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        if searchText == "" {
               print("UISearchBar.text cleared!")
        }else{
            // filter array with string that start with searchText
           //  tableView.reloadData()
           dataFiltered = searchText.isEmpty ? data : data.filter({ (dat) -> Bool in
                  dat.range(of: searchText, options: .caseInsensitive) != nil
              })
           let letterA = searchText.suffix(0)
          // dataFiltered = dataFiltered.filter({ $0.first == letterA)
           let sorted = dataFiltered.filter({ ($0.hasPrefix(String(letterA)))}).sorted { $0 < $1}

            dropButton.dataSource = sorted
              dropButton.show()
        }
        
         
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

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.text = ""
        dataFiltered = data
        dropButton.hide()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        let mainstoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewcontroller:SearchResultViewController  = mainstoryboard.instantiateViewController(withIdentifier: "SearchResultViewController") as! SearchResultViewController
        newViewcontroller.searchword = searchBar.text ?? ""
        self.navigationController?.pushViewController(newViewcontroller, animated: true)
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
    
    
    @IBAction func onTappedViewAll(_ sender: Any) {
        
        
        if loadingView.isHidden{
            navigateToDic()
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
}
