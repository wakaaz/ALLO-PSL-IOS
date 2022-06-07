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
import ScrollableSegmentedControl

class ChildMedaitorViewController: UIViewController,UITableViewDataSource, UITableViewDelegate,UISearchBarDelegate  {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    /*
     Data Pervious Screen
     */
    
    var selectType:Int = 0
    var categoryId :Int = 0
    var categoryName: String = ""
    var subCategoryId: Int = 0
    
    
    
    /*
     Type of Data
     */
    var dictionaryCategories  =  [DictionaryDatum]()
    var learningTutGrades  =  [LearningTutGrade]()
    var lifeSkills = [LifeSkill]()
    var storyTypes = [StoryType]()
    var storyEnglishTypes = [DictionaryDatum]()
    var storyUrduTypes = [DictionaryDatum]()

    
    var tutGrades = [TutGrade]()
    
    var tempdictionaryCategories  =  [DictionaryDatum]()
    
    
    
    
    
    
    /*
     Image Cache
     */
    let imageCache = AutoPurgingImageCache( memoryCapacity: 111_111_111, preferredMemoryUsageAfterPurge: 90_000_000)
    
    /*
     Segment Control
     */
    
     
    @IBOutlet weak var constraintsegmentHeight: NSLayoutConstraint!
    @IBOutlet weak var parentSegmentControl: ScrollableSegmentedControl!
     
    var animationOn:Bool = false
    var isEnglishOn:Bool = true

    var simpleDataArray = ["Default", "Ascending", "Descending"]
    var simplesSelectedArray = [String]()
    public enum SelectionType {
        case Single        // default
        case Multiple
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        constraintsegmentHeight.constant = 0

        // Do any additional setup after loading the view.
        setUpTitle()
        setUpSearchBar()
        setUpTableView()
        loadAnimation()
        setUpRequest()
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
    
    func setUpRequest(){
        if selectType == UIContant.TYPE_DICTIONARY{
            constraintsegmentHeight.constant = 0
            requestDictionaryPayload()
        }else if selectType == UIContant.TYPE_TEACHER{
            constraintsegmentHeight.constant = 0

            requestTeacherTutorialsPayload()
            
        }else if selectType == UIContant.TYPE_STORIES{
            constraintsegmentHeight.constant = 40
            setupSegmentControl()
            requestStoriesPayload()
        }else if selectType == UIContant.TYPE_LEARNING{
            constraintsegmentHeight.constant = 0

            requestLearningPayload()
        }else if selectType == UIContant.TYPE_SKILL{
            constraintsegmentHeight.constant = 0

            requestLessonPayload()
        }
    }
    func setUpTitle(){
        navigationItem.title = categoryName
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
    func setupSegmentControl() {
        
        parentSegmentControl.segmentStyle = .textOnly
        parentSegmentControl.insertSegment(withTitle: "English", image:#imageLiteral(resourceName: "teachericon"), at: 0)
        parentSegmentControl.insertSegment(withTitle: "Urdu", image: #imageLiteral(resourceName: "teachericon"), at: 1)
        parentSegmentControl.underlineSelected = true
        parentSegmentControl.segmentContentColor = UIColor(named: "labelcolor")
        parentSegmentControl.selectedSegmentContentColor = UIColor(named: "AccentColor")
        parentSegmentControl.tintColor = UIColor(named: "AccentColor")
        parentSegmentControl.selectedSegmentIndex = 0
        parentSegmentControl.fixedSegmentWidth = false
        parentSegmentControl.addTarget(self, action: #selector(segmentSelected(sender:)), for: .valueChanged)
    }
    @objc func segmentSelected(sender:ScrollableSegmentedControl) {
        print("Segment at index \(sender.selectedSegmentIndex)  selected")
        parentSegmentControl.selectedSegmentIndex = sender.selectedSegmentIndex
        switch sender.selectedSegmentIndex {
        case 0:
            
            isEnglishOn =  true
            dictionaryCategories  = storyEnglishTypes
            self.tableView.reloadData()
            
        case 1:
            
            isEnglishOn =  false
            dictionaryCategories  = storyUrduTypes
             self.tableView.reloadData()
            
            
        default:
            break
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
       // showAsAlertController(style: .actionSheet, title: "Select Sorting", action: nil, height: nil)
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
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            if animationOn{
                return 10
            }else{
                
                return dictionaryCategories.count

            }
            
        
        
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
            headingName =  dictionaryCategories[indexPath.row].title ?? ""
            subHeadingName =  ""
            duration = dictionaryCategories[indexPath.row].duration ?? ""
            
        }else if selectType == UIContant.TYPE_STORIES{
            
            var model:DictionaryDatum = dictionaryCategories[indexPath.row]
               
             headingName =  model.title ?? ""
             subHeadingName =  ""
             duration = model.duration ?? ""
        }else if selectType == UIContant.TYPE_LEARNING{
            
            headingName =  dictionaryCategories[indexPath.row].title ?? ""
            subHeadingName =  ""
            duration = dictionaryCategories[indexPath.row].duration ?? ""
        }else if selectType == UIContant.TYPE_SKILL{
            
            headingName =  dictionaryCategories[indexPath.row].title ?? ""
            subHeadingName =  ""
            duration = dictionaryCategories[indexPath.row].duration ?? ""
        }
        
        cell.lblTitleEnglish.text =  headingName.firstCharacterUpperCase()
        cell.lblTitleUrdu.text = subHeadingName
        cell.lblDuration.text =  duration
        cell.typeImage.layer.cornerRadius = 8.0
        cell.typeImage.clipsToBounds = true
        cell.selectionStyle = .none
        return cell
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let dataModel = dictionaryCategories[indexPath.row]
       // let result = returnChunk(index: indexPath.row)
       
        navigateToChild(selectedModel: dataModel, list: dictionaryCategories, index: indexPath.row)
        
       /* if isEnglishOn {
            let dataModel = dictionaryCategories[indexPath.row]
           // let result = returnChunk(index: indexPath.row)
            navigateToChild(selectedModel: dataModel, list: dictionaryCategories)
        }else{
            let dataModel = dictionaryCategories[indexPath.row]
             // let result = returnChunk(index: indexPath.row)
            navigateToChild(selectedModel: dataModel, list: dictionaryCategories)
        }*/
     
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        
        
        if let c = cell as?  ChildMedaitorTableViewCell{
            print("Downloading Image")
            // c.photoImageView.af_setImage(withURL: url)
            var imageUrlString:String = dictionaryCategories[indexPath.row].poster ?? ""
            if  selectType == UIContant.TYPE_DICTIONARY{
                
                imageUrlString =  dictionaryCategories[indexPath.row].poster ?? ""
                
            }else if selectType == UIContant.TYPE_TEACHER{
                imageUrlString =  dictionaryCategories[indexPath.row].poster ?? ""
                
                
            }else if selectType == UIContant.TYPE_STORIES{
                imageUrlString =  dictionaryCategories[indexPath.row].poster ?? ""
                
                
            }else if selectType == UIContant.TYPE_LEARNING{
                
                imageUrlString =  dictionaryCategories[indexPath.row].poster ?? ""
                
            }
            imageUrlString =  imageUrlString.removingPercentEncoding ?? ""
            if !imageUrlString.isEmpty{
                let imageRequest = URLRequest(url: URL(string: imageUrlString)!)
                if let finalurl:String = imageUrlString.removingPercentEncoding {
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
        
        
        
        
        
        
    }
    
    
    
    // make a cell for each cell index path
    
    
    
    
    
    
    
    
    
    func requestDictionaryPayload(){
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
                        if var dicList = model.data, !dicList.isEmpty {
                            for i in 0..<dicList.count {
                               
                                var model = dicList[i]
                                model.indexValue = i
                                dicList[i] = model
                                
                                
                            }
                            self.dictionaryCategories =  dicList
                        }
                        self.hideAnimation()

                        self.tableView.reloadData()
                        
                    }else {
                        
                    }
                }
            case .failure(let error):
                print(error)
                
                
            }
        }
    }
    
    
    func requestTeacherTutorialsPayload(){
        let headers: HTTPHeaders = [
            "session": AuthenticationPreference.getSession(),
            "userType": UIContant.GUEST_USER
        ]
        let parameter:  Parameters = ["grade_id":categoryId,"subject_id":subCategoryId]
        print(parameter)
        
        AF.request(UIContant.TEACHER_TUTORIAL, method: .post, parameters: parameter, encoding: URLEncoding(destination: .methodDependent),headers: headers).responseDecodable(of: RootDictionary.self)  { response in
            print(response)
            switch response.result {
            
            case .success:
                guard let model = response.value else { return }
                if let responseCode = model.code {
                    if responseCode ==  200{
                        if var dicList = model.data, !dicList.isEmpty {
                            for i in 0..<dicList.count {
                               
                                var model = dicList[i]
                                model.indexValue = i
                                dicList[i] = model
                                
                                
                            }
                            self.dictionaryCategories =  dicList
                            self.tempdictionaryCategories =  dicList
                            
                        }
                        self.hideAnimation()

                        self.tableView.reloadData()
                        
                    }else {
                        
                    }
                }
            case .failure(let error):
                print(error)
                
                
            }
        }
    }
    
    func requestStoriesPayload(){
        let headers: HTTPHeaders = [
            "session": AuthenticationPreference.getSession(),
            "userType": UIContant.GUEST_USER
        ]
        let parameter:  Parameters = ["type_id":categoryId]
        print(parameter)
        
        AF.request(UIContant.Stories, method: .post, parameters: parameter, encoding: URLEncoding(destination: .methodDependent),headers: headers).responseDecodable(of: RootDictionary.self)  { response in
            print(response)
            switch response.result {
            
            case .success:
                guard let model = response.value else { return }
                if let responseCode = model.code {
                    if responseCode ==  200{
                        if var dicList = model.data, !dicList.isEmpty {
                            
                            for i in 0..<dicList.count {
                               
                                var model = dicList[i]
                                model.indexValue = i
                                dicList[i] = model
                                
                                
                            }
                            self.dictionaryCategories =  dicList
                            self.tempdictionaryCategories =  dicList
                            
                        }
                        
                        
                        for i in 0..<self.dictionaryCategories.count {
                            var model =  self.dictionaryCategories[i]
                            if model.language == "english"{
                                self.storyEnglishTypes.append(model)
                            }else{
                                self.storyUrduTypes.append(model)
                            }
                            
                            
                            
                            
                        }
                        if self.isEnglishOn{
                            self.dictionaryCategories = self.storyEnglishTypes
                        }else{
                            self.dictionaryCategories = self.storyUrduTypes

                        }
                        self.hideAnimation()

                        self.tableView.reloadData()
                        
                    }else {
                        
                    }
                }
            case .failure(let error):
                print(error)
                
                
            }
        }
    }
    
    func requestLearningPayload(){
        let headers: HTTPHeaders = [
            "session": AuthenticationPreference.getSession(),
            "userType": UIContant.GUEST_USER
        ]
        let parameter:  Parameters = ["grade_id":categoryId,"subject_id":subCategoryId]
        print(parameter)
        
        AF.request(UIContant.LEARNING, method: .post, parameters: parameter, encoding: URLEncoding(destination: .methodDependent),headers: headers).responseDecodable(of: RootDictionary.self)  { response in
            print(response)
            switch response.result {
            
            case .success:
                guard let model = response.value else { return }
                if let responseCode = model.code {
                    if responseCode ==  200{
                        if var dicList = model.data, !dicList.isEmpty {
                            
                            for i in 0..<self.dictionaryCategories.count {
                                var model =  self.dictionaryCategories[i]
                                if model.language == "english"{
                                    self.storyEnglishTypes.append(model)
                                }else{
                                    self.storyUrduTypes.append(model)
                                }
                                
                            }
                            for i in 0..<dicList.count {
                               
                                var model = dicList[i]
                                model.indexValue = i
                                dicList[i] = model
                                
                                
                            }
                            self.dictionaryCategories =  dicList
                            self.tempdictionaryCategories =  dicList
                            
                        }
                        self.hideAnimation()

                        self.tableView.reloadData()
                        
                    }else {
                        
                    }
                }
            case .failure(let error):
                print(error)
                
                
            }
        }
    }
    
    func requestLessonPayload(){
        let headers: HTTPHeaders = [
            "session": AuthenticationPreference.getSession(),
            "userType": UIContant.GUEST_USER
        ]
        let parameter:  Parameters = ["title_id":categoryId]
        print(parameter)
        
        AF.request(UIContant.LESSONS, method: .post, parameters: parameter, encoding: URLEncoding(destination: .methodDependent),headers: headers).responseDecodable(of: RootDictionary.self)  { response in
            print(response)
            switch response.result {
            
            case .success:
                guard let model = response.value else { return }
                if let responseCode = model.code {
                    if responseCode ==  200{
                        if var dicList = model.data, !dicList.isEmpty {
                           
                            for i in 0..<dicList.count {
                               
                                var model = dicList[i]
                                model.indexValue = i
                                dicList[i] = model
                                
                                
                            }
                            self.dictionaryCategories =  dicList
                            
                            self.tempdictionaryCategories =  dicList
                        }
                        self.hideAnimation()
                        self.tableView.reloadData()
                        
                    }else {
                        
                    }
                }
            case .failure(let error):
                print(error)
                
                
            }
        }
    }
    
    func navigateToChild(selectedModel:DictionaryDatum,list:[DictionaryDatum],index:Int){
        
        let mainstoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewcontroller:PlayerViewController  = mainstoryboard.instantiateViewController(withIdentifier: "PlayerViewController") as! PlayerViewController
        newViewcontroller.selectType = selectType
        newViewcontroller.selectedDataModel =  selectedModel
        newViewcontroller.dictionaryCategories = list
        newViewcontroller.isEnglishOn = isEnglishOn
        newViewcontroller.storyEnglishTypes =  storyEnglishTypes
        newViewcontroller.storyUrduTypes =  storyUrduTypes
        newViewcontroller.selectedIndex = index
        self.navigationController?.pushViewController(newViewcontroller, animated: true)
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
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        if  (searchText == "")
        {
            dictionaryCategories.removeAll(keepingCapacity: false)
            dictionaryCategories =  tempdictionaryCategories
            tableView.reloadData()
            
            
            
            
        }else
        {
        
            dictionaryCategories.removeAll(keepingCapacity: false)
            let predicateString = searchBar.text!
            dictionaryCategories = tempdictionaryCategories.filter({$0.title?.range(of: predicateString, options: .caseInsensitive) != nil})
            dictionaryCategories.sort {$0.title ?? "" < $1.title ?? ""}
            tableView.reloadData()
            
            
        }
    }
    
    
    
    
    
    
    
    func sortArray(textStr:String){
        
        var tempArray = tempdictionaryCategories
        if selectType == UIContant.TYPE_STORIES{
            if isEnglishOn{
                tempArray = storyEnglishTypes
            }else{
                tempArray = storyUrduTypes

            }
        }
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
        
        
        tableView.reloadData()
        
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
        tableView.reloadData()
    }
    func hideAnimation(){
        animationOn = false
      // dataTableView.reloadData()
    }
    
    
    func returnChunk(index:Int)->[DictionaryDatum]{
        var dict = [DictionaryDatum]()
        if index < dictionaryCategories.count{
            for name in index..<dictionaryCategories.count {
                //YOUR LOGIC....
                print(name)
                let model = dictionaryCategories[name]
                dict.append(model)
                if dict.count == 5{
                    break
                }
            }
        }
        return dict
    }
}
