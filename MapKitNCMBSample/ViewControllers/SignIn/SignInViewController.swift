//
//  SignInViewController.swift
//  InstaSampleSwift5
//
//  Created by Sample on 2020/05/02.
//  Copyright © 2020 sample.com. All rights reserved.
//

import UIKit
import NCMB
import SVProgressHUD

class SignInViewController: UIViewController {
    
    @IBOutlet var userIdTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTextField()
    }
    
    @IBAction func signIn() {
        if userIdTextField == nil && passwordTextField == nil {
            SVProgressHUD.setStatus("ユーザー名とパスワードを入力してください。")
        } else if userIdTextField == nil {
            SVProgressHUD.setStatus("ユーザー名を入力してください。")
        } else if passwordTextField == nil {
            SVProgressHUD.setStatus("パスワードを入力してください。")
        } else if (userIdTextField.text?.count)! > 0 && (passwordTextField.text?.count)! > 0 {
            NCMBUser.logInWithUsername(inBackground: userIdTextField.text, password: passwordTextField.text) { (user, error) in
                if error != nil {
                    SVProgressHUD.showError(withStatus: error!.localizedDescription)
                } else if user?.object(forKey: "active") as? Bool == false {
                    SVProgressHUD.setStatus("そのユーザーは退会済みです。")
                } else {
                    // ログイン成功
                    let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                    let rootViewController = storyboard.instantiateViewController(withIdentifier: "RootTabBarController")
                    // AppDelegateのコードとは違う、表示のコードの書き方
                    UIApplication.shared.keyWindow?.rootViewController = rootViewController
                    
                    // ログイン状態の保持(AppDelegateの"isLogin"の宣言より)
                    let ud = UserDefaults.standard
                    ud.set(true, forKey: "isLogin")
                    ud.synchronize()
                }
            }
        }
    }
    
    // パスワードを忘れた時のために
    @IBAction func forgetPassword() {
        // 置いておく
    }
    
}


// MARK:- textField に関する処理
extension SignInViewController: UITextFieldDelegate {
    
    func configureTextField() {
        userIdTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // TextField以外の部分をタッチ => TextFieldが閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
