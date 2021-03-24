//
//  MediumMedaitorViewController.swift
//  PSL
//
//  Created by MacBook on 24/03/2021.
//

import UIKit
import Alamofire
import AlamofireImage
import RSSelectionMenu



class MediumMedaitorViewController: UIViewController , UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
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
        minimumInteritemSpacing: 15,
        minimumLineSpacing: 15,
        sectionInset: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    )
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    /*
     Data Pervious Screen
     */
    
    var selectType:Int = 0
    var categoryId :Int = 0
    var categoryName: String = ""
    var subjects = [Subject]()
    
    
    
    
    /*
     Type of Data
     */
    
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
    
    
    func setUpCollectionView(){
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView?.collectionViewLayout = columnLayout
        
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
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var size:Int = subjects.count
        
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
        
        
        var headingName: String = ""
        var subHeadingName: String = ""
        let imgStr: String = ""
        var ext: String = ""
        
        
        ext = "Video"
        let count:Int = subjects[indexPath.row].videos ?? 0
        headingName =  subjects[indexPath.row].title ?? ""
        subHeadingName =  String(count)
        
        
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
        
        
        
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate protocol
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // handle tap events
        print("You selected cell #\(indexPath.item)!")
        
            
        if selectType == UIContant.TYPE_TEACHER{
            let catId:Int = categoryId
            let categoryName : String = subjects[indexPath.row].title ?? ""
            let subjectId: Int = subjects[indexPath.row].id ?? 0
            navigateToChild(categoryId: catId, categoryName: categoryName, subjectId: subjectId)
        }
      
    }
    
    
    
    
    
    func showType(style: UIAlertController.Style, title: String?, action: String?, height: Double?) {
        // I had viewController passed in as a function,
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
        
        
        
    }
    
    
    
    
    func navigateToChild(categoryId:Int, categoryName:String,subjectId:Int){
        let mainstoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewcontroller:ChildMedaitorViewController  = mainstoryboard.instantiateViewController(withIdentifier: "ChildMedaitorViewController") as! ChildMedaitorViewController
        newViewcontroller.selectType = selectType
        newViewcontroller.categoryId = categoryId
        newViewcontroller.categoryName =  categoryName
        newViewcontroller.subCategoryId = subjectId
        self.navigationController?.pushViewController(newViewcontroller, animated: true)
    }
    
}