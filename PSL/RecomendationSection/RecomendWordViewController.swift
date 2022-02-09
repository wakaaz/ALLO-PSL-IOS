//
//  RecomendWordViewController.swift
//  PSL
//
//  Created by MacBook on 25/03/2021.
//

import UIKit
import Alamofire
import SVProgressHUD

class RecomendWordViewController: UIViewController,UITextFieldDelegate {
    @IBOutlet weak var txtField: UITextField!
    
    @IBOutlet weak var tfName: UITextField!
    
    @IBOutlet weak var tfEmail: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUp()
    }
    
    func setUp(){
        self.hideKeyboardWhenTappedAround()
        navigationItem.title = "Recommend a word"
        txtField.delegate = self
        txtField.layer.cornerRadius =   5.0
        txtField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: txtField.frame.height))
        txtField.leftViewMode = .always
        
        
        
        tfName.layer.cornerRadius =   5.0
        tfName.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: tfName.frame.height))
        tfName.leftViewMode = .always
        
        
        tfEmail.layer.cornerRadius =   5.0
        tfEmail.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: tfEmail.frame.height))
        tfEmail.leftViewMode = .always


    }

    @IBAction func onTappedSubmit(_ sender: Any) {
        processRecommendedWord()
    }
    
    func processRecommendedWord(){
        let emailEntered = tfEmail.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let nameEntered = tfName.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let wordEntered = txtField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if emailEntered == "" {
            UICommonMethods.showAlert(title: "Error",message: "Please enter email", viewController: self)
        }
        else if nameEntered == "" {
            UICommonMethods.showAlert(title: "Error",message: "Please enter name", viewController: self)
        }else if wordEntered == "" {
            UICommonMethods.showAlert(title: "Error",message: "Please enter word", viewController: self)
        }else{
            SVProgressHUD.setContainerView(self.view)
            SVProgressHUD.show(withStatus: "Please wait")
            requestrecommendeWord(name: nameEntered, email: emailEntered, word: wordEntered)
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
    
    
    func requestrecommendeWord(name:String,email:String,word:String){
        let headers: HTTPHeaders = [
            "session": AuthenticationPreference.getSession(),
            "userType": UIContant.GUEST_USER
        ]
        let parameter:  Parameters = ["email":email,"name":name,"word":word]
        print(parameter)
        
        AF.request(UIContant.RECOMMENDEDWORD, method: .post, parameters: parameter, encoding: URLEncoding(destination: .methodDependent),headers: headers).responseDecodable(of: RecommenedModel.self)  { response in
            print(response)
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
            switch response.result {
            
            case .success:
                guard let model = response.value else { return }
                if let responseCode = model.code {
                    if responseCode ==  200{
                        
                        self.tfName.text = ""
                        self.tfEmail.text = ""
                        self.txtField.text = ""

                        
                        
                        UICommonMethods.showAlert(title: "Recommedation",message: model.responseMsg ?? "", viewController: self)
                        

                        
                    }else {
                        UICommonMethods.showAlert(title: "Recommedation",message: model.responseMsg ?? "", viewController: self)
                    }
                }
            case .failure(let error):
                print(error)
                UICommonMethods.showAlert(title: "Recommedation",message: error.errorDescription ?? "", viewController: self)
                
            }
        }
    }
    
}
