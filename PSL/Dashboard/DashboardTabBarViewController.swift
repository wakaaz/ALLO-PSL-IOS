//
//  DashboardTabBarViewController.swift
//  PSL
//
//  Created by MacBook on 04/03/2021.
//

import UIKit
import Alamofire
import SwiftQueue
import CoreData
import MZDownloadManager

class DashboardTabBarViewController: UITabBarController,UITabBarControllerDelegate,MZDownloadManagerDelegate,UNUserNotificationCenterDelegate {
    let userNotificationCenter = UNUserNotificationCenter.current()

    lazy var downloadManager: MZDownloadManager = {
        [unowned self] in
        let sessionIdentifer: String = "com.iosDevelopment.MZDownloadManager.BackgroundSession"
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        var completion = appDelegate.backgroundSessionCompletionHandler
        
        let downloadmanager = MZDownloadManager(session: sessionIdentifer, delegate: self, completion: completion)
        return downloadmanager
        }()
    var progressController:DownloadViewController? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        self.userNotificationCenter.delegate = self
        self.requestNotificationAuthorization()
        
      // Do any additional setup after loading the view.
      //  requestAuth()
    }
    
    override func viewWillAppear(_ animated: Bool) {
       super.viewWillAppear(animated)
       
      // AppUtility.lockOrientation(.portrait)
       // Or to rotate and lock
       // AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
       
   }

   override func viewWillDisappear(_ animated: Bool) {
       super.viewWillDisappear(animated)
       
       // Don't forget to reset when view is being removed
      // AppUtility.lockOrientation(.all)
   }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    func requestAuth(){
        let login :Parameters = [:]
        AF.request(UIContant.SKIP, method: .post, parameters: login, encoding: URLEncoding(destination: .methodDependent)).responseDecodable(of: RootClass.self)  { response in
            print(response)
           
            switch response.result {

            case .success:
                guard let model = response.value else { return }
                guard let innermodel = model.object else { return }
                 AuthenticationPreference.saveAuth(model: innermodel)
            case .failure(let error):
                print(error)
                 AuthenticationPreference.removeAuth()

              //  UICommonMethods.showAlert(title: "Error",message: "Invalid Credential", viewController: self)

            }
        }
    }
    
    func downloadRequestStarted(_ downloadModel: MZDownloadModel, index: Int) {
       // let indexPath = IndexPath.init(row: index, section: 0)
        //tableView.insertRows(at: [indexPath], with: UITableView.RowAnimation.fade)
        print("started")
    }
    
    func downloadRequestDidPopulatedInterruptedTasks(_ downloadModels: [MZDownloadModel]) {
      //  tableView.reloadData()
    }
    
    func downloadRequestDidUpdateProgress(_ downloadModel: MZDownloadModel, index: Int) {
        //self.refreshCellForIndex(downloadModel, index: index)
        print("Did pregress")
        DispatchQueue.main.async {
            if self.progressController != nil{
                self.progressController?.refreshCellForIndex(downloadModel, index: index)

            }
           // self.progressBar.progress =  0

        }
        

    }
    
    func downloadRequestDidPaused(_ downloadModel: MZDownloadModel, index: Int) {
      //  self.refreshCellForIndex(downloadModel, index: index)
        
        print("Did paused")
        if progressController != nil{
            progressController?.refreshCellForIndex(downloadModel, index: index)

        }

    }
    
    func downloadRequestDidResumed(_ downloadModel: MZDownloadModel, index: Int) {
       // self.refreshCellForIndex(downloadModel, index: index)
        print("Did remuse")
        DispatchQueue.main.async {
            if self.progressController != nil{
                self.progressController?.refreshCellForIndex(downloadModel, index: index)

            }
           // self.progressBar.progress =  0

        }
        

    }
    
    func downloadRequestCanceled(_ downloadModel: MZDownloadModel, index: Int) {
        print("Did cancel")
        if progressController != nil{
            progressController?.refreshCellForIndex(downloadModel, index: index)

        }
        
       // self.safelyDismissAlertController()
        
        
       // let indexPath = IndexPath.init(row: index, section: 0)
       // tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.left)
    }
    
    func downloadRequestFinished(_ downloadModel: MZDownloadModel, index: Int) {
        
       // self.safelyDismissAlertController()
        print("finish")

        downloadManager.presentNotificationForDownload("Ok", notifBody: "Download did completed")
       if let fileName = downloadModel.fileName{
        
            sendNotification(notifAction: "Ok",notifBody: fileName+" downloaded sucessfully")

        }

        //sendNotification(notifAction: "Ok",notifBody: "Download did completed")
        //let indexPath = IndexPath.init(row: index, section: 0)
       // tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.left)
        
        let docDirectoryPath : NSString = (MZUtility.baseFilePath as NSString).appendingPathComponent(downloadModel.fileName) as NSString
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: MZUtility.DownloadCompletedNotif as String), object: docDirectoryPath)
    }
    
    func downloadRequestDidFailedWithError(_ error: NSError, downloadModel: MZDownloadModel, index: Int) {
        //self.safelyDismissAlertController()
       // self.refreshCellForIndex(downloadModel, index: index)
        
        debugPrint("Error while downloading file: \(String(describing: downloadModel.fileName))  Error: \(String(describing: error))")
        if progressController != nil{
            progressController?.refreshCellForIndex(downloadModel, index: index)

        }
       
    }
    func requestNotificationAuthorization() {
        // Code here
        let authOptions = UNAuthorizationOptions.init(arrayLiteral: .alert, .badge, .sound)
        self.userNotificationCenter.requestAuthorization(options: authOptions) { (success, error) in
            if let error = error {
                print("Error: ", error)
            }
        }

    }

    func sendNotification(notifAction: String, notifBody: String) {
        // Code here
        let notificationContent = UNMutableNotificationContent()
           notificationContent.title = "Download Complete"
           notificationContent.body = notifBody
           notificationContent.badge = NSNumber(value: 1)
           
           if let url = Bundle.main.url(forResource: "dune",
                                       withExtension: "png") {
               if let attachment = try? UNNotificationAttachment(identifier: "dune",
                                                               url: url,
                                                               options: nil) {
                   notificationContent.attachments = [attachment]
               }
           }
           
           let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1,
                                                           repeats: false)
           let request = UNNotificationRequest(identifier: "testNotification",
                                               content: notificationContent,
                                               trigger: trigger)
           
           userNotificationCenter.add(request) { (error) in
               if let error = error {
                   print("Notification Error: ", error)
               }
           }
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
}
extension UITabBar{
     func setTransparentTabbar(){
        UITabBar.appearance().backgroundImage = UIImage()
        UITabBar.appearance().shadowImage = UIImage()
        UITabBar.appearance().clipsToBounds = true


    }
}
extension UIImage {
 class func imageWithColor(color: UIColor, size: CGSize) -> UIImage {
        let rect: CGRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}
