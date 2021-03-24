//
//  ChildMedaitorViewController.swift
//  PSL
//
//  Created by MacBook on 24/03/2021.
//

import UIKit
import Alamofire
import AlamofireImage
import RSSelectionMenu

class ChildMedaitorViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    /*
     Data Pervious Screen
     */
    
    var selectType:Int = 0
    var categoryId :Int = 0
    var categoryName: String = ""
    var  subCategoryId: Int = 0
    
    
    
    /*
     Type of Data
     */
    var dictionaryCategories  =  [DictionaryDatum]()
    var learningTutGrades  =  [LearningTutGrade]()
    var lifeSkills = [LifeSkill]()
    var storyTypes = [StoryType]()
    var tutGrades = [TutGrade]()
    
    /*
     Image Cache
     */
    let imageCache = AutoPurgingImageCache( memoryCapacity: 111_111_111, preferredMemoryUsageAfterPurge: 90_000_000)
    
    
    /*
     
     */
    
    var simpleDataArray = ["Default", "Ascending", "Descending"]
    var simplesSelectedArray = [String]()
    public enum SelectionType {
        case Single        // default
        case Multiple
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setUpTitle()
        setUpSearchBar()
        setUpTableView()
        requestPayload()
    }
    
    func setUpTitle(){
        navigationItem.title = categoryName
    }
    
    func setUpSearchBar(){
        simplesSelectedArray.append("Default")
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
    
    @IBAction func onTappedSort(_ sender: Any) {
        showType(style: .actionSheet, title: "Sort By", action: nil, height: nil)
        
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
        
        if  selectType == UIContant.TYPE_DICTIONARY{
            
            headingName =  dictionaryCategories[indexPath.row].englishWord ?? ""
            subHeadingName =  dictionaryCategories[indexPath.row].urduWord ?? ""
            duration = dictionaryCategories[indexPath.row].duration ?? ""
        }else if selectType == UIContant.TYPE_TEACHER{
            
            
        }else if selectType == UIContant.TYPE_STORIES{
            
            
        }else if selectType == UIContant.TYPE_LEARNING{
            
            
        }
        
        cell.lblTitleEnglish.text =  headingName
        cell.lblTitleUrdu.text = subHeadingName
        cell.lblDuration.text =  duration
        
        cell.selectionStyle = .none
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        
        
        if let c = cell as?  ChildMedaitorTableViewCell{
            print("Downloading Image")
            // c.photoImageView.af_setImage(withURL: url)
            var imageUrlString:String = ""
            if  selectType == UIContant.TYPE_DICTIONARY{
                
                imageUrlString =  dictionaryCategories[indexPath.row].poster ?? ""
                
            }else if selectType == UIContant.TYPE_TEACHER{
                
                
            }else if selectType == UIContant.TYPE_STORIES{
                
                
            }else if selectType == UIContant.TYPE_LEARNING{
                
                
            }
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
    
    
    
    // make a cell for each cell index path
    
    
    
    
    
    
    func showType(style: UIAlertController.Style, title: String?, action: String?, height: Double?) {
        // I had viewController passed in as a function,
        var selectionindex:Int = 0
        let selectionType: SelectionType = style == .alert ? .Single : .Multiple
        
        let selectionMenu =  RSSelectionMenu(selectionStyle: .single, dataSource: simpleDataArray) { (cell, name, indexPath) in
            cell.textLabel?.text = name
            cell.tintColor = UICommonMethods.hexStringToUIColor(hex: "#009E4F")
        }
        selectionMenu.setSelectedItems(items: simplesSelectedArray) { [weak self] (item, index, isSelected, selectedItems) in
            
            // update your existing array with updated selected items, so when menu show menu next time, updated items will be default selected.
            self?.simplesSelectedArray = selectedItems
        }
        
        
        selectionMenu.onDismiss = { items in
            self.simplesSelectedArray = items
            if self.presentedViewController as? UIAlertController != nil {
                selectionMenu.dismiss()
            }
            
            
        }
        
        selectionMenu.show(style: .actionSheet(title: nil, action: "Done", height:(Double(simpleDataArray.count) * 50)), from: self)
        
        // show
        
    }
    
    
    func requestPayload(){
        let headers: HTTPHeaders = [
            "session": AuthenticationPreference.getSession(),
            "userType": UIContant.GUEST_USER
        ]
        let parameter:  Parameters = ["category_id":categoryId]
        print(parameter)
        
        AF.request(UIContant.DICTIONARY, method: .post, parameters: parameter, encoding: URLEncoding(destination: .methodDependent),headers: headers).responseDecodable(of: RootDictionary.self)  { response in
            //print(response)
            switch response.result {
            
            case .success:
                guard let model = response.value else { return }
                if let responseCode = model.code {
                    if responseCode ==  200{
                        if let dicList = model.data, !dicList.isEmpty {
                            self.dictionaryCategories =  dicList
                        }
                        
                        self.tableView.reloadData()
                        
                    }else {
                        
                    }
                }
            case .failure(let error):
                print(error)
                
                
            }
        }
    }
}
