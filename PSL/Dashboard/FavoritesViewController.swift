//
//  FavoritesViewController.swift
//  PSL
//
//  Created by MacBook on 04/03/2021.
//

import UIKit

class FavoritesViewController: UIViewController,UITableViewDataSource, UITableViewDelegate,UISearchResultsUpdating {
   
    
    
    @IBOutlet weak var tableView: UITableView!
    let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
       
        // Do any additional setup after loading the view.
        setUpsearchController()
        setUpTableView()
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
