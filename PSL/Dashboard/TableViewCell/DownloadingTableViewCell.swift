//
//  DownloadingTableViewCell.swift
//  PSL
//
//  Created by MacBook on 02/04/2021.
//

import UIKit
import MZDownloadManager
import CoreData
import AlamofireImage
class DownloadingTableViewCell: UITableViewCell {

    @IBOutlet var lblTitle : UILabel?
    @IBOutlet var progressDownload : UIProgressView?
    @IBOutlet var lblDetails : UILabel?
    @IBOutlet weak var img: UIImageView!
    
   
   let imageCache = AutoPurgingImageCache( memoryCapacity: 111_111_111, preferredMemoryUsageAfterPurge: 90_000_000)
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        img.layer.cornerRadius = 8.0
        img.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func updateCellForRowAtIndexPath(_ indexPath : IndexPath, downloadModel: MZDownloadModel) {
        
        var fileName = downloadModel.fileName!
        if   fileName.contains(".mp4"){
              fileName = fileName.replacingOccurrences(of: ".mp4", with: "", options: NSString.CompareOptions.literal, range: nil)
            fileName =  fileName.replacingOccurrences(of: "-", with: " ", options: .literal, range: nil)
            }
        
        self.lblTitle?.text = "\(fileName)"
        self.progressDownload?.progress = downloadModel.progress
        
        var remainingTime: String = ""
        if downloadModel.progress == 1.0 {
            remainingTime = "Please wait..."
        } else if let _ = downloadModel.remainingTime {
            if (downloadModel.remainingTime?.hours)! > 0 {
                remainingTime = "\(downloadModel.remainingTime!.hours) Hours "
            }
            if (downloadModel.remainingTime?.minutes)! > 0 {
                remainingTime = remainingTime + "\(downloadModel.remainingTime!.minutes) Min "
            }
            if (downloadModel.remainingTime?.seconds)! > 0 {
                remainingTime = remainingTime + "\(downloadModel.remainingTime!.seconds) sec"
            }
        } else {
            remainingTime = "Calculating..."
        }
        
        var fileSize = "Getting information..."
        if let _ = downloadModel.file?.size {
            fileSize = String(format: "%.2f %@", (downloadModel.file?.size)!, (downloadModel.file?.unit)!)
        }

        var speed = "Calculating..."
        if let _ = downloadModel.speed?.speed {
            speed = String(format: "%.2f %@/sec", (downloadModel.speed?.speed)!, (downloadModel.speed?.unit)!)
        }
        
        var downloadedFileSize = "Calculating..."
        if let _ = downloadModel.downloadedFile?.size {
            downloadedFileSize = String(format: "%.2f %@", (downloadModel.downloadedFile?.size)!, (downloadModel.downloadedFile?.unit)!)
        }
        
        let detailLabelText = NSMutableString()
        detailLabelText.appendFormat("File Size: \(fileSize)\nDownloaded: \(downloadedFileSize) (%.2f%%)\nSpeed: \(speed)\nTime Left: \(remainingTime)\nStatus: \(downloadModel.status)" as NSString, downloadModel.progress * 100.0)
        
        let progresscount  = downloadModel.progress * 100
        let count:String =  String(format:"%.f", Double(progresscount))
        let str = "Downloading..."+count+"%"
        lblDetails?.text = str
        if let fileName = downloadModel.fileName{
            let thumbnail = getThumbnail(word: fileName)
            if  !thumbnail.isEmpty{
                let imageUrlString =  thumbnail.removingPercentEncoding ?? ""
                if !imageUrlString.isEmpty{
                    let imageRequest = URLRequest(url: URL(string: imageUrlString)!)
                    let finalurl:String = imageUrlString.removingPercentEncoding ?? ""
                    if let image = imageCache.image(withIdentifier: finalurl)
                    {
                        img.image = image
                    }else{
                        img.af_setImage(withURL: URL(string: finalurl)!, completion: { response in
                            switch response.result {
                            
                            case .success:
                                guard let image = response.value else { return }
                                self.img.image = image
                                
                                
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
    
    
    
    func getThumbnail(word:String)->String {
        var dataList = [DownloadDataModel]()
        //As we know that container is set up in the AppDelegates so we need to refer that container.
        var name = ""
        //We need to create a context from this container
        let manager = CoreDataManager.Instance

        let managedContext = manager.managedObjectContext
        //Prepare the request of type NSFetchRequest  for the entity
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Downloadvideos")
        let predicate = NSPredicate(format: "(videoName == '\(word)')")
        fetchRequest.predicate = predicate
        
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

                if let thumbnail = data.value(forKey: "videoThumnail") as? String{
                    name = thumbnail

                }

               
                
                

               
                
                
            }
            
        } catch {
            
            print("Failed")
        }
        
        return name
    }
}
