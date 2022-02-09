//
//  MoreViewController.swift
//  PSL
//
//  Created by MacBook on 04/03/2021.
//

import UIKit

class MoreViewController: UIViewController ,UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    var menuList  = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setDataFactory()
        setUpTableView()
    }
    func setDataFactory(){
        menuList.append("Recommend A word")
        menuList.append("About PSL")
        
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
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let identifier = "MenuTableViewCell"
        
        var cell: MenuTableViewCell! = tableView.dequeueReusableCell(withIdentifier: identifier) as? MenuTableViewCell
        if cell == nil {
            tableView.register(UINib(nibName: "MenuTableViewCell", bundle: nil), forCellReuseIdentifier: identifier)
            cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? MenuTableViewCell
        }
        
        cell.lblTitle.text =  menuList[indexPath.row]
        cell.selectionStyle = .none
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0{
            let mainstoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let newViewcontroller:RecomendWordViewController  = mainstoryboard.instantiateViewController(withIdentifier: "RecomendWordViewController") as! RecomendWordViewController
            self.navigationController?.pushViewController(newViewcontroller, animated: true)
            
        }else if indexPath.row == 1{
            guard let url = URL(string: "http://www.psl.org.pk/about/about-psl") else { return }
            UIApplication.shared.open(url)
        }
        
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
