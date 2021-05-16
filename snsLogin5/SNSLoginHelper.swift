//
//  SNSLoginHelper.swift
//  snsLogin5
//
//  Created by 민트팟 on 2021/05/12.
//

import Foundation
import FBSDKLoginKit
import KakaoSDKAuth
import KakaoSDKCommon
import GoogleSignIn
import NaverThirdPartyLogin


//import GoogleSignIn
//import NaverThirdPartyLogin

protocol SNSLoginDelegate: class {
    var snsLoginViewController: UIViewController { get }
    func snsLogin(_ type: SNSLogin.LoginType, error: Error?)
    func snsLogin(_ type: SNSLogin.LoginType, login: SNSLogin)
}

class SNSLoginHelper: NSObject {

    weak var delegate: SNSLoginDelegate?
    
    static let shared = SNSLoginHelper()
    
    // 페이스북 로그인
    func facebookLogin() {
        guard let viewController = self.delegate?.snsLoginViewController else { return }
        
        LoginManager().logIn(permissions: ["public_profile", "email", "user_birthday", "user_gender"], from: viewController, handler: { (result, error) in
            guard let result = result, error == nil && !result.isCancelled else {
                self.delegate?.snsLogin(.facebook, error: error)
                return
            }
            GraphRequest(graphPath: "me", parameters: ["fields": "id, name, email, birthday, gender, picture"]).start(completionHandler: { (connection, result, error) -> Void in
                guard let result = result as? [String: AnyObject], error == nil else {
                    self.delegate?.snsLogin(.facebook, error: error)
                    return
                }
                self.delegate?.snsLogin(.facebook, login: SNSLogin.facebook(result))
            })
        })
    }
    
    // 페이스북 로그아웃
    func facebookLogout() {
        LoginManager().logOut()
    }
    
    // 카카오 로그인
    func kakaoLogin() {
        guard let viewController = self.delegate?.snsLoginViewController else { return }
        
        if ((KOSession.shared()?.isOpen()) != nil) { KOSession.shared()?.close() }
        KOSession.shared()?.presentingViewController = viewController

        KOSession.shared()?.open(completionHandler: { (error) in
            if error != nil || !(KOSession.shared()?.isOpen())! {
                self.delegate?.snsLogin(.kakao, error: error)
                return
            }
            KOSessionTask.userMeTask(completion: { (error, user) in
                if let account = user?.account {

                    var updateScopes = [String]()

                    if account.needsScopeAccountEmail() { updateScopes.append("account_email") }
                    if account.needsScopeGender() { updateScopes.append("gender") }
                    if account.needsScopeGender() { updateScopes.append("birthday") }

                    KOSession.shared()?.updateScopes(updateScopes, completionHandler: { (error) in
                        guard error == nil else {
                            self.delegate?.snsLogin(.kakao, error: error)
                            return
                        }
                        KOSessionTask.userMeTask(completion: { (error, user) in
                            self.kakaoProfile(error, user: user)
                        })
                    })
                } else {
                    self.kakaoProfile(error, user: user)
                }
            })
        })
    }

    // 카카오 로그인 데이터
    private func kakaoProfile(_ error: Error?, user: KOUserMe?) {
        guard let user = user, error == nil else {
            self.delegate?.snsLogin(.kakao, error: error)
            return
        }
        self.delegate?.snsLogin(.kakao, login: SNSLogin.kakao(user))
    }

    // 카카오 로그아웃
    func kakaoLogout() {
        KOSession.shared()?.logoutAndClose(completionHandler: { (_, _) in })
    }

    // 구글 로그인
    func googleLogin() {
        guard let _ = self.delegate?.snsLoginViewController else { return }
        GIDSignIn.sharedInstance()?.delegate = self
        //GIDSignIn.sharedInstance()?.uiDelegate = self
        GIDSignIn.sharedInstance()?.signIn()
    }

    // 구글 로그아웃
    func googleLogout() {
        GIDSignIn.sharedInstance()?.signOut()
    }

    // 네이버 로그인
    func naverLogin() {
        guard let _ = self.delegate?.snsLoginViewController else { return }
        let naverConnection = NaverThirdPartyLoginConnection.getSharedInstance()
        
        naverConnection?.delegate = self
        naverConnection?.requestThirdPartyLogin()
    }

    // 네이버 로그인 성공시 데이터 통신
    func naverDataFetch(){
        guard let naverConnection = NaverThirdPartyLoginConnection.getSharedInstance(),
            let accessToken = naverConnection.accessToken else {
                self.delegate?.snsLogin(.naver, error: nil)
                return
        }
        let authorization = "Bearer \(accessToken)"

        if let url = URL(string: "https://openapi.naver.com/v1/nid/me") {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue(authorization, forHTTPHeaderField: "Authorization")

            URLSession.shared.dataTask(with: request) { (data, response, error) in
                DispatchQueue.main.async {
                    guard let data = data, error == nil else {
                        self.delegate?.snsLogin(.naver, error: error)
                        return
                    }
                    do {
                        guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject],
                            let response = json["response"] as? [String: AnyObject] else {
                                self.delegate?.snsLogin(.naver, error: nil)
                                return
                        }
                        self.delegate?.snsLogin(.naver, login: SNSLogin.naver(response))
                    } catch let error as NSError {
                        self.delegate?.snsLogin(.naver, error: error)
                    }
                }
            }.resume()
        }
    }

    // 네이버 토큰 리셋
    func naverReset() {
        NaverThirdPartyLoginConnection.getSharedInstance()?.resetToken()
    }

    // 네이버 토큰 삭제
    func naverLogout() {
        NaverThirdPartyLoginConnection.getSharedInstance()?.requestDeleteToken()
    }
}



// MARK: NaverThirdPartyLoginConnectionDelegate
extension SNSLoginHelper: NaverThirdPartyLoginConnectionDelegate {
    // 네이버 로그인 성공 (로그인된 상태에서 requestThirdPartyLogin()를 호출하면 이 메서드는 불리지 않는다.)
    func oauth20ConnectionDidFinishRequestACTokenWithAuthCode() {
        self.naverDataFetch()
    }

    // 네이버 로그인된 상태(로그아웃이나 연동해제 하지않은 상태)에서 로그인 재시도
    func oauth20ConnectionDidFinishRequestACTokenWithRefreshToken() {
        self.naverDataFetch()
    }

    // 접근 토큰, 갱신 토큰, 연동 해제등이 실패
    func oauth20Connection(_ oauthConnection: NaverThirdPartyLoginConnection!, didFailWithError error: Error!) {
        self.delegate?.snsLogin(.naver, error: error)
    }

    // 연동해제 콜백
    func oauth20ConnectionDidFinishDeleteToken() {

    }

    // 사파리에서 화면 띄우기
//    func oauth20ConnectionDidOpenInAppBrowser(forOAuth request: URLRequest!) {
//        guard let viewController = self.delegate?.snsLoginViewController else { return }
//        viewController.present(NLoginThirdPartyOAuth20InAppBrowserViewController(request: request), animated: true, completion: nil)
//    }
}


// MARK: GIDSignInDelegate
extension SNSLoginHelper: GIDSignInDelegate {
    // 구글 로그인 성공
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            self.delegate?.snsLogin(.google, error: error)
            return
        } else if let user = user {
            self.delegate?.snsLogin(.google, login: SNSLogin.google(user))
        }
    }
}

//// MARK: GIDSignInUIDelegate
//extension SNSLoginHelper: GIDSignInUIDelegate  {
//    // 구글 UIViewController dismiss
//    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
//        viewController.dismiss(animated: true, completion: nil)
//    }
//
//    // 구글 UIViewController present
//    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
//        guard let viewController = self.delegate?.snsLoginViewController else { return }
//        viewController.present(viewController, animated: true, completion: nil)
//    }
//}
