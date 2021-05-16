//
//  ViewController.swift
//  snsLogin5
//
//  Created by 민트팟 on 2021/05/12.
//

import UIKit
import GoogleSignIn
import AuthenticationServices

class ViewController: UIViewController, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self    .view.window!
    }


    @IBOutlet weak var facebookButton: IndicatorButton!
    @IBOutlet weak var kakaoButton: IndicatorButton!
    @IBOutlet weak var googleButton: IndicatorButton!
    @IBOutlet weak var naverButton: IndicatorButton!
    @IBOutlet weak var loginProviderStackView: UIStackView!
    
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.facebookButton.setTitle("Facebook Login", for: .normal)
        self.facebookButton.setTitleColor(.white, for: .normal)
        self.facebookButton.backgroundColor = UIColor(red: 58/255, green: 92/255, blue: 169/255, alpha: 1)
        
        self.kakaoButton.setTitle("Kakao Login", for: .normal)
        self.kakaoButton.setTitleColor(UIColor(red: 63/255, green: 49/255, blue: 48/255, alpha: 1), for: .normal)
        self.kakaoButton.backgroundColor = UIColor(red: 238/255, green: 218/255, blue: 73/255, alpha: 1)

        self.googleButton.setTitle("Google Login", for: .normal)
        self.googleButton.setTitleColor(.white, for: .normal)
        self.googleButton.backgroundColor = UIColor(red: 197/255, green: 82/255, blue: 64/255, alpha: 1)
        GIDSignIn.sharedInstance()?.presentingViewController = self

        self.naverButton.setTitle("Naver Login", for: .normal)
        self.naverButton.setTitleColor(.white, for: .normal)
        self.naverButton.backgroundColor = UIColor(red: 90/255, green: 178/255, blue: 52/255, alpha: 1)
        
        let authorizationButton = ASAuthorizationAppleIDButton()
        authorizationButton.addTarget(self, action: #selector(handleAuthorizationAppleIDButtonPress), for: .touchUpInside)
        self.loginProviderStackView.addArrangedSubview(authorizationButton)
    }

    @IBAction func facebookTap(_ sender: IndicatorButton) {
        guard !sender.isShowIndicator else { return }
        sender.showIndicator(.gray, color: .white)
        SNSLoginHelper.shared.delegate = self
        SNSLoginHelper.shared.facebookLogin()
    }
    
    @IBAction func kakaoTap(_ sender: IndicatorButton) {
        guard !sender.isShowIndicator else { return }
        sender.showIndicator(.gray, color: .black)
        SNSLoginHelper.shared.delegate = self
        SNSLoginHelper.shared.kakaoLogin()
    }

    @IBAction func googleTap(_ sender: IndicatorButton) {
        guard !sender.isShowIndicator else { return }
        sender.showIndicator(.gray, color: .white)
        SNSLoginHelper.shared.delegate = self
        SNSLoginHelper.shared.googleLogin()
    }

    @IBAction func naverTap(_ sender: IndicatorButton) {
        guard !sender.isShowIndicator else { return }
        sender.showIndicator(.gray, color: .white)
        SNSLoginHelper.shared.delegate = self
        SNSLoginHelper.shared.naverLogin()
    }
    
    
    @objc
    func handleAuthorizationAppleIDButtonPress() {
      let appleIDProvider = ASAuthorizationAppleIDProvider()
      let request = appleIDProvider.createRequest()
      request.requestedScopes = [.fullName, .email]
            
      let authorizationController = ASAuthorizationController(authorizationRequests: [request])
      authorizationController.delegate = self
      authorizationController.presentationContextProvider = self
      authorizationController.performRequests()
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
      if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
          // Create an account in your system.
          let userFullName = appleIDCredential.fullName?.givenName
          let userEmail = appleIDCredential.email
          emailLabel.text = userEmail
          nameLabel.text = userFullName
          //Navigate to other view controller
      } else if let passwordCredential = authorization.credential as? ASPasswordCredential {
          // Sign in using an existing iCloud Keychain credential.
          let username = passwordCredential.user
          let password = passwordCredential.password
          
          //Navigate to other view controller
      }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
      // handle Error.
    }
}

// MARK: SNSLoginDelegate
extension ViewController: SNSLoginDelegate {
    var snsLoginViewController: UIViewController { return self }
    
    func snsLogin(_ type: SNSLogin.LoginType, error: Error?) {
        if type == .facebook {
            self.facebookButton.hideIndicator()
        } else if type == .kakao {
            self.kakaoButton.hideIndicator()
        } else if type == .google {
            self.googleButton.hideIndicator()
        } else if type == .naver {
            self.naverButton.hideIndicator()
        }
        print("Login Error")
        if let error = error {
            print(error)
        }
    }
    
    func snsLogin(_ type: SNSLogin.LoginType, login: SNSLogin) {
        if type == .facebook {
            self.facebookButton.hideIndicator()
        } else if type == .kakao {
            self.kakaoButton.hideIndicator()
        } else if type == .google {
            self.googleButton.hideIndicator()
        } else if type == .naver {
            self.naverButton.hideIndicator()
        }
        print("Login Success")
        print(login)
        
        if login.email != nil {
            emailLabel.text = login.email
        }
        
        if login.name != nil {
            nameLabel.text = login.name
        }
        
        print(login.type)

    }
}
