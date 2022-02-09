//
//  FavoritesViewController.swift
//  PSL
//
//  Created by MacBook on 04/03/2021.
//

import UIKit
import Alamofire
import AlamofireImage
class FavoritesViewController: UIViewController,UITableViewDataSource, UITableViewDelegate,UISearchResultsUpdating {
    
    
    var animationOn:Bool = false

    var dictionaryCategories  =  [FavouriteModel]()
    var dictionaryCategoriesTemp  =  [FavouriteModel]()
   
    var dataTemp = [DictionaryDatum]()

    @IBOutlet weak var lblNodata: UILabel!
    @IBOutlet weak var NodataImage: UIImageView!
    let imageCache = AutoPurgingImageCache( memoryCapacity: 111_111_111, preferredMemoryUsageAfterPurge: 90_000_000)
    @IBOutlet weak var tableView: UITableView!
    let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
       
        // Do any additional setup after loading the view.
        setUpsearchController()
        setUpTableView()
       // requestPayload()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.lblNodata.isHidden =  true
        self.NodataImage.isHidden =  true
        requestPayload()


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
        self.tableView.isEmptyRowsHidden =  true
        self.tableView.rowHeight = UITableView.automaticDimension

    }

    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        print(text)
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
            dictionaryCategories = dictionaryCategoriesTemp.filter({$0.dictionaryModel?.englishWord?.range(of: predicateString, options: .caseInsensitive) != nil})
            dictionaryCategories.sort {$0.dictionaryModel?.englishWord ?? "" < $1.dictionaryModel?.englishWord ?? "" }
            
            tableView.reloadData()

            
        }
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
        var headingName = ""
        if let title = dictionaryCategories[indexPath.row].dictionaryModel?.title{
            headingName = title
        }else{
            headingName = dictionaryCategories[indexPath.row].dictionaryModel?.englishWord ?? ""
        }
        
        let subHeadingName: String = dictionaryCategories[indexPath.row].dictionaryModel?.urduWord ?? ""
        let duration: String = dictionaryCategories[indexPath.row].dictionaryModel?.duration ?? ""
        
     
        
        
        
        cell.lblTitleEnglish.text =  headingName
        cell.lblTitleUrdu.text = subHeadingName
        cell.lblDuration.text =  duration
        cell.typeImage.layer.cornerRadius = 8.0
        cell.typeImage.clipsToBounds = true
        cell.selectionStyle = .none
        return cell
        }
    }
  
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        let dataModel = dictionaryCategories[indexPath.row]
        
        if let selectModel =  dataModel.dictionaryModel{
            navigateToChild(index: indexPath.row, selectedModel: selectModel, list: self.dataTemp)
        }
       
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        
        
        if let c = cell as?  ChildMedaitorTableViewCell{
            print("Downloading Image")
            // c.photoImageView.af_setImage(withURL: url)
            var imageUrlString:String = dictionaryCategories[indexPath.row].dictionaryModel?.poster ?? ""
           
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
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Remove") { (action, indexPath) in
            // delete item at indexPath
            print("hello")
            let model = self.dictionaryCategories[indexPath.row]
            if let selectModel =  model.dictionaryModel{
                self.deleteModelAt(model: selectModel, index: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .automatic);
            }
            
           
           // self.tableView.reloadData()

        }

        

        return [delete]
    }
    
    
    func deleteModelAt(model:DictionaryDatum,index: Int) {
      //... delete logic for model
        
        
        let model =  dictionaryCategories[index]
        dictionaryCategories.remove(at:index)
        let videoId = model.dictionaryModel?.id ?? 0
        if videoId > 0{
            let status = UICommonMethods.RemoveToFavourite(type: model.type, id: videoId)
            print(status)
        }
        
        
        
     //   var type = UIContant.TYPE_DICTIONARY
       
        
        
                   // myTableView.deleteRows(at: [indexPath as IndexPath], with: .fade)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    func navigateToChild(index:Int,selectedModel:DictionaryDatum,list:[DictionaryDatum]){
        let mainstoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewcontroller:PlayerViewController  = mainstoryboard.instantiateViewController(withIdentifier: "PlayerViewController") as! PlayerViewController
        
        
        
        let model =  dictionaryCategories[index]
        newViewcontroller.selectType = model.type

        newViewcontroller.selectedDataModel =  selectedModel
        newViewcontroller.dictionaryCategories = list
        newViewcontroller.isFromFav =  true
        self.navigationController?.pushViewController(newViewcontroller, animated: true)
    }
    
    func requestPayload(){
        loadAnimation()
        let headers: HTTPHeaders = [
            "session": AuthenticationPreference.getSession(),
            "userType": UIContant.GUEST_USER
        ]
        print(headers)
        let parameter:  Parameters = [:]
        AF.request(UIContant.FAVOURITE, method: .get, parameters: parameter, encoding: URLEncoding(destination: .methodDependent),headers: headers).responseDecodable(of: FavouriteListRoot.self)  { response in
            
            switch response.result {
            
            case .success:
                guard let model = response.value else { return }
                if let responseCode = model.code {
                    if responseCode ==  200{
                        if let dicList = model.data, !dicList.isEmpty {
                           print(dicList)
                           // self.dataTemp = dicList
                            self.dataTemp.removeAll()
                            self.dictionaryCategories.removeAll()
                            for nIndex in 0..<dicList.count
                                {
                                
                                let model = dicList[nIndex]
                            
                                if let innerModel:DictionaryDatum =  model.story{
                                    
                                    let dataModel = FavouriteModel()
                                    dataModel.type =  UIContant.TYPE_STORIES
                                    dataModel.dictionaryModel = innerModel
                                    self.dictionaryCategories.append(dataModel)
                                    self.dataTemp.append(innerModel)

                                    
                                }
                                if let innerModel =  model.dictionary{

                                    let dataModel = FavouriteModel()
                                   dataModel.type =  UIContant.TYPE_DICTIONARY
                                   dataModel.dictionaryModel = innerModel
                                   self.dictionaryCategories.append(dataModel)
                                    self.dataTemp.append(innerModel)

                                    
                                }
                                if let innerModel =  model.tutorial{

                                    let dataModel = FavouriteModel()
                                   dataModel.type =  UIContant.TYPE_TEACHER
                                   dataModel.dictionaryModel = innerModel
                                   self.dictionaryCategories.append(dataModel)
                                    self.dataTemp.append(innerModel)

                                    
                                }
                                if let innerModel =  model.learningTutorial{

                                    let dataModel = FavouriteModel()
                                   dataModel.type =  UIContant.TYPE_LEARNING
                                   dataModel.dictionaryModel = innerModel
                                   self.dictionaryCategories.append(dataModel)
                                    self.dataTemp.append(innerModel)

                                    
                                }
                                if let innerModel =  model.lesson{

                                    let dataModel = FavouriteModel()
                                   dataModel.type =  UIContant.TYPE_SKILL
                                   dataModel.dictionaryModel = innerModel
                                   self.dictionaryCategories.append(dataModel)
                                    self.dataTemp.append(innerModel)

                                    
                                }
                                
                            }
                        }
                        self.dictionaryCategoriesTemp = self.dictionaryCategories
                        self.hideAnimation()
                        self.tableView.reloadData()
                        if self.dictionaryCategories.count > 0{
                            self.lblNodata.isHidden =  true
                            self.NodataImage.isHidden =  true
                        }else{
                            self.lblNodata.isHidden =  false
                            self.NodataImage.isHidden =  false
                        }
                        
                    }else {
                        self.hideAnimation()

                    }
                }
            case .failure(let error):
                print(error)
                
                
            }
        }
    }
    
    
    
    
    func getVideoType(id:Int){
        
        for i in 0..<dataTemp.count {
            //YOUR LOGIC....
            
        }
    }
    func loadAnimation(){
       animationOn = true
        tableView.reloadData()
    }
    func hideAnimation(){
        animationOn = false
      // dataTableView.reloadData()
    }
}
