//
//  HomeViewController.swift
//  PSL
//
//  Created by MacBook on 04/03/2021.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        stepUpSearchBar()
       
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    func stepUpSearchBar(){
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
    
    
    @IBAction func onTappedDictionary(_ sender: Any) {
        navigateToNext(selectType: UIContant.TYPE_DICTIONARY)
    }
    @IBAction func onTappedTeacherTutorail(_ sender: Any) {
        navigateToNext(selectType: UIContant.TYPE_TEACHER)
    }
    
    @IBAction func onTappedStories(_ sender: Any) {
        navigateToNext(selectType: UIContant.TYPE_STORIES)
    }
    @IBAction func onTappedLearningTutorail(_ sender: Any) {
        navigateToNext(selectType: UIContant.TYPE_LEARNING)
    }
    
    
    func navigateToNext(selectType :Int){
        let mainstoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewcontroller:MedaitorViewController  = mainstoryboard.instantiateViewController(withIdentifier: "MedaitorViewController") as! MedaitorViewController
        newViewcontroller.selectType = selectType
        self.navigationController?.pushViewController(newViewcontroller, animated: true)
    }
    
}
