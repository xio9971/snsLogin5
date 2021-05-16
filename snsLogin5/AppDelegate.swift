//
//  AppDelegate.swift
//  snsLogin5
//
//  Created by 민트팟 on 2021/05/12.
//

import UIKit
import FBSDKLoginKit
import GoogleSignIn
import NaverThirdPartyLogin

@main
class AppDelegate: UIResponder, UIApplicationDelegate {


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        GIDSignIn.sharedInstance().clientID = "143242584279-6i9c4bpol6f0paj7v0rukq8f7un6c3ah.apps.googleusercontent.com"
        
        
        let naverThirdPartyLoginInstance = NaverThirdPartyLoginConnection.getSharedInstance()
        // 네이버 앱으로 인증하는 방식을 활성화하려면 앱 델리게이트에 다음 코드를 추가합니다.
        naverThirdPartyLoginInstance?.isNaverAppOauthEnable = true
        // SafariViewContoller에서 인증하는 방식을 활성화하려면 앱 델리게이트에 다음 코드를 추가합니다.
        naverThirdPartyLoginInstance?.isInAppOauthEnable = true
        // 인증 화면을 iPhone의 세로 모드에서만 사용하려면 다음 코드를 추가합니다.
        naverThirdPartyLoginInstance?.setOnlyPortraitSupportInIphone(true)
        // 애플리케이션 이름
        naverThirdPartyLoginInstance?.appName = (Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String) ?? ""
        // 콜백을 받을 URL Scheme
        naverThirdPartyLoginInstance?.serviceUrlScheme = kServiceAppUrlScheme
        // 애플리케이션에서 사용하는 클라이언트 아이디
        naverThirdPartyLoginInstance?.consumerKey = kConsumerKey
        // 애플리케이션에서 사용하는 클라이언트 시크릿
        naverThirdPartyLoginInstance?.consumerSecret = kConsumerSecret
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        guard let scheme = url.scheme else { return true }
        
        if scheme.contains("kakao") {
            if KOSession.isKakaoAccountLoginCallback(url.absoluteURL) {
                return KOSession.handleOpen(url)
            }
            return true
        }

        if scheme.contains("naverlogin") {
            let result = NaverThirdPartyLoginConnection.getSharedInstance().receiveAccessToken(url)
            if result == CANCELBYUSER {
                print("result: \(result)")
            }
            return true
        }
        
        return true
    }
    

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

