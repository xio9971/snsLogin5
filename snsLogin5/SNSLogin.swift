//
//  SNSLogin.swift
//  snsLogin5
//
//  Created by 민트팟 on 2021/05/12.
//

import Foundation
import GoogleSignIn

struct SNSLogin {
    enum LoginType: String {
        case facebook
        case kakao
        case google
        case naver
    }
    
    enum GenderType {
        case male
        case female
        
        static func sns(_ value: AnyObject?) -> GenderType? {
            guard let value = value as? String else { return nil }
            if value.lowercased() == "male" || value.lowercased() == "m" {
                return .male
            } else if value.lowercased() == "female" || value.lowercased() == "f" {
                return .female
            }
            return nil
        }
    }
    
    var type: LoginType
    
    var token: String?
    var name: String?
    var email: String?
    var thumbnailProfileURLPath: String?
    var profileURLPath: String?
    var gender: GenderType?
    var birthday: Date?
    
    init(_ type: LoginType) {
        self.type = type
    }
    
    static func facebook(_ result: [String: AnyObject]) -> SNSLogin {
        var login = SNSLogin(.facebook)
        
        login.token = result["id"] as? String
        login.name = result["name"] as? String
        login.email = result["email"] as? String
        if let picture = result["picture"] as? [String: AnyObject], let data = picture["data"] as? [String: AnyObject] {
            login.thumbnailProfileURLPath = data["url"] as? String ?? ""
        }
        if let token = login.token, token != "" {
            login.profileURLPath = "https://graph.facebook.com/\(token)/picture?type=large"
        }
        login.gender = GenderType.sns(result["gender"])
        if let birthday = result["birthday"] as? String, birthday != "" {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"
            login.birthday = dateFormatter.date(from: birthday)
        }
        
        return login
    }
    
    static func kakao(_ user: KOUserMe) -> SNSLogin {
        var login = SNSLogin(.kakao)

        login.token = user.id
        login.name = user.nickname
        if let gender = user.account?.gender {
            if gender == KOUserGender.male {
                login.gender = GenderType.male
            } else if gender == KOUserGender.female {
                login.gender = GenderType.female
            }
        }
        login.email = user.account?.email ?? ""
        login.profileURLPath = user.profileImageURL?.absoluteString ?? ""
        login.thumbnailProfileURLPath = user.thumbnailImageURL?.absoluteString ?? ""
        return login
    }

    static func google(_ user: GIDGoogleUser) -> SNSLogin {
        var login = SNSLogin(.google)

        login.token = user.userID
        login.name = user.profile.name
        login.email = user.profile.email

        return login
    }

    static func naver(_ response: [String: AnyObject]) -> SNSLogin {
        var login = SNSLogin(.naver)

        login.token = response["id"] as? String
        login.email = response["email"] as? String
        login.name = response["name"] as? String
        login.profileURLPath = response["profile_image"] as? String
        login.gender = GenderType.sns(response["gender"])

        return login
    }
}
