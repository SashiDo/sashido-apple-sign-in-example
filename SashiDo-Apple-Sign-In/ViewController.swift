//
//  ViewController.swift
//  SashiDo-Apple-Sign-In
//
//  Created by Pavel Ivanov on 5.02.20.
//  Copyright © 2020 Pavel Ivanov. All rights reserved.
//

import UIKit
import AuthenticationServices
import Parse

class ViewController: UIViewController, PFUserAuthenticationDelegate {
    func restoreAuthentication(withAuthData authData: [String : String]?) -> Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        PFUser.register(self, forAuthType: "apple")
        
        let button = ASAuthorizationAppleIDButton()
        button.addTarget(self, action: #selector(appleAction), for: .touchUpInside)
        self.view.addSubview(button)
        button.center = self.view.center
    }
    
    @objc func appleAction () {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email];
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
    
    private func getToken(_ credential: ASAuthorizationAppleIDCredential) -> String {
        guard let data = credential.identityToken, let token = String(data: data, encoding: .utf8) else {
            return ""
        }
        return token
    }
    
    private func signIn(token: String, id: String) {
        
        var authData = [String: String]()
        authData["id"] = id
        authData["token"] = token
        
        PFUser.logInWithAuthType(inBackground: "apple", authData: authData).continueWith(block:
            { task -> Void in
                if let user = task.result, task.isCompleted {
                    print("User is logged in", user)
                } else if let e = task.error {
                    print("ERRRREEE", e)
                } else {
                    print("Hmmmmm something is wrong")
                }
        })
    }
    
}

extension ViewController:  ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else {
                fatalError()
        }
        
        return window
    }
    
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let userID = credential.user
            let token = getToken(credential)

            print("@@@", userID)
            print("@@@", token)
            
            signIn(token: token, id: userID)
        }
    }
    
}
