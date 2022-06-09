//
//  PlayerViewController.swift
//  PSL
//
//  Created by MacBook on 25/03/2021.
//

import UIKit
import Alamofire
import AlamofireImage
import AVFoundation
import AVKit
import CoreAudio
import RSSelectionMenu
import MZDownloadManager
import CoreData
import RSSelectionMenu
import UserNotifications

class PlayerViewController: BaseViewController ,UITableViewDataSource, UITableViewDelegate,URLSessionDownloadDelegate{
    
    @IBOutlet weak var parentView: UIView!
    
    @IBOutlet weak var viemoView: UIView!
    
    @IBOutlet weak var youtudeView: UIView!
    @IBOutlet weak var lblTotalDuration: UILabel!
    
    @IBOutlet weak var lblcurrentDuration: UILabel!
    @IBOutlet weak var lblHeading: UILabel!
    
    
    @IBOutlet weak var lblUrduHeading: UILabel!
    
    @IBOutlet weak var lblsubHeading: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var nsTableViewHeight: NSLayoutConstraint!
    
    
    
    
    @IBOutlet weak var btnPlay: UIButton!
    
    
    @IBOutlet weak var btnplay2: UIButton!
    
    
    @IBOutlet weak var progressBar: UIProgressView!
    
    @IBOutlet weak var slider: CustomSlider!
    var dictionaryCategories  =  [DictionaryDatum]()
    var dictionaryCategoriesTemp  =  [DictionaryDatum]()
    var storyEnglishTypes = [DictionaryDatum]()
    var storyUrduTypes = [DictionaryDatum]()
    var isEnglishOn:Bool = true
    var selectType:Int = 0
    var selectedDataModel:DictionaryDatum? = nil
    var AutoselectedDataModel:DictionaryDatum? = nil
    var selectedIndex:Int = 0
    
    
    @IBOutlet weak var constraintChangeLanguageTop: NSLayoutConstraint!
    @IBOutlet weak var constraintChangeLanguageHeight: NSLayoutConstraint!
    @IBOutlet weak var btnChangeLanguage: UIButton!
    @IBOutlet weak var stackViewDownloadLesson: UIStackView!
    @IBOutlet weak var stackViewDownloadLessonHeight: NSLayoutConstraint!
    
    
    
    var selectedDownloadLessonindex:Int = 0
    /*
     Image Cache
     */
    let imageCache = AutoPurgingImageCache( memoryCapacity: 111_111_111, preferredMemoryUsageAfterPurge: 90_000_000)
    
    /*
     Acton
     */
    @IBOutlet weak var imgDownload: UIImageView!
    
    @IBOutlet weak var imgFavourite: UIImageView!
    
    @IBOutlet weak var btnDownloadLesson: UIButton!
    
    @IBOutlet weak var viewTouchListner: UIView!
    @IBOutlet weak var btnViewLesson: UIButton!
    var videourl = "https://player.vimeo.com/external/543031368.sd.mp4?s=baaefe7f28dd4f41d30628f7aba4920fe29eb9bb&profile_id=164"
    /*
     Custom  Video Player
     */
    
    @IBOutlet weak var controlView: UIView!
    var simpleDataArray = [String]()
    var simplesSelectedArray = [String]()
    public enum SelectionType {
        case Single        // default
        case Multiple
    }
    
    
    @IBOutlet weak var favouriteView: UIView!
    
    @IBOutlet weak var nsMainViewHeight: NSLayoutConstraint!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var optionView: UIView!
    @IBOutlet weak var videoplayer: UIView!
    var player:AVPlayer?
    var playerLayer:AVPlayerLayer?
    var playerItem:AVPlayerItem?
    
    var isPause:Bool =  false
    var definesize:CGSize?
    var fristTime = false
    var isAutoPlay = true
    /*
     
     */
    var playingVideoCount:Int = 0
    
    @IBOutlet weak var loaderView: LoaderView!
    
    @IBOutlet weak var autoplaysSwitch: UISwitch!
    var mzDownloadingViewObj : DownloadViewController?
    
    @IBOutlet weak var downloadIamge: UIImageView!
    
    
    @IBOutlet weak var viewFullScreen: UIView!
    var QualityType:Int =  1
    
    var isSingleVideo = false
    var videoName = ""
    var isDownloadVideo = false
    var downloadedModel:DownloadDataModel? = nil
    
    var isFromFav = false
    
    var speedRate = 0.1
    
    
    @IBOutlet weak var btnfullscreen: UIButton!
    /*
     // Selection list
     */
    var downloadDataArray = [String]()
    var downloadselectedArray = [String]()

    @IBOutlet weak var playerBar: UIView!
    var isPlayerBar  =  true
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        print("screenType:", UIDevice.current.screenType)

        setUpIcon()
        
        
        slider.minimumValue = 0
        
        definesize = CGSize(width: self.view.frame.width, height: self.videoplayer.frame.height)
        slider.addTarget(self, action: #selector(self.playbackSliderValueChanged(_:)), for: .valueChanged)
        slider.isContinuous = true
        slider.tintColor = UICommonMethods.hexStringToUIColor(hex: "#35BE79")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Settings", style: .done, target: self, action: #selector(addTapped))
        
        // self.tabBarController?.tabBar.layer.zPosition = -15
        self.tabBarController?.tabBar.isHidden = true
        let gesture = UITapGestureRecognizer(target: self, action:  #selector(self.checkFullScreen(sender:)))
        self.viewFullScreen.addGestureRecognizer(gesture)
        // Do any additional setup after loading the view.
        if isSingleVideo{
            self.autoplaysSwitch.isOn = false
            if !videoName.isEmpty{
                dictionaryCategories = getAllWords(word: videoName)
                if dictionaryCategories.count > 0{
                    
                    selectedDataModel = dictionaryCategories[0]
                }
                
            }
        }
        if isDownloadVideo{
            
            if downloadedModel != nil{
                
                favouriteView.isHidden = true
                var fileName = downloadedModel?.videoName.firstCharacterUpperCase() ?? ""
                if   fileName.contains(".mp4"){
                    fileName = fileName.replacingOccurrences(of: ".mp4", with: "", options: NSString.CompareOptions.literal, range: nil)
                }
                lblTotalDuration.text = downloadedModel?.duration
                lblHeading.text = fileName.firstCharacterUpperCase()
                lblsubHeading.text = "Downloads"
                downloadIamge.image =  UIImage(named: "navdownload")
                
                
                
                
                videourl = downloadedModel?.path ?? ""
                print(videourl)
                
                player = AVPlayer(url: URL(fileURLWithPath: videourl))
                player?.rate  = 1
                //  player?.currentItem.  = false
                
                //player?.currentItem?.isPlaybackBufferEmpty=  true
                player?.automaticallyWaitsToMinimizeStalling =  false
                //player = AVPlayer(playerItem: playerItem)
                playerReSubcribe()
                playerLayer = AVPlayerLayer(player: player)
                self.videoplayer.layer.sublayers = nil
                
                self.videoplayer.layer.addSublayer(playerLayer!)
                
                
                playerLayer?.frame.size = definesize! //bounds of the view in which AVPlayer should be displayed
                playerLayer?.videoGravity = .resizeAspect
                
                
                player?.play()
                //    self.loaderView.isHidden = false
                
                player?.isMuted = false
                slider.minimumValue = 0
                slider.value = 0
                if let duration = playerItem?.asset.duration{
                    let seconds : Float64 = CMTimeGetSeconds(duration)
                    
                    slider.maximumValue = Float(seconds)
                }
                //let duration : CMTime = playerItem?.asset.duration ?? 00
                //
                
                slider.isContinuous = true
                slider.tintColor = UICommonMethods.hexStringToUIColor(hex: "#35BE79")
                imgFavourite.isHidden = true
                
                isPause = false
                if #available(iOS 13.0, *) {
                    btnPlay.setImage(UIImage(systemName: "pause.fill"), for: .normal)
                    btnplay2.setImage(UIImage(systemName: "pause.fill"), for: .normal)
                    
                } else {
                    // Fallback on earlier versions
                }
                
                
                
                
                if let duration =  selectedDataModel?.duration{
                    lblTotalDuration.text = duration
                    lblcurrentDuration.text = "00:00"
                }
                
                if let vimeo = selectedDataModel?.vimeoLink{
                    if (vimeo.isEmpty){
                        viemoView.isHidden = true
                    }else{
                        viemoView.isHidden = false

                    }
                }
                
                if let youtube = selectedDataModel?.youtubeLink{
                    if (youtube.isEmpty){
                        youtudeView.isHidden = true
                    }else{
                        youtudeView.isHidden = false

                    }
                }
                let gesture = UITapGestureRecognizer(target: self, action:  #selector(self.checkAction))
                self.mainView.addGestureRecognizer(gesture)
                
                
                
            }
            
            
            
        }else{
            favouriteView.isHidden = false

            if selectType == UIContant.TYPE_STORIES{
                if isEnglishOn{
                    dictionaryCategories = storyEnglishTypes
                    dictionaryCategoriesTemp =  dictionaryCategories

                }else{
                    dictionaryCategories = storyUrduTypes
                    dictionaryCategoriesTemp =  dictionaryCategories
                }
            }else{
                dictionaryCategoriesTemp =  dictionaryCategories

            }
            
            
            
            // dictionaryCategoriesTemp =  returnChunk(index: 0)
            // setUpSorting()
            DispatchQueue.global(qos: .background).async {
                if self.selectType == UIContant.TYPE_DICTIONARY{
                    let sortedElementsAndIndices = self.dictionaryCategoriesTemp.sorted(by: {
                        self.selectedDataModel?.englishWord ?? "" < $1.englishWord ?? ""
                    })
                    
                    self.dictionaryCategories = sortedElementsAndIndices
                }else{
                    let sortedElementsAndIndices = self.dictionaryCategoriesTemp.sorted(by: {
                        self.selectedDataModel?.indexValue ?? 0  > $1.indexValue ?? 0
                    })
                    
                    self.dictionaryCategories = sortedElementsAndIndices
                }
             
                
                self.dictionaryCategories =  self.dictionaryCategories.filter(){$0.indexValue != self.selectedDataModel?.indexValue}
                
                
                
                
                
                
                DispatchQueue.main.async {
                    self.setUpData()
                    self.setUpTableView()
                    
                }
                
            }
            
        }
        
        
        playerDelegate()
        
     
        
        
    }
    func backScreenTitle()-> String{
        var title = ""
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers
        for aViewController in viewControllers {
            
            let value = aViewController.navigationItem.title ?? ""
            print(aViewController.navigationItem.title)
            title = title + value+" "
        }
        return title
    }
    func setUpIcon(){
        let icon = UIImage(named: "changelanguage")!
          btnChangeLanguage.setImage(icon, for: .normal)
          btnChangeLanguage.imageView?.contentMode = .scaleAspectFit
          btnChangeLanguage.imageEdgeInsets = UIEdgeInsets(top: 0, left: -20, bottom: 0, right: 0)
          btnChangeLanguage.tintColor = UIColor.white
          btnChangeLanguage.layer.cornerRadius = 5
        
        
        let icon1 = UIImage(named: "downloadlesson")!
         /* btnDownloadLesson.setImage(icon1, for: .normal)
        btnDownloadLesson.imageView?.contentMode = .scaleAspectFit
        btnDownloadLesson.imageEdgeInsets = UIEdgeInsets(top: 0, left: -20, bottom: 0, right: 0)
        btnDownloadLesson.tintColor = UIColor.white
        btnDownloadLesson.layer.cornerRadius = 5*/
        
        
        let icon2 = UIImage(named: "viewlesson")!
          btnViewLesson.setImage(icon2, for: .normal)
        btnViewLesson.imageView?.contentMode = .scaleAspectFit
        btnViewLesson.imageEdgeInsets = UIEdgeInsets(top: 0, left: -20, bottom: 0, right: 0)
        btnViewLesson.tintColor = UIColor.white
        btnViewLesson.layer.cornerRadius = 5
        
        
        
        
        

    }
    @objc func playbackSliderValueChanged(_ playbackSlider:UISlider)
    {
        
        let seconds : Int64 = Int64(playbackSlider.value)
        let targetTime:CMTime = CMTimeMake(value: seconds, timescale: 1)
        
        player!.seek(to: targetTime)
        
        if player!.rate == 0
        {
            player?.play()
            isPause = false
            
            if #available(iOS 13.0, *) {
                btnPlay.setImage(UIImage(systemName: "pause.fill"), for: .normal)
                btnplay2.setImage(UIImage(systemName: "pause.fill"), for: .normal)
                
            } else {
                // Fallback on earlier versions
            }
        }else {
            player?.pause()
            isPause = true
            changepausebutton()
        }
    }
    
    
    @objc func addTapped(sender: UIBarButtonItem) {
        // Function body goes here
        showQuality()
        
    }
    func setSwitch(){
        autoplaysSwitch.addTarget(self, action: #selector(switchChanged), for: UIControl.Event.valueChanged)
        
        
    }
    override func viewDidLayoutSubviews() {
        print("view")
        /* playerLayer = AVPlayerLayer(player: player)
         self.videoplayer.layer.addSublayer(playerLayer!)
         
         // definesize = CGSize(width: self.view.frame.width, height: self.videoplayer.frame.height)
         //playerLayer?.frame.size = definesize! //bounds of the view in which AVPlayer should be displayed
         playerLayer?.frame = self.videoplayer.bounds
         
         playerLayer?.videoGravity = .resizeAspect*/
    }
    @objc func switchChanged(mySwitch: UISwitch) {
        isAutoPlay = mySwitch.isOn
        
        // Do something
    }
    override func viewWillAppear(_ animated: Bool) {
        if !fristTime{
            fristTime = true
            navigationItem.largeTitleDisplayMode = .never
            
        }else{
            self.player?.pause()
            
        }
        

        NotificationCenter.default.post(name: Notification.Name("avPlayerDidDismiss"), object: nil, userInfo: nil)
        AppUtility.lockOrientation(.all)

    }
    
    func setUpSorting(){
        
        
        
        setUpData()
        //DispatchQueue.global(qos: .background).async {
       
        if selectType ==  UIContant.TYPE_DICTIONARY{
            let sortedElementsAndIndices = self.dictionaryCategoriesTemp.sorted(by: {
                self.selectedDataModel?.englishWord ?? "" < $1.englishWord ?? ""
            })
            
            self.dictionaryCategories = sortedElementsAndIndices
        }else{
            
            
            
           
            
            let sortedElementsAndIndices = self.dictionaryCategoriesTemp.sorted(by: {
                self.selectedDataModel?.indexValue ?? 0 > $1.indexValue ?? 0
            })
            
            self.dictionaryCategories = sortedElementsAndIndices
        }
        
        self.dictionaryCategories =  self.dictionaryCategories.filter(){$0.indexValue != self.selectedDataModel?.indexValue}
       
        self.dictionaryCategories = sortingAlogaritm(indexPosition: selectedDataModel?.indexValue ?? 0, list: self.dictionaryCategories)
        tableView.reloadData()
      
    }
    
    func sortingAlogaritm(indexPosition:Int,list:[DictionaryDatum])->[DictionaryDatum]{
        
        var beforIndexList = [DictionaryDatum]()
        var afterIndexList = [DictionaryDatum]()
        if(indexPosition == 0){
            beforIndexList.append(contentsOf: list)
        }else {
            for i in 0..<list.count {
               
                var model = list[i]
                if(indexPosition > model.indexValue){
                    afterIndexList.append(model)
                }else{
                    beforIndexList.append(model)
                }
                
                
            }
        }
        let finalList:[DictionaryDatum] = beforIndexList + afterIndexList
        return finalList
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
        setTableViewHeight()
    }
    
    
    
    
    func setUpData(){
        if selectedDataModel != nil{
            
            
            
            var headingName: String = ""
            var subHeadingName: String = ""
            var typeStr:String = ""
            if  selectType == UIContant.TYPE_DICTIONARY{
                typeStr = "Dictionary"
                headingName =  selectedDataModel?.englishWord ?? ""
                subHeadingName =  selectedDataModel?.urduWord ?? ""
            }else if selectType == UIContant.TYPE_TEACHER{
                typeStr = "Teacher Tutorials"
                
                headingName =  selectedDataModel?.title ?? ""
                subHeadingName =  ""
                
            }else if selectType == UIContant.TYPE_STORIES{
                typeStr = "Stories"
                headingName =  selectedDataModel?.title ?? ""
                subHeadingName =  ""
            }else if selectType == UIContant.TYPE_LEARNING{
                typeStr = "Learning"
                headingName =  selectedDataModel?.title ?? ""
                subHeadingName =  ""
            }else if selectType == UIContant.TYPE_SKILL{
                typeStr = "Life Skills"
                headingName =  selectedDataModel?.title ?? ""
                subHeadingName =  ""
            }
            
            
            lblHeading.text = headingName.firstCharacterUpperCase()
            lblsubHeading.text = backScreenTitle()
            lblUrduHeading.text = subHeadingName
            
            if isFromFav{
                selectedDataModel?.favorite = 1
            }
            if selectedDataModel?.favorite == 0{
                let image : UIImage = UIImage(named:"favouriteicon")!
                
                imgFavourite.image = image
                
            }else if selectedDataModel?.favorite ==  1{
                let image : UIImage = UIImage(named:"favourite")!
                
                imgFavourite.image = image
                
            }
            
            if checkRecord(id: String(selectedDataModel?.id ?? 0)) > 0{
                
                
                downloadIamge.image =  UIImage(named: "navdownload")
                
            }else{
                downloadIamge.image =  UIImage(named: "downloadicon")
                
            }
            print(selectedDataModel?.vimeoLink)
            print(selectedDataModel?.youtubeLink)

            
            if let vimeo = selectedDataModel?.vimeoLink{
                if (vimeo.isEmpty){
                    viemoView.isHidden = true
                }else{
                    viemoView.isHidden = false

                }
            }
            
            if let youtube = selectedDataModel?.youtubeLink{
                if (youtube.isEmpty){
                    youtudeView.isHidden = true
                }else{
                    youtudeView.isHidden = false

                }
            }
            
            let parentId = selectedDataModel?.parent
            if isEnglishOn{

                let value = storyUrduTypes.filter { $0.id == parentId }
                if value.count > 0{
                    btnChangeLanguage.setTitle("Watch Urdu Version", for: .normal)
                    constraintChangeLanguageHeight.constant =  40
                    btnChangeLanguage.isHidden = false
                }else{
                    constraintChangeLanguageHeight.constant =  0
                    btnChangeLanguage.isHidden = true
                }
            }else{
                let value = storyEnglishTypes.filter { $0.id == parentId }
                if value.count > 0{
                    btnChangeLanguage.setTitle("Watch English Version", for: .normal)

                    constraintChangeLanguageHeight.constant =  40
                    btnChangeLanguage.isHidden = false

                }else{
                    constraintChangeLanguageHeight.constant =  0
                    btnChangeLanguage.isHidden = true


                }
            }
            
            getDownloadLesson()
            if downloadDataArray.count > 0{
                stackViewDownloadLessonHeight.constant =  40
                stackViewDownloadLesson.isHidden = false

            }else{
                stackViewDownloadLessonHeight.constant =  0
                stackViewDownloadLesson.isHidden = true
            }
            videourl = selectedDataModel?.quality720p?.url?.removingPercentEncoding ?? ""
            print(videourl)
            setUpVideoPlayer()
        }
    }
    func setTableViewHeight(){
        
        nsTableViewHeight.constant = CGFloat(dictionaryCategories.count * 100)
        
    }
    
    
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
        
        
        
        /*if  selectType == UIContant.TYPE_DICTIONARY{
         
         headingName =  dictionaryCategories[indexPath.row].englishWord ?? ""
         subHeadingName =  dictionaryCategories[indexPath.row].urduWord ?? ""
         duration = dictionaryCategories[indexPath.row].duration ?? ""
         }else if selectType == UIContant.TYPE_TEACHER{
         headingName =  dictionaryCategories[indexPath.row].title ?? ""
         subHeadingName =  ""
         duration = dictionaryCategories[indexPath.row].duration ?? ""
         
         }else if selectType == UIContant.TYPE_STORIES{
         
         headingName =  dictionaryCategories[indexPath.row].title ?? ""
         subHeadingName =  ""
         duration = dictionaryCategories[indexPath.row].duration ?? ""
         }else if selectType == UIContant.TYPE_LEARNING{
         
         headingName =  dictionaryCategories[indexPath.row].title ?? ""
         subHeadingName =  ""
         duration = dictionaryCategories[indexPath.row].duration ?? ""
         }else if selectType == UIContant.TYPE_SKILL{
         
         headingName =  dictionaryCategories[indexPath.row].title ?? ""
         subHeadingName =  ""
         duration = dictionaryCategories[indexPath.row].duration ?? ""
         }*/
        var headingName = ""
        if let title = dictionaryCategories[indexPath.row].title{
            
            if title.isEmpty{
                headingName = dictionaryCategories[indexPath.row].englishWord ?? ""

            }else{
                headingName = title

            }
        }else{
            headingName = dictionaryCategories[indexPath.row].englishWord ?? ""
        }
        
        let subHeadingName: String = dictionaryCategories[indexPath.row].urduWord ?? ""
        let duration: String = dictionaryCategories[indexPath.row].duration ?? ""
        
        print(headingName)
        cell.lblTitleEnglish.text =  headingName
        cell.lblTitleUrdu.text = subHeadingName
        cell.lblDuration.text =  duration
        
        cell.selectionStyle = .none
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.player?.pause()
        selectedDataModel  =  dictionaryCategories[indexPath.row]
        setUpSorting()
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        
        
        if let c = cell as?  ChildMedaitorTableViewCell{
            print("Downloading Image")
            // c.photoImageView.af_setImage(withURL: url)
            var imageUrlString:String = ""
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
    
    func showQuality(){
        let optionMenu = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .actionSheet)
        optionMenu.view.tintColor  = UICommonMethods.hexStringToUIColor(hex: "#009E4F")
        
        let saveAction = UIAlertAction(title: "Quality", style: .default, handler:
                                        {
                                            (alert: UIAlertAction!) -> Void in
                                            self.selectQuality()
                                            
                                        })
        
        let deleteAction = UIAlertAction(title: "PlaybackSpeed", style: .default, handler:
                                            {
                                                (alert: UIAlertAction!) -> Void in
                                                self.selectSpeed()
                                            })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler:
                                            {
                                                (alert: UIAlertAction!) -> Void in
                                            })
        cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
        
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(saveAction)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    
    
    
    
    
    func selectSpeed(){
        let optionMenu = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .actionSheet)
        
        optionMenu.view.tintColor  = UICommonMethods.hexStringToUIColor(hex: "#009E4F")
        
        
        // if let p240 =  selectedDataModel?.quality240p?.url{
        let x1 = UIAlertAction(title: "0.25x", style: .default, handler:
                                            {
                                                (alert: UIAlertAction!) -> Void in
                                                
                                               
                                                
                                                
                                                if self.player != nil{
                                                    
                                                    self.player?.rate =  0.25
                                                }
                                                
                                                
                                            })
        optionMenu.addAction(x1)
        
        // }
       
        let x2 = UIAlertAction(title: "0.5x", style: .default, handler:
                                            {
                                                (alert: UIAlertAction!) -> Void in
                                                
                                               
                                                if self.player != nil{
                                                    
                                                    self.player?.rate =  0.5
                                                }
                                                
                                                
                                                
                                                
                                            })
        optionMenu.addAction(x2)
        
        let x3 = UIAlertAction(title: "0.75x", style: .default, handler:
                                            {
                                                (alert: UIAlertAction!) -> Void in
                                                
                                               
                                                
                                                
                                                 if self.player != nil{
                                                     
                                                     self.player?.rate =  0.75
                                                 }
                                                 
                                                
                                                
                                                
                                            })
        optionMenu.addAction(x3)
        
        let x4 = UIAlertAction(title: "Normal", style: .default, handler:
                                            {
                                                (alert: UIAlertAction!) -> Void in
                                                
                                               
                                                
                                                if self.player != nil{
                                                    
                                                    self.player?.rate =  1.0
                                                }
                                                
                                                
                                                
                                                
                                            })
        optionMenu.addAction(x4)
        
        
        
        
        let x5 = UIAlertAction(title: "1.25x", style: .default, handler:
                                            {
                                                (alert: UIAlertAction!) -> Void in
                                                
                                               
                                                
                                                
                                                if self.player != nil{
                                                    
                                                    self.player?.rate =  1.25
                                                }
                                                
                                                
                                                
                                            })
        optionMenu.addAction(x5)
        
        
        
    
        
        
        let x7 = UIAlertAction(title: "1.5x", style: .default, handler:
                                            {
                                                (alert: UIAlertAction!) -> Void in
                                                
                                               
                                                if self.player != nil{
                                                    
                                                    self.player?.rate =  1.5
                                                }
                                                
                                                
                                                
                                                
                                            })
        optionMenu.addAction(x7)
        let x8 = UIAlertAction(title: "1.75x", style: .default, handler:
                                            {
                                                (alert: UIAlertAction!) -> Void in
                                                
                                               
                                                if self.player != nil{
                                                    
                                                    self.player?.rate =  1.75
                                                }
                                                
                                                
                                                
                                                
                                            })
        optionMenu.addAction(x8)
        
        let x9 = UIAlertAction(title: "2x", style: .default, handler:
                                            {
                                                (alert: UIAlertAction!) -> Void in
                                                
                                               
                                                if self.player != nil{
                                                    
                                                    self.player?.rate =  2.0
                                                }
                                                
                                                
                                                
                                                
                                            })
        optionMenu.addAction(x9)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler:
                                            {
                                                (alert: UIAlertAction!) -> Void in
                                            })
        cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
        
        optionMenu.addAction(cancelAction)
        
        
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    
    
    
    func selectQuality(){
        let optionMenu = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .actionSheet)
        
        optionMenu.view.tintColor  = UICommonMethods.hexStringToUIColor(hex: "#009E4F")
        
        
        // if let p240 =  selectedDataModel?.quality240p?.url{
        let deleteAction = UIAlertAction(title: "Auto", style: .default, handler:
                                            {
                                                (alert: UIAlertAction!) -> Void in
                                                
                                                var p240:String =  self.selectedDataModel?.quality240p?.url ?? ""
                                                
                                                
                                                if !p240.isEmpty{
                                                    
                                                    
                                                    self.videourl = p240.removingPercentEncoding ?? ""
                                                    print(self.videourl)
                                                    if self.player != nil {
                                                        self.player?.pause()
                                                    }
                                                    self.setUpVideoPlayer()
                                                }
                                                
                                                
                                                
                                                
                                                
                                            })
        optionMenu.addAction(deleteAction)
        
        // }
        if let p240 =  selectedDataModel?.quality240p?.url{
            if !p240.isEmpty{
                let deleteAction = UIAlertAction(title: "240p", style: .default, handler:
                                                    {
                                                        (alert: UIAlertAction!) -> Void in
                                                        //  let p240:String =  self.selectedDataModel?.quality240p?.url ?? ""
                                                        
                                                        
                                                        if !p240.isEmpty{
                                                            
                                                            
                                                            self.videourl = p240.removingPercentEncoding ?? ""
                                                            print(self.videourl)
                                                            
                                                            if self.player != nil {
                                                                self.player?.pause()
                                                            }
                                                            self.setUpVideoPlayer()
                                                        }
                                                    })
                optionMenu.addAction(deleteAction)
            }
           
            
        }
        
        if let p360 =  selectedDataModel?.quality360p?.url{
            if !p360.isEmpty{
                let deleteAction = UIAlertAction(title: "360p", style: .default, handler:
                                                    {
                                                        (alert: UIAlertAction!) -> Void in
                                                        // var p360:String =  self.selectedDataModel?.quality360p?.url ?? ""
                                                        
                                                        
                                                        if !p360.isEmpty{
                                                            
                                                            
                                                            self.videourl = p360.removingPercentEncoding ?? ""
                                                            print(self.videourl)
                                                            
                                                            if self.player != nil {
                                                                self.player?.pause()
                                                            }
                                                            self.setUpVideoPlayer()
                                                        }
                                                    })
                optionMenu.addAction(deleteAction)
            }
            
            
        }
        
        if let p480 =  selectedDataModel?.quality480p?.url{
            if !p480.isEmpty{
                let deleteAction = UIAlertAction(title: "480p", style: .default, handler:
                                                    {
                                                        (alert: UIAlertAction!) -> Void in
                                                        // var p480:String =  self.selectedDataModel?.quality480p?.url ?? ""
                                                        
                                                        
                                                        if !p480.isEmpty{
                                                            
                                                            
                                                            self.videourl = p480.removingPercentEncoding ?? ""
                                                            print(self.videourl)
                                                            
                                                            if self.player != nil {
                                                                self.player?.pause()
                                                            }
                                                            self.setUpVideoPlayer()
                                                        }
                                                    })
                optionMenu.addAction(deleteAction)
            }
            
            
        }
        
        if let p720 =  selectedDataModel?.quality720p?.url{
            
            if !p720.isEmpty{
                let deleteAction = UIAlertAction(title: "720p", style: .default, handler:
                                                    {
                                                        (alert: UIAlertAction!) -> Void in
                                                        // var p720:String =  self.selectedDataModel?.quality720p?.url ?? ""
                                                        
                                                        
                                                        if !p720.isEmpty{
                                                            
                                                            
                                                            self.videourl = p720.removingPercentEncoding ?? ""
                                                            print(self.videourl)
                                                            
                                                            if self.player != nil {
                                                                self.player?.pause()
                                                            }
                                                            self.setUpVideoPlayer()
                                                        }
                                                    })
                optionMenu.addAction(deleteAction)
            }
            
            
            
        }
        if let p1080 =  selectedDataModel?.quality1080p?.url{
            if !p1080.isEmpty{
                let deleteAction = UIAlertAction(title: "1080p", style: .default, handler:
                                                    {
                                                        (alert: UIAlertAction!) -> Void in
                                                        //  var p1080:String =  self.selectedDataModel?.quality1080p?.url ?? ""
                                                        
                                                        
                                                        if !p1080.isEmpty{
                                                            
                                                            
                                                            self.videourl = p1080.removingPercentEncoding ?? ""
                                                            print(self.videourl)
                                                            
                                                            if self.player != nil {
                                                                self.player?.pause()
                                                            }
                                                            self.setUpVideoPlayer()
                                                        }
                                                    })
                optionMenu.addAction(deleteAction)
            }
            
            
        }
        
        
        
        
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler:
                                            {
                                                (alert: UIAlertAction!) -> Void in
                                            })
        cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
        
        optionMenu.addAction(cancelAction)
        
        
        self.present(optionMenu, animated: true, completion: nil)
    }
    func downloadQuality(){
        let optionMenu = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .actionSheet)
        
        optionMenu.view.tintColor  = UICommonMethods.hexStringToUIColor(hex: "#009E4F")
        
        
        if let p720 =  selectedDataModel?.quality720p?.url{
            
            if !p720.isEmpty{
                let deleteAction = UIAlertAction(title: "High (720p)", style: .default, handler:
                                                    {
                                                        (alert: UIAlertAction!) -> Void in
                                                        
                                                        
                                                        
                                                        let urlstr = p720.removingPercentEncoding ?? ""
                                                        
                                                        
                                                        
                                                        if !urlstr.isEmpty{
                                                            
                                                            self.prepareDownloading(urlquality: urlstr, videoName: self.getVideoName())
                                                        }
                                                        
                                                        
                                                    })
                optionMenu.addAction(deleteAction)
            }
            
            
            
        }
        if let p360 =  selectedDataModel?.quality360p?.url{
            if !p360.isEmpty{
                let deleteAction = UIAlertAction(title: "Medium (360p)", style: .default, handler:
                                                    {
                                                        (alert: UIAlertAction!) -> Void in
                                                        
                                                        let urlstr = p360.removingPercentEncoding ?? ""
                                                        
                                                        
                                                        
                                                        if !urlstr.isEmpty{
                                                            
                                                            self.prepareDownloading(urlquality: urlstr, videoName: self.getVideoName())
                                                        }
                                                        
                                                    })
                optionMenu.addAction(deleteAction)
            }
            
            
        }
        
        if let p240 =  selectedDataModel?.quality240p?.url{
            
            if !p240.isEmpty{
                let deleteAction = UIAlertAction(title: "Low (240p)", style: .default, handler:
                                                    {
                                                        (alert: UIAlertAction!) -> Void in
                                                        let urlstr = p240.removingPercentEncoding ?? ""
                                                        
                                                        
                                                        
                                                        if !urlstr.isEmpty{
                                                            
                                                            self.prepareDownloading(urlquality: urlstr, videoName: self.getVideoName())
                                                        }
                                                    })
                optionMenu.addAction(deleteAction)
            }
          
            
        }
        
        
        
        
        
        
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler:
                                            {
                                                (alert: UIAlertAction!) -> Void in
                                            })
        cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
        
        optionMenu.addAction(cancelAction)
        
        
        self.present(optionMenu, animated: true, completion: nil)
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    /*
     
     */
    
    @IBAction func onTappedFavourite(_ sender: Any) {
        processFavourite()
    }
    @IBAction func onTappedShare(_ sender: Any) {
        
        if let videourl =  selectedDataModel?.shareablURL{
            let url =  videourl.removingPercentEncoding ?? ""
            if let name = URL(string: url), !name.absoluteString.isEmpty {
                let objectsToShare = [name]
                let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                self.present(activityVC, animated: true, completion: nil)
            } else {
                // show alert for not available
            }
        }
        
        
    }
    
    @IBAction func onTappedDownload(_ sender: Any) {
        callBottomSheet()
        
    }
    
    @IBAction func onTappedVimeo(_ sender: Any) {
        if let videourl =  selectedDataModel?.vimeoLink{
            let url =  videourl.removingPercentEncoding ?? ""
            if let name = URL(string: url), !name.absoluteString.isEmpty {
                let objectsToShare = [name]
                let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                self.present(activityVC, animated: true, completion: nil)
            } else {
                // show alert for not available
            }
        }
    }
    
    @IBAction func onTappedYoutube(_ sender: Any) {
        if let videourl =  selectedDataModel?.youtubeLink{
            let url =  videourl.removingPercentEncoding ?? ""
            if let name = URL(string: url), !name.absoluteString.isEmpty {
                let objectsToShare = [name]
                let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                self.present(activityVC, animated: true, completion: nil)
            } else {
                // show alert for not available
            }
        }
    }
    
    
    @IBAction func onTappedPervious(_ sender: Any) {
        
        self.player?.pause()
        playerItem?.seek(to: .zero, completionHandler: nil)
        
        /*playingVideoCount =  playingVideoCount - 1
         if playingVideoCount < 0{
         playingVideoCount =  dictionaryCategories.count-1
         }else{
         
         }
         print(playingVideoCount)*/
        if selectedDataModel != nil{
            if let currentModel:DictionaryDatum = selectedDataModel{
                //let index = dictionaryCategoriesTemp.firstIndex(of: currentModel)
                var index  = dictionaryCategoriesTemp.firstIndex(where: { $0.id == currentModel.id }) ?? 0
                if index > 0{
                    index = index - 1
                    
                }else{
                    index = 0
                    
                }
                selectedDataModel  =  dictionaryCategoriesTemp[index]
                setUpSorting()
            }
            
            
        }
        
    }
    
    @IBAction func onTappedForward(_ sender: Any) {
        self.player?.pause()
        playerItem?.seek(to: .zero, completionHandler: nil)
        
        /* if playingVideoCount > dictionaryCategories.count{
         playingVideoCount =  0
         }else{
         
         }*/
        
        print(playingVideoCount)
        
        selectedDataModel  =  dictionaryCategories[playingVideoCount]
        setUpSorting()
    }
    
    
    @IBAction func onTappedChangeLanguage(_ sender: Any) {
        
        if let selectModel = selectedDataModel{
            
            
            var id = selectModel.parent
            if isEnglishOn{
                isEnglishOn  = false
                let value = storyUrduTypes.filter { $0.id == id }
                if value.count > 0{
                    self.selectedDataModel = value[0]

                }
                dictionaryCategoriesTemp =  storyUrduTypes

            }else{
                isEnglishOn  = true
                let value = storyEnglishTypes.filter { $0.id == id }
                if value.count > 0{
                    self.selectedDataModel = value[0]
                }
                
                dictionaryCategoriesTemp =  storyEnglishTypes
            }
            self.player?.pause()

            setUpSorting()
            //
        }
        
       
    }
    
    
    @IBAction func onTappedDownloadLesson(_ sender: Any) {
        
        let center = UNUserNotificationCenter.current()

        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                print("Yay!")
            } else {
                print("D'oh")
            }
        }
        
        getDownloadLesson()
    
    
        showDownloadLessonAlertController(style: .actionSheet, title: "Select Lesson to Download", action: nil, height: nil,isDownload: true)
    }
    
    
    
    @IBAction func onTappedViewLesson(_ sender: Any) {
        getDownloadLesson()
        showDownloadLessonAlertController(style: .actionSheet, title: "Select Lesson to View", action: nil, height: nil,isDownload: false)
    }
    
    
    func getDownloadLesson(){
        downloadDataArray.removeAll()
        downloadselectedArray.removeAll()
        if let documentList:[Document] =  selectedDataModel?.documents{
            
            for i in 0..<documentList.count {
                print(i)
                downloadDataArray.append(documentList[i].name ?? "")
            }
            
            
        }
    }
    /*
     Process the
     */
    func processFavourite(){
        
        if selectedDataModel !=  nil{
            
            if selectedDataModel?.favorite == 0{
                let image : UIImage = UIImage(named:"favourite")!
                imgFavourite.image = image
                selectedDataModel?.favorite =  1
                
                
                if let videoid = selectedDataModel?.id{
                    UICommonMethods.AddToFavourite(type: selectType, id: videoid)
                    
                }
                
                
                
                
                
                
                
                
                
            }else if selectedDataModel?.favorite ==  1{
                let image : UIImage = UIImage(named:"favouriteicon")!
                imgFavourite.image = image
                selectedDataModel?.favorite =  0
                if let videoid = selectedDataModel?.id{
                    UICommonMethods.RemoveToFavourite(type: selectType, id: videoid)
                    
                }
                
                
                
            }
            
            
            if let indexOfItem = dictionaryCategoriesTemp.firstIndex(where: { (item) -> Bool in
                return item.englishWord == selectedDataModel?.englishWord
            }) {
                print("\(indexOfItem)")
                
                dictionaryCategoriesTemp[indexOfItem] =  selectedDataModel!
            }
            else {
                print("item not found")
            }
            
            
            
            
        }
        
    }
    
    
    
    
    
    
    
    
    
    /*
     Custom Video Player
     */
    
    func setUpVideoPlayer(){
       
        if  videourl != nil && !videourl.isEmpty{
            print("hello")

            if let url1 = URL(string: videourl){
                print("hello")
                let asset = AVAsset(url: url1)
                playerItem = AVPlayerItem(asset: asset)
                player = AVPlayer(playerItem: playerItem)
                playerReSubcribe()
                playerLayer = AVPlayerLayer(player: player)
                self.videoplayer.layer.addSublayer(playerLayer!)
                
                definesize = CGSize(width: self.videoplayer.frame.width, height: self.videoplayer.frame.height)
                playerLayer?.frame.size = definesize! //bounds of the view in which AVPlayer should be displayed
                playerLayer?.videoGravity = .resizeAspect
                
                player?.rate = 0.1
                player?.play()
                //    self.loaderView.isHidden = false
                
                player?.isMuted = false
                slider.value = 0
                /* if let duration = playerItem?.asset.duration{
                 let seconds : Float64 = CMTimeGetSeconds(duration)
                 print(seconds)
                 }*/
                //let duration : CMTime = playerItem?.asset.duration ?? 00
                
                
                // slider.addTarget(self, action: #selector(self.playbackSliderValueChanged(_:)), for: .valueChanged)
                
                isPause = false
                if #available(iOS 13.0, *) {
                    btnPlay.setImage(UIImage(systemName: "pause.fill"), for: .normal)
                    btnplay2.setImage(UIImage(systemName: "pause.fill"), for: .normal)
                    
                } else {
                    // Fallback on earlier versions
                }
                
                
                
                
                if let duration =  selectedDataModel?.duration{
                    lblTotalDuration.text = duration
                    lblcurrentDuration.text = "00:00"
                }
                let gesture = UITapGestureRecognizer(target: self, action:  #selector(self.checkAction))
                self.mainView.addGestureRecognizer(gesture)
            }
          
        }
        
        
    }
    
    
    
    func playerDelegate(){
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerEndedPlaying), name: Notification.Name("AVPlayerItemDidPlayToEndTimeNotification"), object: nil)
    }
    
    func playerReSubcribe(){
        
        player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 2), queue: DispatchQueue.main) {[weak self] (progressTime) in
            if let duration = self?.player?.currentItem?.duration {
                let durationSeconds = CMTimeGetSeconds(duration)
                //if ((self?.isDownloadVideo) != nil){
                if durationSeconds > 0{
                    self?.slider.maximumValue = Float(durationSeconds)
                    
                }
                
                // }
                
                let seconds = CMTimeGetSeconds(progressTime)
                if let currentTime  = self?.player?.currentItem?.currentTime().seconds{
                    
                    
                    self?.slider.value = Float(currentTime)
                    
                    //if isDownloadVideo
                    let time =  self?.formatTimeFor(seconds: currentTime)
                    print(time)
                    self?.lblcurrentDuration.text = time
                    
                }
                
                
                let progress = Float(seconds)
                print(progress)
                DispatchQueue.main.async {
                    /* self?.progressBar.progress = progress
                     if progress >= 1.0 {
                     self?.progressBar.progress = 0.0
                     }*/
                    //  self?.slider.value = progress
                    
                }
            }
        }
        player?.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)
    }
    func removePlayerListner(){
        NotificationCenter.default.removeObserver(self as Any, name: Notification.Name("AVPlayerItemDidPlayToEndTimeNotification"), object: nil)
        // player?.removeObserver(self, forKeyPath: "timeControlStatus")
    }
    @objc func playerEndedPlaying(_ notification: Notification) {
        DispatchQueue.main.async {[weak self] in
            if let playerItem = notification.object as? AVPlayerItem {
                self?.player?.pause()
                self?.isPause = true
                self?.changepausebutton()
                playerItem.seek(to: .zero, completionHandler: nil)
                let status = self?.autoplaysSwitch.isOn ?? false
                if status{
                    
                    // if dictionaryCategories.count
                    if self?.dictionaryCategories.count ?? 0 > 0{
                        let currentModel = self?.dictionaryCategories[self?.playingVideoCount ?? 0]
                        self?.selectedDataModel = currentModel
                        self?.setUpSorting()
                    }
                    
                }
                
                
                
            }
            
            
        }
    }
    
    @objc func checkFullScreen(sender : UITapGestureRecognizer) {
        // Do what you want
        var value  = UIInterfaceOrientation.landscapeRight.rawValue
        if UIApplication.shared.statusBarOrientation == .landscapeLeft || UIApplication.shared.statusBarOrientation == .landscapeRight{
            value = UIInterfaceOrientation.portrait.rawValue
            if #available(iOS 13.0, *) {
                parentView.backgroundColor =  UIColor.systemBackground
            } else {
                // Fallback on earlier versions
                parentView.backgroundColor =  UIColor.white

            }
            self.navigationController?.navigationBar.isHidden =  false
        }else{
            parentView.backgroundColor =  UIColor.black

            self.navigationController?.navigationBar.isHidden =  true

        }
        
        UIDevice.current.setValue(value, forKey: "orientation")
        UIViewController.attemptRotationToDeviceOrientation()
        playerLayer?.frame = self.videoplayer.bounds
        //playerLayer?.videoGravity = .resizeAspect
    }
    
    
    @objc func checkAction(sender : UITapGestureRecognizer) {
        // Do what you want
        print("hello")
     //   controlAnimated()

        if optionView.isHidden{
            optionView.isHidden = false
            UIView.animate(
                withDuration: 0.35,
                delay: 0,
                usingSpringWithDamping: 0.9,
                initialSpringVelocity: 1,
                options: [],
                animations: {
                    self.playerBar.isHidden =  false
                    self.btnfullscreen.isHidden = false
                },
                completion: nil
            )
            
        }else{
            optionView.isHidden = true
            
            UIView.animate(
                withDuration: 0.35,
                delay: 0,
                usingSpringWithDamping: 0.9,
                initialSpringVelocity: 1,
                options: [],
                animations: {
                   self.playerBar.isHidden =  true
                   self.btnfullscreen.isHidden = true

                },
                completion: nil
            )
            
        }
    }
    
    
    @objc func avPlayerDidDismiss(_ notification: Notification) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {[weak self] in
            //self?.isMuted = true
            //self?.playVideo()
            NotificationCenter.default.removeObserver(self as Any, name: Notification.Name("avPlayerDidDismiss"), object: nil)
        }
    }
    
    
    
    @IBAction func onTappadPause(_ sender: Any) {
        
        if isPause{
            player?.play()
            isPause = false
            if #available(iOS 13.0, *) {
                btnPlay.setImage(UIImage(systemName: "pause.fill"), for: .normal)
                btnplay2.setImage(UIImage(systemName: "pause.fill"), for: .normal)
                
            } else {
                // Fallback on earlier versions
            }
            
        }else{
            player?.pause()
            isPause = true
            if #available(iOS 13.0, *) {
                btnPlay.setImage(UIImage(systemName: "play.fill"), for: .normal)
                btnplay2.setImage(UIImage(systemName: "play.fill"), for: .normal)
                
            } else {
                // Fallback on earlier versions
            }
            
            
        }
        
        
        
    }
    
    
    
    @IBAction func onTappedOption(_ sender: Any) {
    }
    
    
    
    @IBAction func onTappedFullScreen(_ sender: Any) {
        var value  = UIInterfaceOrientation.landscapeRight.rawValue
        if UIApplication.shared.statusBarOrientation == .landscapeLeft || UIApplication.shared.statusBarOrientation == .landscapeRight{
            value = UIInterfaceOrientation.portrait.rawValue
            if #available(iOS 13.0, *) {
                parentView.backgroundColor =  UIColor.systemBackground
            } else {
                // Fallback on earlier versions
                parentView.backgroundColor =  UIColor.white

            }
            self.navigationController?.navigationBar.isHidden =  false
        }else{
            parentView.backgroundColor =  UIColor.black

            self.navigationController?.navigationBar.isHidden =  true

        }
        
        UIDevice.current.setValue(value, forKey: "orientation")
        UIViewController.attemptRotationToDeviceOrientation()
        playerLayer?.frame = self.videoplayer.bounds
        //playerLayer?.videoGravity = .resizeAspect
        
    }
    
    
    
    
    
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "timeControlStatus", let change = change, let newValue = change[NSKeyValueChangeKey.newKey] as? Int, let oldValue = change[NSKeyValueChangeKey.oldKey] as? Int {
            let oldStatus = AVPlayer.TimeControlStatus(rawValue: oldValue)
            let newStatus = AVPlayer.TimeControlStatus(rawValue: newValue)
            if newStatus != oldStatus {
                DispatchQueue.main.async {[weak self] in
                    if newStatus == .playing {
                        self?.loaderView.isHidden = true
                       // self?.playerBar.isHidden =  true
                       /* DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5) {

                        }*/
                        
                        UIView.animate(
                            withDuration: 0.35,
                            delay: 5.0,
                            usingSpringWithDamping: 0.9,
                            initialSpringVelocity: 1,
                            options: [],
                            animations: {
                               self?.playerBar.isHidden =  true
                              self?.btnfullscreen.isHidden =  true
                                self?.optionView.isHidden = true
                            },
                            completion: nil
                        )
                    }else if(newStatus == .paused){
                        self?.loaderView.isHidden = true
                        UIView.animate(
                            withDuration: 0.35,
                            delay: 5.0,
                            usingSpringWithDamping: 0.9,
                            initialSpringVelocity: 1,
                            options: [],
                            animations: {
                               self?.playerBar.isHidden =  false
                               self?.btnfullscreen.isHidden =  false
                                self?.optionView.isHidden = false

                            },
                            completion: nil
                        )
                    }
                    
                    else {
                        self?.loaderView.isHidden = false
                        
                        UIView.animate(
                            withDuration: 0.35,
                            delay: 5.0,
                            usingSpringWithDamping: 0.9,
                            initialSpringVelocity: 1,
                            options: [],
                            animations: {
                               self?.playerBar.isHidden =  false
                               self?.btnfullscreen.isHidden =  false
                                self?.optionView.isHidden = false

                            },
                            completion: nil
                        )
                       
                    }
                }
            }
        }
    }
    
    
    
    
    /*
     Orrivide Transctiion
     */
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        var timeDuration: TimeInterval = 0.3 //for iPads
        
        
        if UIDevice.current.orientation.isLandscape {
            parentView.backgroundColor =  UIColor.black

            self.navigationController?.navigationBar.isHidden =  true
            if UIDevice.current.orientation == .landscapeLeft{
                UIView.animate(withDuration: timeDuration, animations: {
                    let degrees : Double = 0; //the value in degrees
                    let affineTransform = CGAffineTransform(rotationAngle: CGFloat(degrees * .pi/180))
                   self.mainView!.transform = CGAffineTransform(rotationAngle: CGFloat(degrees * .pi/180))
                   self.videoplayer.transform = affineTransform
                    
                    
                })
            }/*else if UIDevice.current.orientation == .landscapeRight{
                let degrees : Double = -180; //the value in degrees
                let affineTransform = CGAffineTransform(rotationAngle: CGFloat(degrees * .pi/90))
               self.mainView!.transform = CGAffineTransform(rotationAngle: CGFloat(degrees * .pi/90))
               self.videoplayer.transform = affineTransform
            }*/else{
                UIView.animate(withDuration: timeDuration, animations: {
                    let degrees : Double = -180; //the value in degrees
                    self.mainView!.transform = CGAffineTransform(rotationAngle: CGFloat(degrees * .pi/90))
                   
                    //self.mainView.frame = someRect
                    //self.videoplayer.frame = someRect
                    // self.videoplayer.layer.removeFromSuperlayer()
                    
                    
                })
            }
            
            coordinator.animate(alongsideTransition: { (context) in
            }) { (context) in
                /* self.mainView.frame.size = size
                 self.nsMainViewHeight.constant =  size.height
                 // self.playerLayer?.frame.size = size
                 
                 print(size.width)
                 print(self.controlView.frame.width)
                 // self.playerLayer?.frame.size = size //bounds of the view in which AVPlayer should be displayed
                 self.playerLayer?.videoGravity = .resizeAspect
                 
                 //   self.playerLayer?.frame.size = size*/
                print(size.height)
                print(size.width)
                
                let sizeheight = size.height
                var minusheight = 40
                if UIScreen.main.nativeBounds.height >= 2778{
                    minusheight = 72
                }else if  UIScreen.main.nativeBounds.height >= 2532{
                    minusheight = 52

                }
                self.nsMainViewHeight.constant =  sizeheight
                let  definesize = CGSize(width:  self.videoplayer.frame.width, height:  sizeheight)
                self.videoplayer.frame.size = definesize
                
                let someRect = CGRect(x: 0, y: 0, width: definesize.width, height: sizeheight)
                
                self.playerLayer?.frame =  someRect
                self.playerLayer?.frame.size = definesize
                
                self.playerLayer?.videoGravity = .resizeAspect
                //self.mainView.frame = someRect
                //self.videoplayer.frame = someRect
                // self.videoplayer.layer.removeFromSuperlayer()
                
                self.playerLayer = AVPlayerLayer(player: self.player)
                self.videoplayer.layer.addSublayer(self.playerLayer!)
                
                //self.playerLayer?.frame.size = self.mainView.frame.size//bounds of the view in which AVPlayer should be displayed
                // playerLayer?.videoGravity = .resizeAspect
                
                //self.playerLayer?.frame.size = size
                self.playerLayer?.videoGravity = .resizeAspect
                
                
                
                
                
                // self.setUpVideoPlayer()
                // self.playerLayer?.frame.size = self.definesize!
                // self.playerLayer?.videoGravity = .resizeAspect
                
            }
        } else {
            
            if #available(iOS 13.0, *) {
                parentView.backgroundColor =  UIColor.systemBackground
            } else {
                // Fallback on earlier versions
                parentView.backgroundColor =  UIColor.white

            }

            self.navigationController?.navigationBar.isHidden =  false
            
            if UIDevice.current.orientation == .portraitUpsideDown{
                UIView.animate(withDuration: timeDuration, animations: {
                    let degrees : Double = -90; //the value in degrees

                    self.mainView!.transform = CGAffineTransform(rotationAngle: CGFloat(degrees * .pi/180))
                  

                })
                  
            }else{
                UIView.animate(withDuration: timeDuration, animations: {
                    let degrees : Double = 0; //the value in degrees
           

                    self.mainView!.transform = CGAffineTransform(rotationAngle: CGFloat(degrees * .pi/180))
                    
                })
            }
            //  let definesize = CGSize(width: self.videoplayer.frame.width, height: self.videoplayer.frame.height)
            
            coordinator.animate(alongsideTransition: { (context) in
            }) { (context) in
                //
                let degrees : Double = -90; //the value in degrees
                
                let de = CGAffineTransform(rotationAngle: CGFloat(degrees * .pi/180))
                self.playerLayer = AVPlayerLayer(player: self.player)
                self.videoplayer.layer.sublayers = nil
                self.videoplayer.layer.addSublayer(self.playerLayer!)
                self.nsMainViewHeight.constant =  250
                let  definesize = CGSize(width: self.view.frame.width, height: 250)
                self.playerLayer?.frame.size = definesize
                //self.playerLayer?.videoGravity = .resizeAspect
              

              //let affineTransform = CGAffineTransform(rotationAngle: de)
                 // self.playerLayer?.frame.size = self.definesize!
                //self.playerLayer?.videoGravity = .resizeAspect
                
            }
        }
        
        
    }
    
    
    func callBottomSheet(){
        
        
        downloadQuality()
        // View controller the bottom sheet will hold
        /*simpleDataArray.removeAll()
         if selectedDataModel != nil{
         
         if let qualitiy240p = selectedDataModel?.quality240p?.url{
         simpleDataArray.append("240p")
         }
         if let qualitiy360p = selectedDataModel?.quality360p?.url{
         simpleDataArray.append("360p")
         }
         if let qualitiy480p = selectedDataModel?.quality480p?.url{
         simpleDataArray.append("480p")
         }
         if let qualitiy720p = selectedDataModel?.quality720p?.url{
         simpleDataArray.append("720p")
         }
         if let qualitiy1080p = selectedDataModel?.quality1080p?.url{
         simpleDataArray.append("1080p")
         }
         }
         
         
         showAsAlertController(style: .actionSheet, title: "Select Sorting", action: nil, height: nil)*/
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
                //self?.sortArray(textStr: textStr)
                
                
                
                var urlstr = ""
                
                if textStr == "240p"{
                    urlstr = self?.selectedDataModel?.quality240p?.url ?? ""
                }else if textStr == "360p"{
                    urlstr = self?.selectedDataModel?.quality360p?.url ?? ""
                }else if  textStr == "480p"{
                    urlstr = self?.selectedDataModel?.quality480p?.url ?? ""
                }else if textStr == "720p"{
                    urlstr = self?.selectedDataModel?.quality720p?.url ?? ""
                }else if textStr == "1080p"{
                    urlstr = self?.selectedDataModel?.quality1080p?.url ?? ""
                }
                
                if !urlstr.isEmpty{
                    
                    self?.prepareDownloading(urlquality: urlstr, videoName: self?.getVideoName() ?? "")
                }
                
                
                
                
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
    
    
    func getVideoName()->String{
        
        var headingName: String = ""
        var subHeadingName: String = ""
        var typeStr:String = ""
        if  selectType == UIContant.TYPE_DICTIONARY{
            typeStr = "Dictionary"
            headingName =  selectedDataModel?.englishWord ?? ""
            if headingName == "-"{
                headingName =  selectedDataModel?.urduWord ?? ""
            }
            
            
            
        }else if selectType == UIContant.TYPE_TEACHER{
            typeStr = "Teacher Tutorials"
            
            headingName =  selectedDataModel?.title ?? ""
            subHeadingName =  ""
            
        }else if selectType == UIContant.TYPE_STORIES{
            typeStr = "Stories"
            headingName =  selectedDataModel?.title ?? ""
            subHeadingName =  ""
        }else if selectType == UIContant.TYPE_LEARNING{
            typeStr = "Learning"
            headingName =  selectedDataModel?.title ?? ""
            subHeadingName =  ""
        }else if selectType == UIContant.TYPE_SKILL{
            typeStr = "Life Skills"
            headingName =  selectedDataModel?.title ?? ""
            subHeadingName =  ""
        }
        
        headingName =  headingName+""
        return headingName
    }
    /*
     Download Section
     */
    
    func prepareDownloading(urlquality:String,videoName:String){
        var availableDownloadsArray: [String] = []
        
        var videourl = urlquality.removingPercentEncoding ?? ""
        print(videourl)
        if !videourl.isEmpty{
            let myDownloadPath = MZUtility.baseFilePath + "/PSLVideos"
            if !FileManager.default.fileExists(atPath: myDownloadPath) {
                try! FileManager.default.createDirectory(atPath: myDownloadPath, withIntermediateDirectories: true, attributes: nil)
            }
            
            debugPrint("custom download path: \(myDownloadPath)")
            availableDownloadsArray.append(videourl)
            
            
            let fileURL  : NSString = availableDownloadsArray[0] as NSString
            var fileName : NSString = videoName as NSString
            fileName =  fileName.replacingOccurrences(of: " ", with: "_") as NSString
        //    var value = fileName
        
            var name:NSString = fileName
            name =  name as String+".mp4" as NSString
            
            print(name)
            fileName = MZUtility.getUniqueFileNameWithPath((myDownloadPath as NSString).appendingPathComponent(name as String) as NSString)
            
            
            
            if let nearestEnclosingTabBarController:DashboardTabBarViewController = self.tabBarController as? DashboardTabBarViewController{
                //if nearestEnclosingTabBarController as! DashboardTabBarViewController{
                
                
                
                downloadIamge.image =  UIImage(named: "navdownload")
                nearestEnclosingTabBarController.downloadManager.addDownloadTask(fileName as String, fileURL: fileURL as String, destinationPath: myDownloadPath)
                
                if let model = self.selectedDataModel{
                    
                    if checkRecord(id: String(model.id ?? 0)) == 0{
                        createData(selectedDataModel: model, videoName: fileName as String)
                        
                    }
                }
                
                self.showToast(message: "Downloading is start...", seconds: 1.0)
                // }
                
            }
            
        }
        
        
    }
    
    
    func createData(selectedDataModel:DictionaryDatum,videoName:String){
        
        //As we know that container is set up in the AppDelegates so we need to refer that container.
        
        
        //We need to create a context from this container
        let manager = CoreDataManager.Instance
        
        let managedContext = manager.managedObjectContext
        
        //Now let’s create an entity and new user records.
        let userEntity = NSEntityDescription.entity(forEntityName: "Downloadvideos", in: managedContext)!
        
        //final, we need to add some data to our newly created record for each keys using
        //here adding 5 data with loop
        
        
        
        let user = NSManagedObject(entity: userEntity, insertInto: managedContext)
        if let id = selectedDataModel.id{
            user.setValue(id, forKeyPath: "videoid")
            
        }
        
        user.setValue(videoName, forKeyPath: "videoName")
        user.setValue(MZUtility.baseFilePath + "/PSLVideos/"+videoName, forKeyPath: "videopath")
        
        
        if let duration = selectedDataModel.duration{
            user.setValue(duration, forKeyPath: "videoduration")
            
        }
        if let poster = selectedDataModel.poster{
            let thumnail = poster.removingPercentEncoding
            user.setValue(thumnail, forKeyPath: "videoThumnail")
            
        }
        
        
        
        
        //Now we have set all the values. The next step is to save them inside the Core Data
        
        do {
            try managedContext.save()
            
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    
    
    
    func checkRecord(id:String)->Int {
        var count:Int = 0
        //As we know that container is set up in the AppDelegates so we need to refer that container.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return 0 }
        
        //We need to create a context from this container
        let manager = CoreDataManager.Instance
        
        let managedContext = manager.managedObjectContext
        //Prepare the request of type NSFetchRequest  for the entity
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Downloadvideos")
        let predicateID = NSPredicate(format: "videoid == %@",id)
        fetchRequest.predicate = predicateID
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
    
    
    func getAllWords(word:String)->[DictionaryDatum] {
        var dataList = [DictionaryDatum]()
        
        let manager = CoreDataManager.Instance
        
        let managedContext = manager.managedObjectContext
        //Prepare the request of type NSFetchRequest  for the entity
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Words")
        
        let predicate = NSPredicate(format: "(english_word == '\(word)')")
        fetchRequest.predicate = predicate
        
        //
        do {
            let result = try managedContext.fetch(fetchRequest)
            print(result.count)
            for data in result as! [NSManagedObject] {
                
                let id = data.value(forKey: "id") as? Int
                let category_id = data.value(forKey: "category_id") as? Int
                let poster = data.value(forKey: "poster") as? String
                
                let english_word = data.value(forKey: "english_word") as? String
                print(english_word)
                
                //  if (english_word != "-" &&  english_word?.suffix(0) == searchTerm.suffix(0)){
                
                
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
                pocData.setValue(shareablURL ?? "", forKey: "shareablURL")

                pocData.setValue("", forKey: "title")
                pocData.setValue(0, forKey: "grade_id")
                pocData.setValue(0, forKey: "subject_id")
                
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
                
                //}
            }
            
        } catch {
            
            print("Failed")
        }
        
        return dataList
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        if self.player != nil{
            self.player?.pause()
            self.isPause = true
            // self.player?.playerItem.seek(to: .zero, completionHandler: nil)
        }
        navigationItem.largeTitleDisplayMode = .automatic
        self.tabBarController?.tabBar.isHidden =  false
        super.viewWillDisappear(true)
        print("view disappear")
        
        
        
    }
    func changepausebutton(){
        if #available(iOS 13.0, *) {
            btnPlay.setImage(UIImage(systemName: "play.fill"), for: .normal)
            btnplay2.setImage(UIImage(systemName: "play.fill"), for: .normal)
            
        } else {
            // Fallback on earlier versions
        }
        
    }
    func getHoursMinutesSecondsFrom(seconds: Double) -> (hours: Int, minutes: Int, seconds: Int) {
        let secs = Int(seconds)
        let hours = secs / 3600
        let minutes = (secs % 3600) / 60
        let seconds = (secs % 3600) % 60
        return (hours, minutes, seconds)
    }
    func formatTimeFor(seconds: Double) -> String {
        let result = getHoursMinutesSecondsFrom(seconds: seconds)
        let hoursString = "\(result.hours)"
        var minutesString = "\(result.minutes)"
        if minutesString.count == 1 {
            minutesString = "0\(result.minutes)"
        }
        var secondsString = "\(result.seconds)"
        if secondsString.count == 1 {
            secondsString = "0\(result.seconds)"
        }
        var time = "\(hoursString):"
        if result.hours >= 1 {
            time.append("\(minutesString):\(secondsString)")
        }
        else {
            time = "\(minutesString):\(secondsString)"
        }
        return time
    }
    
    func returnChunk(index:Int)->[DictionaryDatum]{
        var dict = [DictionaryDatum]()
        if index < dictionaryCategoriesTemp.count{
            for name in index..<dictionaryCategoriesTemp.count {
                //YOUR LOGIC....
                print(name)
                let model = dictionaryCategoriesTemp[name]
                dict.append(model)
                if dict.count == 5{
                    break
                }
            }
        }
        return dict
    }
    
    
    
    func showToast(message : String, seconds: Double){
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .actionSheet)
            alert.view.backgroundColor = UICommonMethods.hexStringToUIColor(hex: "#009E4F")
            //alert.view.alpha = 0.5
            alert.view.tintColor  = UICommonMethods.hexStringToUIColor(hex: "#FFFFFF")

            alert.view.layer.cornerRadius = 15
  
            self.present(alert, animated: true)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + seconds) {
                alert.dismiss(animated: true)
            }
        }
    
    
    
    /*
     // Selection List
     */
    func showDownloadLessonAlertController(style: UIAlertController.Style, title: String?, action: String?, height: Double?,isDownload:Bool) {
        let selectionType: SelectionType = style == .actionSheet ? .Single : .Multiple
        
        let selectionMenu =  RSSelectionMenu(selectionStyle: .multiple, dataSource: downloadDataArray) { (cell, name, indexPath) in
            cell.textLabel?.text = name
            cell.tintColor = UICommonMethods.hexStringToUIColor(hex: "#009E4F")
            
        }
        selectionMenu.dismissAutomatically = false
        selectionMenu.cellSelectionStyle = .checkbox
        selectionMenu.maxSelectionLimit = 1
        selectionMenu.setSelectedItems(items: downloadselectedArray) { [weak self] (item, index, isSelected, selectedItems) in
            
            // update your existing array with updated selected items, so when menu show menu next time, updated items will be default selected.
            self?.selectedDownloadLessonindex = index
            self?.downloadselectedArray = selectedItems
            print("hello"+String(selectedItems.count))
            if(selectedItems.count > 0){
                let textStr = selectedItems[0]
            }
            
            
            //   self?.lblFilter.text =
        }
        
        selectionMenu.onDismiss = { items in
           // self.downloadselectedArray = items
            if self.presentedViewController as? UIAlertController != nil {
                selectionMenu.dismiss()
            }
            if(self.downloadselectedArray.count > 0){
                self.downlessonaction(isDownload: isDownload)

            }
            //print("hello"+String(self.simplesSelectedArray.count))
            
        }
        var heightDef  = 50
        if UIScreen.main.nativeBounds.height >= 2532{
            heightDef = 80
        }
        if downloadDataArray.count > 1{
            selectionMenu.show(style: .actionSheet(title: nil, action: "Done", height:(Double(downloadDataArray.count) * Double(heightDef))), from: self)
        }else{
            selectionMenu.show(style: .actionSheet(title: nil, action: "Done", height:Double(heightDef)), from: self)
        }
        // show
    }
    
    
    
    
    
    func downlessonaction(isDownload:Bool){
        
        
        if let documentList:[Document] =  selectedDataModel?.documents{
            
            
            let lessonurl =  documentList[selectedDownloadLessonindex].url
            let dataurl =  lessonurl?.removingPercentEncoding ?? ""
            if isDownload{
                guard let url = URL(string: dataurl) else { return }
                       
                       let urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
                       
                       let downloadTask = urlSession.downloadTask(with: url)
                       downloadTask.resume()
            }else{
                guard let url = URL(string: dataurl) else {
                     return
                }

                if UIApplication.shared.canOpenURL(url) {
                     UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
            
        }
        
       
    }
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print("downloadLocation:", location)
        guard let url = downloadTask.originalRequest?.url else { return }
               let documentsPath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
               let destinationURL = documentsPath.appendingPathComponent(url.lastPathComponent)
               var filename = destinationURL.lastPathComponent
              // delete original copy
               try? FileManager.default.removeItem(at: destinationURL)
               // copy from temp to Document
               do {
                   try FileManager.default.copyItem(at: location, to: destinationURL)
                   //self.pdfURL = destinationURL
                   print()
                filename =  filename.replacingOccurrences(of: "_" , with: " ")
                scheduleNotification(fileName: filename)
               } catch let error {
                   print("Copy Error: \(error.localizedDescription)")
               }
    }
    func scheduleNotification(fileName:String) {
        let center = UNUserNotificationCenter.current()

        let content = UNMutableNotificationContent()
        content.title = fileName+" Downloaded"
        content.body = "File download sucessfully"
        content.categoryIdentifier = "alarm"
        content.userInfo = ["customData": "fizzbuzz"]
        content.sound = UNNotificationSound.default

      
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request)
    }
    
    func controlAnimated() {
        if (self.playerBar.isHidden) {
            UIView.animate(
                withDuration: 0.35,
                delay: 0,
                usingSpringWithDamping: 0.9,
                initialSpringVelocity: 1,
                options: [],
                animations: {
                    self.playerBar.isHidden =  false
                    self.btnfullscreen.isHidden =  false
                },
                completion: nil
            )
        }else{
            UIView.animate(
                withDuration: 0.35,
                delay: 0,
                usingSpringWithDamping: 0.9,
                initialSpringVelocity: 1,
                options: [],
                animations: {
                    self.playerBar.isHidden =  true
                    self.btnfullscreen.isHidden =  true

                },
                completion: nil
            )
        }
    }
    
    
    
   
    
    
   
   
}
