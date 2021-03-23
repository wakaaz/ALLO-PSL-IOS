//
//  DownloadViewController.swift
//  PSL
//
//  Created by MacBook on 04/03/2021.
//

import UIKit

class DownloadViewController: UIViewController ,UITableViewDataSource, UITableViewDelegate,UISearchResultsUpdating{
   
    let searchController = UISearchController(searchResultsController: nil)

    @IBOutlet weak var nsVideoTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var nsCatTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var videoTableView: UITableView!
    @IBOutlet weak var catTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpsearchController()
        setUpTableView()
        setUpDataFactory()
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
    
    func setUpDataFactory(){
        nsCatTableViewHeight.constant =  2 * 100
        nsVideoTableViewHeight.constant =  4 * 100
        self.catTableView.reloadData()
        self.videoTableView.reloadData()
    }
    func setUpTableView(){
        self.catTableView.delegate = self
        self.catTableView.dataSource = self
        self.catTableView.separatorStyle = .singleLine
        self.catTableView.estimatedRowHeight = 100
        self.catTableView.separatorInset = .zero
        self.catTableView.layoutMargins = .zero
        self.catTableView.isEmptyRowsHidden =  true
        self.catTableView.isScrollEnabled = false

        self.catTableView.rowHeight = UITableView.automaticDimension
        
        self.videoTableView.delegate = self
        self.videoTableView.dataSource = self
        self.videoTableView.separatorStyle = .singleLine
        self.videoTableView.estimatedRowHeight = 100
        self.videoTableView.separatorInset = .zero
        self.videoTableView.layoutMargins = .zero
        self.videoTableView.isEmptyRowsHidden =  true
        self.videoTableView.isScrollEnabled = false
        self.videoTableView.rowHeight = UITableView.automaticDimension

    }

    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        print(text)
       
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
                let identifier = "FavouriteTableViewCell"
                
                var cell: FavouriteTableViewCell! = tableView.dequeueReusableCell(withIdentifier: identifier) as? FavouriteTableViewCell
                if cell == nil {
                    tableView.register(UINib(nibName: "FavouriteTableViewCell", bundle: nil), forCellReuseIdentifier: identifier)
                    cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? FavouriteTableViewCell
                }
                        
          cell.selectionStyle = .none
                return cell
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
