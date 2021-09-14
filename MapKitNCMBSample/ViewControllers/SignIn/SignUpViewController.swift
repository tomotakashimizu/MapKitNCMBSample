//
//  SignUpViewController.swift
//  InstaSampleSwift5
//
//  Created by Sample on 2020/05/02.
//  Copyright © 2020 sample.com. All rights reserved.
//

import UIKit
import NCMB
import SVProgressHUD

class SignUpViewController: UIViewController {
    
    @IBOutlet var userIdTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var confirmTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTextField()
    }
    
    @IBAction func signUp() {
        let user = NCMBUser()
        
        if (userIdTextField.text?.count)! < 4 {
            print("文字数が足りません")
            let alertController = UIAlertController(title: "登録できません", message: "ユーザー名を4文字以上で登録してください。", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(action)
            self.present(alertController, animated: true, completion: nil)
            // returnを書いた後の関数内のコードは読まれない
            return
        }
        
        user.userName = userIdTextField.text!
        user.mailAddress = emailTextField.text!
        
        if (passwordTextField.text?.count)! < 6 {
            let alertController2 = UIAlertController(title: "登録できません", message: "パスワードを6文字以上にしてください。", preferredStyle: .alert)
            let action2 = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController2.addAction(action2)
            self.present(alertController2, animated: true, completion: nil)
            // returnを書いた後の関数内のコードは読まれない
            return
        } else if passwordTextField.text == confirmTextField.text {
            user.password = passwordTextField.text!
        } else {
            let alertController3 = UIAlertController(title: "登録できません", message: "パスワードが一致しません。", preferredStyle: .alert)
            let action3 = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController3.addAction(action3)
            self.present(alertController3, animated: true, completion: nil)
            // returnを書いた後の関数内のコードは読まれない
            return
        }
        
        user.signUpInBackground { (error) in
            if error != nil {
                // エラーがあった場合
                SVProgressHUD.showError(withStatus: error!.localizedDescription)
            } else {
                let acl = NCMBACL()
                acl.setPublicReadAccess(true)
                acl.setWriteAccess(true, for: user)
                user.acl = acl
                user.saveEventually({ (error) in
                    if error != nil {
                        SVProgressHUD.showError(withStatus: error!.localizedDescription)
                        self.navigationController?.popViewController(animated: true)
                    } else {
                        // 登録成功
                        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                        let rootViewcontroller = storyboard.instantiateViewController(withIdentifier: "RootTabBarController")
                        // AppDelegateのコードとは違う、表示のコードの書き方
                        UIApplication.shared.keyWindow?.rootViewController = rootViewcontroller
                        
                        // ログイン状態の保持(AppDelegateの"isLogin"の宣言より)
                        let ud = UserDefaults.standard
                        ud.set(true, forKey: "isLogin")
                        ud.synchronize()
                    }
                })
            }
        }
    }
    
}


// MARK:- textField に関する処理
extension SignUpViewController: UITextFieldDelegate {
    
    func configureTextField() {
        userIdTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        confirmTextField.delegate = self
    }
    
    // 改行(完了)ボタンを押した時の処理
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // キーボードを閉じる
        textField.resignFirstResponder()
        return true
    }
    
    // TextField以外の部分をタッチ => TextFieldが閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
