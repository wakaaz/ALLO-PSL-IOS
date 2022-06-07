//
//  MedaitorViewController.swift
//  PSL
//
//  Created by MacBook on 23/03/2021.
//

import UIKit
import Alamofire
import AlamofireImage
import RSSelectionMenu

class MedaitorViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UISearchBarDelegate {
    private lazy var collectionViewLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        let spacing: CGFloat = 1
        let numOfColumns: CGFloat = 3
        let itemSize: CGFloat = (UIScreen.main.bounds.width - (numOfColumns - spacing) - 2) / 3
        layout.itemSize = CGSize(width: itemSize, height: itemSize)
        layout.minimumInteritemSpacing = spacing
        layout.minimumLineSpacing = spacing
        layout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        return layout
    }()
    
    let columnLayout = ColumnFlowLayout(
        cellsPerRow: 2,
        minimumInteritemSpacing: 5,
        minimumLineSpacing: 5,
        sectionInset: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    )
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var selectType:Int = 0
    
    var animationOn:Bool = false

    /*
     Type of Data
     */
    var dictionaryCategories  = [DictionaryCategory]()
    var learningTutGrades  =  [LearningTutGrade]()
    var lifeSkills = [LifeSkill]()
    var storyTypes = [StoryType]()
    var tutGrades = [TutGrade]()
    
    
    
    var tempdictionaryCategories  = [DictionaryCategory]()
    var templearningTutGrades  =  [LearningTutGrade]()
    var templifeSkills = [LifeSkill]()
    var tempstoryTypes = [StoryType]()
    var temptutGrades = [TutGrade]()
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
        setUpCollectionView()
        loadAnimation()
        requestPayload()
    }
    override func viewWillAppear(_ animated: Bool) {
       super.viewWillAppear(animated)
       
       AppUtility.lockOrientation(.portrait)
       // Or to rotate and lock
       // AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
       
   }

   override func viewWillDisappear(_ animated: Bool) {
       super.viewWillDisappear(animated)
       
       // Don't forget to reset when view is being removed
       AppUtility.lockOrientation(.all)
   }
    func setUpTitle(){
        
        if  selectType == UIContant.TYPE_DICTIONARY{
            navigationItem.title = "Dictionary"
            
        }else if selectType == UIContant.TYPE_TEACHER{
            navigationItem.title = "Teacher Tutorials"
            
        }else if selectType == UIContant.TYPE_STORIES{
            navigationItem.title = "Stories"
            
        }else if selectType == UIContant.TYPE_LEARNING{
            navigationItem.title = "Student Tutorials"
            
        }else if selectType == UIContant.TYPE_SKILL{
            navigationItem.title = "Life Skills"
            
        }
        
        
    }
    
    func setUpSearchBar(){
        simplesSelectedArray.append("Default")
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
    }
    
    
    func setUpCollectionView(){
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView?.collectionViewLayout = columnLayout
        
        // collectionView?.contentInsetAdjustmentBehavior = .always
        // collectionView?.collectionViewLayout = collectionViewLayout
        
    }
    
    @IBAction func onTappedSort(_ sender: Any) {
        //showType(style: .actionSheet, title: "Sort By", action: nil, height: nil)
     //   showAsAlertController(style: .actionSheet, title: "Select Player", action: nil, height: nil)
        selectSorting()
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        var size:Int = 0
        if animationOn{
            size = 10
        }else{
            if  selectType == UIContant.TYPE_DICTIONARY{
                size = dictionaryCategories.count
                
            }else if selectType == UIContant.TYPE_TEACHER{
                size = tutGrades.count
                
            }else if selectType == UIContant.TYPE_STORIES{
                size = storyTypes.count
                
            }else if selectType == UIContant.TYPE_LEARNING{
                size = learningTutGrades.count
                
            }else if selectType == UIContant.TYPE_SKILL{
                size = lifeSkills.count
                
            }
        }
       
        return size
    }
    
    // make a cell for each cell index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("cell")
        let reuseIdentifier = "MedaitorCollectionViewCell" // also enter this string as the cell identifier in the storyboard
        
        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! MedaitorCollectionViewCell
        
        // Use the outlet in our custom class to get a reference to the UILabel in the cell
        // make cell more visible in our example project
        
        if animationOn{
            cell.s1.isHidden = false
            cell.s2.isHidden = false
            cell.s1.startAnimating()
            cell.s2.startAnimating()

        }else{
            cell.s1.isHidden = true
            cell.s2.isHidden = true
         
        var headingName: String = ""
        var subHeadingName: String = ""
        var imgStr: String = ""
        var ext: String = ""
        if  selectType == UIContant.TYPE_DICTIONARY{
            ext = "Words"
            let count:Int = dictionaryCategories[indexPath.row].videos ?? 0
            headingName =  dictionaryCategories[indexPath.row].title ?? ""
            subHeadingName =  String(count)
            imgStr =  dictionaryCategories[indexPath.row].image ?? ""
        }else if selectType == UIContant.TYPE_TEACHER{
            var count:Int = 0
            if let subjectList = tutGrades[indexPath.row].subjects{
                count = subjectList.count
            }
            ext = "Subjects"
            headingName =  tutGrades[indexPath.row].grade ?? ""
            subHeadingName =  String(count)
            imgStr =  tutGrades[indexPath.row].icon ?? ""
        }else if selectType == UIContant.TYPE_STORIES{
            ext = "Stories"
            let count:Int = storyTypes[indexPath.row].videos ?? 0
            headingName =  storyTypes[indexPath.row].title ?? ""
            subHeadingName =  String(count)
          //  imgStr =  storyTypes[indexPath.row].icon ?? ""
        }else if selectType == UIContant.TYPE_LEARNING{
            var count:Int = 0
            if let subjectList = learningTutGrades[indexPath.row].subjects{
                count = subjectList.count
            }
            ext = "Subjects"
            headingName =  learningTutGrades[indexPath.row].grade ?? ""
            subHeadingName =  String(count)
            //imgStr =  learningTutGrades[indexPath.row].icon ?? ""
        }else if selectType == UIContant.TYPE_SKILL{
            
            let count:Int = lifeSkills[indexPath.row].videos ?? 0
            
            ext = "Subjects"
            headingName =  lifeSkills[indexPath.row].title ?? ""
            subHeadingName =  String(count)
           // imgStr =  lifeSkills[indexPath.row].icon ?? ""
        }
        
        
        
        cell.lblSubHeading.text = headingName
        cell.lblTypeName.text = subHeadingName+" "+ext
        
        /* cell.lblProductName.text = productList[indexPath.row].name
         print(productList[indexPath.row].thumbnail)*/
        if !imgStr.isEmpty{
            var imageRequest = URLRequest(url: URL(string: imgStr)!)
            print(imgStr.removingPercentEncoding)
            var finalurl:String = imgStr.removingPercentEncoding ?? ""
            
            if let image = imageCache.image(withIdentifier: finalurl)
            {
                cell.typeImage.image = image
            }else{
                cell.typeImage.af_setImage(withURL: URL(string: finalurl)!, completion: { response in
                    
                    
                    switch response.result {
                    
                    case .success:
                        guard let image = response.value else { return }
                        cell.typeImage.image = image
                        self.imageCache.add(image, withIdentifier: finalurl)
                        
                    case .failure(let error):
                        print(error)
                        
                        
                    }
                    
                })
            }
        }
        
        
        
        }
        return cell
    }
    
    // MARK: - UICollectionViewDelegate protocol
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // handle tap events
        print("You selected cell #\(indexPath.item)!")
        
        var catId:Int = 0
        var categoryName : String = ""
        if  selectType == UIContant.TYPE_DICTIONARY{
            
            catId =  dictionaryCategories[indexPath.row].id ?? 0
            categoryName =  dictionaryCategories[indexPath.row].title ?? ""
            navigateToNext(categoryId: catId, categoryName: categoryName)
            
        }else if selectType == UIContant.TYPE_TEACHER{
            catId =  tutGrades[indexPath.row].id ?? 0
            categoryName =  tutGrades[indexPath.row].grade ?? ""
            
            if let subjectList = tutGrades[indexPath.row].subjects{
                navigateToMedium(categoryId: catId, categoryName: categoryName, subjects: subjectList)
                
            }
            
            
        }else if selectType == UIContant.TYPE_STORIES{
            catId =  storyTypes[indexPath.row].id ?? 0
            categoryName =  storyTypes[indexPath.row].title ?? ""
            navigateToNext(categoryId: catId, categoryName: categoryName)
            
        }else if selectType == UIContant.TYPE_LEARNING{
            catId =  learningTutGrades[indexPath.row].id ?? 0
            categoryName =  learningTutGrades[indexPath.row].grade ?? ""
            if let subjectList = learningTutGrades[indexPath.row].subjects{
                navigateToMedium(categoryId: catId, categoryName: categoryName, subjects: subjectList)
                
            }
            
        }else if selectType == UIContant.TYPE_SKILL{
            catId =  lifeSkills[indexPath.row].id ?? 0
            categoryName =  lifeSkills[indexPath.row].title ?? ""
            navigateToNext(categoryId: catId, categoryName: categoryName)
            
        }
        
        
        
        
    }
    
    
    
    
    
    
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
    
    func requestPayload(){
        
        
        
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
                            self.dictionaryCategories =  dicList
                            self.tempdictionaryCategories =  dicList
                        }
                        if let teacherList = innermodel.tutGrades, !teacherList.isEmpty {
                            self.tutGrades =  teacherList
                            self.temptutGrades = teacherList
                        }
                        if let storyList = innermodel.storyTypes, !storyList.isEmpty {
                            self.storyTypes =  storyList
                            self.tempstoryTypes =  storyList
                        }
                        if let learningList = innermodel.learningTutGrades, !learningList.isEmpty {
                            self.learningTutGrades =  learningList
                            self.templearningTutGrades =  learningList
                        }
                        if let skillList = innermodel.lifeSkills, !skillList.isEmpty {
                            self.lifeSkills =  skillList
                            self.templifeSkills =  skillList
                        }
                        self.hideAnimation()
                        self.collectionView.reloadData()
                        
                    }else {
                        
                    }
                }
            case .failure(let error):
                print(error)
                
                
            }
        }
    }
    
    
    func navigateToNext(categoryId:Int, categoryName:String){
        let mainstoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewcontroller:ChildMedaitorViewController  = mainstoryboard.instantiateViewController(withIdentifier: "ChildMedaitorViewController") as! ChildMedaitorViewController
        newViewcontroller.selectType = selectType
        newViewcontroller.categoryId = categoryId
        newViewcontroller.categoryName =  categoryName
        self.navigationController?.pushViewController(newViewcontroller, animated: true)
    }
    
    func navigateToMedium(categoryId:Int, categoryName:String,subjects:[Subject]){
        let mainstoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewcontroller:MediumMedaitorViewController  = mainstoryboard.instantiateViewController(withIdentifier: "MediumMedaitorViewController") as! MediumMedaitorViewController
        newViewcontroller.selectType = selectType
        newViewcontroller.categoryId = categoryId
        newViewcontroller.categoryName =  categoryName
        newViewcontroller.subjects =  subjects
        self.navigationController?.pushViewController(newViewcontroller, animated: true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
           searchBar.resignFirstResponder()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
       {
           if  (searchText == "")
           {
            
            
            if  selectType == UIContant.TYPE_DICTIONARY{
                dictionaryCategories.removeAll(keepingCapacity: false)
                dictionaryCategories =  tempdictionaryCategories
            }else if selectType == UIContant.TYPE_TEACHER{
                tutGrades.removeAll(keepingCapacity: false)
                tutGrades =  temptutGrades
            }else if selectType == UIContant.TYPE_STORIES{
                storyTypes.removeAll(keepingCapacity: false)
                storyTypes =  tempstoryTypes
            }else if selectType == UIContant.TYPE_LEARNING{
                learningTutGrades.removeAll(keepingCapacity: false)
                learningTutGrades =  templearningTutGrades
            }else if selectType == UIContant.TYPE_SKILL{
                lifeSkills.removeAll(keepingCapacity: false)
                lifeSkills =  templifeSkills
            }
            
            
            collectionView.reloadData()
            
            
          
              
           }else
           {
            
            if  selectType == UIContant.TYPE_DICTIONARY{
               
                 dictionaryCategories.removeAll(keepingCapacity: false)
                              let predicateString = searchBar.text!
                dictionaryCategories = tempdictionaryCategories.filter({$0.title?.range(of: predicateString, options: .caseInsensitive) != nil})
                dictionaryCategories.sort {$0.title ?? "" < $1.title ?? ""}
            }else if selectType == UIContant.TYPE_TEACHER{
                tutGrades.removeAll(keepingCapacity: false)
                             let predicateString = searchBar.text!
                tutGrades = temptutGrades.filter({$0.grade?.range(of: predicateString, options: .caseInsensitive) != nil})
                tutGrades.sort {$0.grade ?? "" < $1.grade ?? ""}
            }else if selectType == UIContant.TYPE_STORIES{
                storyTypes.removeAll(keepingCapacity: false)
                             let predicateString = searchBar.text!
                storyTypes = tempstoryTypes.filter({$0.title?.range(of: predicateString, options: .caseInsensitive) != nil})
                storyTypes.sort {$0.title ?? "" < $1.title ?? ""}
            }else if selectType == UIContant.TYPE_LEARNING{
                learningTutGrades.removeAll(keepingCapacity: false)
                             let predicateString = searchBar.text!
                learningTutGrades = templearningTutGrades.filter({$0.grade?.range(of: predicateString, options: .caseInsensitive) != nil})
                learningTutGrades.sort {$0.grade ?? "" < $1.grade ?? ""}
            }else if selectType == UIContant.TYPE_SKILL{
               
                
                lifeSkills.removeAll(keepingCapacity: false)
                             let predicateString = searchBar.text!
                lifeSkills = templifeSkills.filter({$0.title?.range(of: predicateString, options: .caseInsensitive) != nil})
                lifeSkills.sort {$0.title ?? "" < $1.title ?? ""}
            }
            
            
            
            collectionView.reloadData()
            
             
           }
       }
    
    
    
    
    
    
    
    func sortArray(textStr:String){
        
        if  selectType == UIContant.TYPE_DICTIONARY{
            var tempArray = tempdictionaryCategories
            
            if  textStr == "Default"{
                dictionaryCategories =  tempdictionaryCategories
            }else if textStr == "Ascending"{
                dictionaryCategories =  tempArray.sorted { (channel1, channel2) -> Bool in
                    let channelName1 = channel1.title ?? ""
                    let channelName2 = channel2.title ?? ""
                    return (channelName1.localizedCaseInsensitiveCompare(channelName2) == .orderedAscending)}
                
            }else if textStr == "Descending"{
                dictionaryCategories =  tempArray.sorted { (channel1, channel2) -> Bool in
                    let channelName1 = channel1.title ?? ""
                    let channelName2 = channel2.title ?? ""
                    return (channelName1.localizedCaseInsensitiveCompare(channelName2) == .orderedDescending)}
            }
            
            
            
        }else if selectType == UIContant.TYPE_TEACHER{
            let tempArray = temptutGrades
            if  textStr == "Default"{
                tutGrades =  temptutGrades
            }else if textStr == "Ascending"{
                tutGrades =  tempArray.sorted { (channel1, channel2) -> Bool in
                    let channelName1 = channel1.grade ?? ""
                    let channelName2 = channel2.grade ?? ""
                    return (channelName1.localizedCaseInsensitiveCompare(channelName2) == .orderedAscending)}
                
            }else if textStr == "Descending"{
                tutGrades =  tempArray.sorted { (channel1, channel2) -> Bool in
                    let channelName1 = channel1.grade ?? ""
                    let channelName2 = channel2.grade ?? ""
                    return (channelName1.localizedCaseInsensitiveCompare(channelName2) == .orderedDescending)}
            }
        }else if selectType == UIContant.TYPE_STORIES{
            let tempArray = tempstoryTypes
            if  textStr == "Default"{
                storyTypes =  tempstoryTypes
            }else if textStr == "Ascending"{
                storyTypes =  tempArray.sorted { (channel1, channel2) -> Bool in
                    let channelName1 = channel1.title ?? ""
                    let channelName2 = channel2.title ?? ""
                    return (channelName1.localizedCaseInsensitiveCompare(channelName2) == .orderedAscending)}
                
            }else if textStr == "Descending"{
                storyTypes =  tempArray.sorted { (channel1, channel2) -> Bool in
                    let channelName1 = channel1.title ?? ""
                    let channelName2 = channel2.title ?? ""
                    return (channelName1.localizedCaseInsensitiveCompare(channelName2) == .orderedDescending)}
            }
        }else if selectType == UIContant.TYPE_LEARNING{
            let tempArray = templearningTutGrades
            if  textStr == "Default"{
                learningTutGrades =  templearningTutGrades
            }else if textStr == "Ascending"{
                learningTutGrades =  tempArray.sorted { (channel1, channel2) -> Bool in
                    let channelName1 = channel1.grade ?? ""
                    let channelName2 = channel2.grade ?? ""
                    return (channelName1.localizedCaseInsensitiveCompare(channelName2) == .orderedAscending)}
                
            }else if textStr == "Descending"{
                learningTutGrades =  tempArray.sorted { (channel1, channel2) -> Bool in
                    let channelName1 = channel1.grade ?? ""
                    let channelName2 = channel2.grade ?? ""
                    return (channelName1.localizedCaseInsensitiveCompare(channelName2) == .orderedDescending)}
            }
        }else if selectType == UIContant.TYPE_SKILL{
            let tempArray = templifeSkills
            if  textStr == "Default"{
                lifeSkills =  templifeSkills
            }else if textStr == "Ascending"{
                lifeSkills =  tempArray.sorted { (channel1, channel2) -> Bool in
                    let channelName1 = channel1.title ?? ""
                    let channelName2 = channel2.title ?? ""
                    return (channelName1.localizedCaseInsensitiveCompare(channelName2) == .orderedAscending)}
                
            }else if textStr == "Descending"{
                lifeSkills =  tempArray.sorted { (channel1, channel2) -> Bool in
                    let channelName1 = channel1.title ?? ""
                    let channelName2 = channel2.title ?? ""
                    return (channelName1.localizedCaseInsensitiveCompare(channelName2) == .orderedDescending)}
            }
        }
        
        collectionView.reloadData()
        
    }
    
    func selectSorting(){
        let optionMenu = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .actionSheet)
        
        
        optionMenu.view.tintColor  = UICommonMethods.hexStringToUIColor(hex: "#009E4F")

       // if let p240 =  selectedDataModel?.quality240p?.url{
            let deleteAction1 = UIAlertAction(title: "Alphabetically: A-Z", style: .default, handler:
            {
                (alert: UIAlertAction!) -> Void in
                
                
                    
                self.sortArray(textStr: "Ascending")
                
                
               
            })
            optionMenu.addAction(deleteAction1)

       // }
        
            let deleteAction2 = UIAlertAction(title: "Alphabetically: Z-A", style: .default, handler:
            {
                (alert: UIAlertAction!) -> Void in
              //  let p240:String =  self.selectedDataModel?.quality240p?.url ?? ""
                self.sortArray(textStr: "Descending")

                
              
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
        collectionView.reloadData()
    }
    func hideAnimation(){
        animationOn = false
      // dataTableView.reloadData()
    }
}

