//
//  DownloadViewController.swift
//  PSL
//
//  Created by MacBook on 04/03/2021.
//

import UIKit
import MZDownloadManager
import AVFoundation
import CoreData
import AlamofireImage
class DownloadViewController: BaseViewController ,UITableViewDataSource, UITableViewDelegate,UISearchResultsUpdating{
   
    let searchController = UISearchController(searchResultsController: nil)

    @IBOutlet weak var lblDownloadedVideo: UILabel!
    @IBOutlet weak var NodataImg: UIImageView!
    
    @IBOutlet weak var lblNodata: UILabel!
    @IBOutlet weak var videoTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var videoTableView: UITableView!
    
    @IBOutlet weak var lblDownloading: UILabel!
    
    @IBOutlet weak var downloadingTop: NSLayoutConstraint!
    
    @IBOutlet weak var downloadingtableTop: NSLayoutConstraint!
    
    @IBOutlet weak var downloadingTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var downloadingTableView: UITableView!
    let imageCache = AutoPurgingImageCache( memoryCapacity: 111_111_111, preferredMemoryUsageAfterPurge: 90_000_000)
    var downloadManager: MZDownloadManager? = nil
    var downloadedFilesArray : [String] = []

    var dbDownloadVideos = [DownloadDataModel]()
    var dbDownloadVideosTemp = [DownloadDataModel]()

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()

        setUpDownloadFile()
        // Do any additional setup after loading the view.
        setUpsearchController()
        print("hello")

        
    }
    override func viewWillAppear(_ animated: Bool) {
 
        
       
            if let nearestEnclosingTabBarController:DashboardTabBarViewController = self.tabBarController as? DashboardTabBarViewController{
                    nearestEnclosingTabBarController.progressController = self
             
             }
        calculatedownloadTableHeight()
        calculateVideoTableHeight()
        
        if dbDownloadVideos.count == 0   && downloadManager?.downloadingArray.count == 0{
            lblNodata.isHidden =  false
            NodataImg.isHidden =  false
            lblDownloadedVideo.text = ""
            lblDownloading.text = ""
        }else{
            lblNodata.isHidden =  true
            NodataImg.isHidden =  true
        }

    }
    
    func hideDownloading(){
        
       
        lblDownloading.text = ""
        downloadingTop.constant = 0
        downloadingtableTop.constant = 0
        downloadingTableViewHeight.constant = 0
        
    }
    func showDownloading(){
        lblDownloading.text = "Downloading Videos"
        downloadingTop.constant = 16
        downloadingtableTop.constant = 16
        
    }
    func calculatedownloadTableHeight(){
        if downloadManager != nil{
            let count = downloadManager?.downloadingArray.count ?? 0
            if count > 0{
                showDownloading()
                downloadingTableViewHeight.constant = CGFloat(count * 100)
                downloadingTableView.reloadData()
                lblNodata.isHidden =  true
                NodataImg.isHidden  = true
            }else{
            
                hideDownloading()
            }
        }else{
            hideDownloading()
        }
        

    }
    
    
    func calculateVideoTableHeight(){
    
        videoTableViewHeight.constant = CGFloat(dbDownloadVideos.count * 100)
        self.videoTableView.reloadData()

    }
    
    
    func generateThumbnail(path: String) -> UIImage? {
        do {
            //let asset = AVURLAsset(URL: URL(fileURLWithPath: "/that/long/path"), options: nil)

            let asset = AVURLAsset(url:  URL(fileURLWithPath: path), options: nil)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.maximumSize = CGSize(width: 60,height: 60)
            imgGenerator.appliesPreferredTrackTransform = true
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
            let thumbnail = UIImage(cgImage: cgImage)
            return thumbnail
        } catch let error {
            print("*** Error generating thumbnail: \(error.localizedDescription)")
            return nil
        }
    }
    
    func setUpDownloadFile(){
        if let nearestEnclosingTabBarController:DashboardTabBarViewController = self.tabBarController as? DashboardTabBarViewController{
          
             downloadManager = nearestEnclosingTabBarController
                .downloadManager
            
            calculatedownloadTableHeight()

           
        }
        do {
            let contentOfDir: [String] = try FileManager.default.contentsOfDirectory(atPath: MZUtility.baseFilePath+"/PSLVideos" as String)
            downloadedFilesArray.append(contentsOf: contentOfDir)
            
            dbDownloadVideos =  getAllDownloadVideos()
            dbDownloadVideosTemp = dbDownloadVideos
            print(dbDownloadVideos.count)
            let index = downloadedFilesArray.firstIndex(of: ".DS_Store")
            if let index = index {
                downloadedFilesArray.remove(at: index)
            }

            
            if dbDownloadVideos.count > 0{
                calculateVideoTableHeight()
            }else{
                lblDownloadedVideo.text = ""
            }
            
            if dbDownloadVideos.count == 0   && downloadManager?.downloadingArray.count == 0{
                lblNodata.isHidden =  false
                NodataImg.isHidden =  false
            }else{
                lblNodata.isHidden =  true
                NodataImg.isHidden =  true
            }
        } catch let error as NSError {
            print("Error while getting directory content \(error)")
            
            if dbDownloadVideos.count == 0   && downloadManager?.downloadingArray.count == 0{
                lblNodata.isHidden =  false
                NodataImg.isHidden =  false
                lblDownloadedVideo.text = ""
                lblDownloading.text = ""
            }else{
                lblNodata.isHidden =  true
                NodataImg.isHidden =  true
            }
            
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(downloadFinishedNotification(_:)), name: NSNotification.Name(rawValue: MZUtility.DownloadCompletedNotif as String), object: nil)
    }
    @objc func downloadFinishedNotification(_ notification : Notification) {
        let fileName : NSString = notification.object as! NSString
        downloadedFilesArray.append(fileName.lastPathComponent)
      //  videoTableView.reloadSections(IndexSet(integer: 0), with: UITableView.RowAnimation.fade)
        dbDownloadVideos =  getAllDownloadVideos()
        dbDownloadVideosTemp = dbDownloadVideos

        if dbDownloadVideos.count > 0{
            lblDownloadedVideo.text = "Downloaded Videos"

            calculateVideoTableHeight()
        }else{
            lblDownloadedVideo.text = ""

        }
        calculatedownloadTableHeight()
        
        
        if dbDownloadVideos.count == 0   && downloadManager?.downloadingArray.count == 0{
            lblNodata.isHidden =  false
            NodataImg.isHidden =  false
            lblDownloadedVideo.text = ""
            lblDownloading.text = ""
        }else{
            lblNodata.isHidden =  true
            NodataImg.isHidden =  true
        }
        
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
        
        self.videoTableView.delegate = self
        self.videoTableView.dataSource = self
       
        self.videoTableView.separatorStyle = .singleLine
        self.videoTableView.estimatedRowHeight = 100
        self.videoTableView.separatorInset = .zero
        self.videoTableView.layoutMargins = .zero
        self.videoTableView.isEmptyRowsHidden =  true
        self.videoTableView.isScrollEnabled = false
        self.videoTableView.rowHeight = UITableView.automaticDimension

        
        self.downloadingTableView.delegate = self
        self.downloadingTableView.dataSource = self
        self.downloadingTableView.separatorStyle = .singleLine
        self.downloadingTableView.estimatedRowHeight = 100
        self.downloadingTableView.separatorInset = .zero
        self.downloadingTableView.layoutMargins = .zero
        self.downloadingTableView.isEmptyRowsHidden =  true
        self.downloadingTableView.isScrollEnabled = false
    }

    func refreshCellForIndex(_ downloadModel: MZDownloadModel, index: Int) {
        calculatedownloadTableHeight()
       /* let indexPath = IndexPath.init(row: index, section: 0)
        let cell = self.downloadingTableView.cellForRow(at: indexPath)
        if let cell = cell {
            let downloadCell = cell as! DownloadingTableViewCell
           // downloadCell.updateCellForRowAtIndexPath(indexPath, downloadModel: downloadModel)
        }*/
    }
    
    func insertItem(index:Int){
        let indexPath = IndexPath.init(row: index, section: 0)
        videoTableView.insertRows(at: [indexPath], with: UITableView.RowAnimation.fade)
      

       
    }
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        print(text)
        if  (text == "")
        {
            dbDownloadVideos.removeAll(keepingCapacity: false)
            dbDownloadVideos =  dbDownloadVideosTemp
            calculateVideoTableHeight()
            
            
            
            
        }else
        {
            
            
            dbDownloadVideos.removeAll(keepingCapacity: false)
            let predicateString = text
            dbDownloadVideos = dbDownloadVideosTemp.filter({$0.videoName.range(of: predicateString, options: .caseInsensitive) != nil})
            dbDownloadVideos.sort {$0.videoName < $1.videoName }
            
            calculateVideoTableHeight()

            
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        if tableView == videoTableView{
            return dbDownloadVideos.count

        }else{
            if self.downloadManager != nil{
                return self.downloadManager?.downloadingArray.count ?? 0

            }else{
                return 0
            }

        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == videoTableView{

            
                let identifier = "ChildMedaitorTableViewCell"
                
                var cell: ChildMedaitorTableViewCell! = tableView.dequeueReusableCell(withIdentifier: identifier) as? ChildMedaitorTableViewCell
                if cell == nil {
                    tableView.register(UINib(nibName: "ChildMedaitorTableViewCell", bundle: nil), forCellReuseIdentifier: identifier)
                    cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? ChildMedaitorTableViewCell
                }
            var fileName = dbDownloadVideos[indexPath.row].videoName.firstCharacterUpperCase() ?? ""
            if fileName.contains(".mp4"){
                fileName = fileName.replacingOccurrences(of: ".mp4", with: "", options: NSString.CompareOptions.literal, range: nil)
                fileName =  fileName.replacingOccurrences(of: "-", with: " ", options: .literal, range: nil)
                print(fileName)
            }
        cell.lblTitleEnglish.text =  fileName
        cell.lblTitleUrdu.text = ""
        cell.lblDuration.text =  dbDownloadVideos[indexPath.row].duration
        cell.typeImage.layer.cornerRadius = 8.0
        cell.typeImage.clipsToBounds = true
      
          cell.selectionStyle = .none
                return cell
            
        }else{
            
                let identifier = "DownloadingTableViewCell"
                
                var cell: DownloadingTableViewCell! = tableView.dequeueReusableCell(withIdentifier: identifier) as? DownloadingTableViewCell
                if cell == nil {
                    tableView.register(UINib(nibName: "DownloadingTableViewCell", bundle: nil), forCellReuseIdentifier: identifier)
                    cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? DownloadingTableViewCell
                }
            
            if self.downloadManager != nil{
                if  let downloadModel = self.downloadManager?.downloadingArray[indexPath.row] {
                    cell.updateCellForRowAtIndexPath(indexPath, downloadModel: downloadModel)

                }
                
            }
            
          cell.selectionStyle = .none
                return cell
        }
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        
        
        if let c = cell as?  ChildMedaitorTableViewCell{
            print("Downloading Image")
            // c.photoImageView.af_setImage(withURL: url)
            var imageUrlString:String = dbDownloadVideos[indexPath.row].thumnail
            
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
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
      
        if tableView == videoTableView{
            let mainstoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewcontroller:PlayerViewController  = mainstoryboard.instantiateViewController(withIdentifier: "PlayerViewController") as! PlayerViewController
            newViewcontroller.selectType = UIContant.TYPE_DICTIONARY
            newViewcontroller.isDownloadVideo = true
            
           
            newViewcontroller.videoName =  dbDownloadVideos[indexPath.row].videoName
            newViewcontroller.downloadedModel = dbDownloadVideos[indexPath.row]
            self.navigationController?.pushViewController(newViewcontroller, animated: true)
            
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        if tableView == videoTableView{
            let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
                // delete item at indexPath
                print("hello")
                self.deleteModelAt(index: indexPath.row)
                self.videoTableView.deleteRows(at: [indexPath], with: .automatic);
               // self.tableView.reloadData()
                self.calculatedownloadTableHeight()
                self.calculateVideoTableHeight()
                
                if self.dbDownloadVideos.count == 0   && self.downloadManager?.downloadingArray.count == 0{
                    self.lblNodata.isHidden =  false
                    self.NodataImg.isHidden =  false
                    self.lblDownloadedVideo.text = ""
                    self.lblDownloading.text = ""
                }else{
                    self.lblNodata.isHidden =  true
                    self.NodataImg.isHidden =  true
                }
            }

            

            return [delete]
        }else{
            return nil
        }
       
    }
    
    
    func deleteModelAt(index: Int) {
      //... delete logic for model
        
        let filepath =  dbDownloadVideos[index].path
        let videoId = dbDownloadVideos[index].id
         let url = URL(fileURLWithPath: filepath)
        if FileManager.default.fileExists(atPath: filepath) {
            try! FileManager.default.removeItem(at: url)
        }
        
        if !videoId.isEmpty{
            deleteDownload(Id: videoId)

        }
        dbDownloadVideos.remove(at:index)
        
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
    func getAllDownloadVideos()->[DownloadDataModel] {
        var dataList = [DownloadDataModel]()
        //As we know that container is set up in the AppDelegates so we need to refer that container.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return [DownloadDataModel]() }
        
        //We need to create a context from this container
        let manager = CoreDataManager.Instance

        let managedContext = manager.managedObjectContext
        //Prepare the request of type NSFetchRequest  for the entity
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Downloadvideos")
        //let predicateID = NSPredicate(format: "id == %@","")
        //    fetchRequest.predicate = predicateID
        //        fetchRequest.fetchLimit = 1
        //        fetchRequest.predicate = NSPredicate(format: "username = %@", "Ankur")
        //        fetchRequest.sortDescriptors = [NSSortDescriptor.init(key: "email", ascending: false)]
        //
        do {
            let result = try managedContext.fetch(fetchRequest)
            print(result.count)
            for data in result as! [NSManagedObject] {
                let model  = DownloadDataModel()

                if let id = data.value(forKey: "videoid") as? Int{
                    model.id = String(id)

                }
                
                if let videoName = data.value(forKey: "videoName") as? String{
                    model.videoName = videoName

                }
                
                if  let duration = data.value(forKey: "videoduration") as? String{
                    model.duration  = duration

                }
                
                if let path = data.value(forKey: "videopath") as? String{
                    model.path = path

                }
                if let thumbnail = data.value(forKey: "videoThumnail") as? String{
                    model.thumnail = thumbnail

                }

               
                
                
                dataList.append(model)

               
                
                
            }
            
        } catch {
            
            print("Failed")
        }
        
        return dataList
    }
  
    
    
    func updateProgress(){
        print("hello progress")
    }
    
    
    
    
    
    func deleteDownload(Id:String){
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Downloadvideos")
         let queryString = "videoid = \"" + Id + "\""
                let predicate = NSPredicate(format:queryString)
         fetchRequest.predicate = predicate
        
        //We need to create a context from this container
        let manager = CoreDataManager.Instance
        
        let managedContext = manager.managedObjectContext
         let result = try? managedContext.fetch(fetchRequest)
         let resultData = result  as! [NSManagedObject]

         for object in resultData {
            managedContext.delete(object)
         }

         do {
             try managedContext.save()
             print("saved!")
         } catch let error as NSError  {
             print("Could not save \(error), \(error.userInfo)")
         }
    }
   
}
