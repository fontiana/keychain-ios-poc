//
//  ViewController.swift
//  keychain
//
//  Created by Victor Oliveira on 28/05/21.
//

import UIKit
import LocalAuthentication

class ViewController: UIViewController {
    
    private var UserPassword = "";
    private var UserBiometrics = "";
    
    override func viewDidLoad() {
        super.viewDidLoad()
        PasswordTextField.text = "123456";
        ResultLabel.text = "";
        UsernameTextField.text = "user";
        UserPassword = "user-password"
        UserBiometrics = "user-biometrics"
    }
    
    @IBOutlet weak var ResultLabel: UILabel!
    @IBOutlet weak var PasswordTextField: UITextField!
    @IBOutlet weak var UsernameTextField: UITextField!
    
    @IBAction func saveSecretButton(_ sender: Any) {
        addSecret(password: PasswordTextField.text!);
    }
    @IBAction func UsernameDidChange(_ sender: Any) {
        UserPassword = "\(UsernameTextField.text!)-password"
        UserBiometrics = "\(UsernameTextField.text!)-biometrics"
    }
    
    @IBAction func getSecretButton(_ sender: Any) {
        retrieveSecretUsing(password: PasswordTextField.text!);
    }
    
    func addSecret(password : String) {
        var error : Unmanaged<CFError>?
        let accessControl = SecAccessControlCreateWithFlags(kCFAllocatorDefault,
            kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly,
            [.applicationPassword],
            &error)
        
        let accessControlBiometricOnly = SecAccessControlCreateWithFlags(kCFAllocatorDefault,
            kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly,
            [.biometryAny],
            &error)
        
        let context = LAContext()
        context.setCredential(password.data(using: .utf8), type: .applicationPassword)
        
        let attributesWithPassword = [
          kSecClass: kSecClassGenericPassword,
          kSecValueData: "Victor2021".data(using: .utf8)!,
          kSecAttrAccount: UserPassword,
          kSecAttrService: "secretService",
          kSecAttrAccessControl: accessControl!,
          kSecUseAuthenticationContext: context,
          kSecReturnData: true
        ] as CFDictionary
        
        let attributesWithoutPassword = [
          kSecClass: kSecClassGenericPassword,
          kSecValueData: "Victor2021".data(using: .utf8)!,
          kSecAttrAccount: UserBiometrics,
          kSecAttrService: "secretService",
          kSecAttrAccessControl: accessControlBiometricOnly!,
          kSecReturnData: true
        ] as CFDictionary
        
        let statusPassword = SecItemAdd(attributesWithPassword, nil)
        let statusBiometrics = SecItemAdd(attributesWithoutPassword, nil)
        
        let errorDescriptionPassword = SecCopyErrorMessageString(statusPassword,nil)
        let errorDescriptionBiometrics = SecCopyErrorMessageString(statusBiometrics,nil)
        
        ResultLabel.text = "Save status - Password \(statusPassword) \(errorDescriptionPassword)\n Biometrics \(statusBiometrics) \(errorDescriptionBiometrics)";
    }
    
    func retrieveSecretUsing(password : String) {
        var error : Unmanaged<CFError>?
        let accessControl = SecAccessControlCreateWithFlags(kCFAllocatorDefault,
            kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly,
            [.applicationPassword],
            &error)
        
        let accessControlBiometricOnly = SecAccessControlCreateWithFlags(kCFAllocatorDefault,
            kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly,
            [.biometryAny],
            &error)
        
        let context = LAContext()
        context.setCredential(password.data(using: .utf8), type: .applicationPassword)
        
        let attributesPassword = [
          kSecClass: kSecClassGenericPassword,
          kSecAttrAccount: UserPassword,
          kSecAttrService: "secretService",
          kSecAttrAccessControl: accessControl!,
          kSecMatchLimit: kSecMatchLimitOne,
          kSecUseAuthenticationContext: context,
          kSecReturnData: true
        ] as CFDictionary
        
        let attributesBiometrics = [
          kSecClass: kSecClassGenericPassword,
          kSecAttrAccount: UserBiometrics,
          kSecAttrService: "secretService",
          kSecAttrAccessControl: accessControlBiometricOnly!,
          kSecMatchLimit: kSecMatchLimitOne,
          kSecReturnData: true
        ] as CFDictionary
        
        var ref : AnyObject?
        let statusBiometrics = SecItemCopyMatching(attributesBiometrics, &ref)
        
        if let result = ref {
            let secret = String(data: result as! Data, encoding: .utf8)
            Alert(message: "Biometric step: \(secret)")
        } else {
            let statusPassword = SecItemCopyMatching(attributesPassword, &ref)
            if let result = ref {
                let secret = String(data: result as! Data, encoding: .utf8)
                Alert(message: "Password step: \(secret)")
            }
            
            let errorDescriptionPassword = SecCopyErrorMessageString(statusPassword,nil)
            let errorDescriptionBiometrics = SecCopyErrorMessageString(statusBiometrics,nil)
            
            ResultLabel.text = "Status - Biometrics \(statusBiometrics) \(errorDescriptionPassword)\n Password \(statusPassword) \(statusPassword)"
        }
    }
    
    func Alert(message: String) {
        let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
}
